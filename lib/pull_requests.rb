require 'octokit'
require 'time_difference'
require 'json'
require 'tempfile'
require 'fileutils'
require 'config'
require 'data_repository'

class PullRequests
  def initialize(opts=Conf.config)
    @oauth_token = opts.fetch(:oauth_token)
    @org_name = opts.fetch(:org_name)
  end

  def pull_requests
    json = JSON.parse(DataRepository.read('prs'))
    Hash[json.map { |proj, prs| [proj, prs.map { |pr| Struct.new(*pr.keys.map(&:intern)).new(*pr.values)} ]}]
  end

  def update
    init_github!
    data = JSON.dump(open_pull_requests.group_by { |pr| pr[:repo_name] })
    DataRepository.save('prs', data)
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

        {
          title: search_result.title,
          repo_name: pull_request.base.repo.name,
          user_avatar_url: search_result.user.avatar_url,
          build_status: build_status(pull_request),
          days_since_last_update: days_since(search_result.updated_at),
          modifications: pull_request.additions + pull_request.deletions,
        }
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
