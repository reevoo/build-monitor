require 'github_api'
require 'time_difference'

PullRequest = Struct.new(:title, :user_avatar_url, :build_status, :days_open)

class PullRequests
  def initialize(opts={})
    @oauth_token = opts.fetch(:oauth_token)
    @org_name = opts.fetch(:org_name)
  end

  def pull_requests
    @github = Github.new(oauth_token: oauth_token)
    @pull_requests ||= repo_names.each_with_object({}) do |repo_name, hash|
      pulls = github.pull_requests.list(org_name, repo_name)
      requests = pulls.map do |pull|
        PullRequest.new(
          pull.title,
          pull.user.avatar_url,
          build_status(repo_name, pull.head.sha),
          days_open(pull.created_at)
        )
      end.sort_by(&:title)
      hash[repo_name] = requests unless requests.empty?
    end
  rescue Github::Error::ServiceError => e
    {
      'error' => [
        PullRequest.new(
          'Github connection error',
          'https://github.com/images/error/angry_unicorn.png',
          'failure',
          100
        )
      ]
    }
  end

private
  attr_reader :org_name, :github, :oauth_token

  def repo_names
    @repo_names ||= github.
                      repos.
                      list(org: org_name, per_page: 100).
                      select {|repo| repo.open_issues > 0}.
                      map(&:name)
  end

  def build_status(repo_name, sha)
    status = github.repos.statuses.list(org_name, repo_name, sha).first
    if status
      status.state
    else
      ""
    end
  end

  def days_open(created_time)
    TimeDifference.between(Time.now, Time.parse(created_time)).in_days
  end
end
