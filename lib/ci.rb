require 'tempfile'
require 'fileutils'
require 'config'
require 'open-uri'
require 'data_repository'

class CI
  def initialize(opts=Conf.config)
    @url = opts.fetch(:url, "http://ci/api/json?tree=jobs[name,builds[timestamp,result,building]]")
    @ignored_projects = opts[:ignored_projects] || []
  end

  def broken_projects
    non_ignored_projects.select{|project| project.latest_complete_build.failed?}
  end

  def in_progress_projects
    projects.select(&:build_in_progress?)
  end

  def recently_built_projects(n=5)
    non_ignored_projects.sort_by { |project|
      project.latest_complete_build.timestamp
    }.reverse.first(n)
  end

  def update
    DataRepository.save('ci', open(url).read)
  end

private
  attr_reader :url, :ignored_projects

  def projects
    @projects ||= status["jobs"].map do |hash|
      Project.new(hash.merge(ignored: ignore_project?(hash["name"])))
    end
  end

  def ignore_project?(name)
    ignored_projects.include?(name) || name.match(/branches/i)
  end

  def non_ignored_projects
    projects.delete_if(&:ignored?)
  end

  def status
    @status ||= JSON.parse(DataRepository.read("ci"))
  end
end
