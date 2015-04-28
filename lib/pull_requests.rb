require 'octokit'
require 'time_difference'

PullRequest = Struct.new(:title, :repo_name, :user_avatar_url, :build_status, :days_since_last_update, :modifications)

class PullRequests
  def initialize(opts={})
    @oauth_token = opts.fetch(:oauth_token)
    @org_name = opts.fetch(:org_name)
  end

  def pull_requests
    init_github!

    @pull_requests ||= open_pull_requests
      .group_by { |pr| pr.repo_name }
  end

private
  attr_reader :org_name, :github, :oauth_token

  def init_github!
    @github = Octokit::Client.new(
      access_token: oauth_token,
      auto_paginate: true
    )
  end

  def open_pull_requests
    github
      .search_issues('is:open is:pr user:reevoo')
      .items
      .map { |search_result|
        pull_request = github.get(search_result.pull_request.url)

        PullRequest.new(
          search_result.title,
          pull_request.base.repo.name,
          search_result.user.avatar_url,
          build_status(pull_request),
          days_since(search_result.updated_at),
          pull_request.additions + pull_request.deletions,
        )
      }
  end

  def build_status(pull_request)
    statuses = pull_request.rels[:statuses].get.data

    return '' unless statuses.any?
    statuses.first.state
  end

  def days_since(time)
    TimeDifference.between(Time.now, time).in_days
  end
end
