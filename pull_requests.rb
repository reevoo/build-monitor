require 'github_api'

PullRequest = Struct.new(:title, :user_avatar_url)

class PullRequests
  def initialize(opts={})
    oauth_token = opts.fetch(:oauth_token)
    @org_name = opts.fetch(:org_name)
    @github = Github.new(oauth_token: oauth_token)
  end

  def pull_requests
    @pull_requests ||= repo_names.each_with_object({}) do |repo_name, hash|
      pulls = github.pull_requests.list(org_name, repo_name)
      requests = pulls.map do |pull|
        PullRequest.new(pull.title, pull.user.avatar_url)
      end
      hash[repo_name] = requests unless requests.empty?
    end
  end

private
  attr_reader :org_name, :github

  def repo_names
    @repo_names ||= github.
                      repos.
                      list(org: org_name, per_page: 100).
                      select {|repo| repo.open_issues > 0}.
                      map(&:name)
  end
end
