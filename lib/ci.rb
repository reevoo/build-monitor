require 'tempfile'
require 'fileutils'
require 'config'
require 'open-uri'

class CI
  def initialize(opts=Conf.config)
    @url = opts.fetch(:url, "http://ci/api/json?tree=jobs[name,builds[timestamp,result,building]]")
    @ignored_projects = opts[:ignored_projects] || []
    @data_dir = opts.fetch(:data_dir)
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
    file = Tempfile.new('ci')
    file.write(open(url).read)
    file.close
    FileUtils.mv(file.path, "#{data_dir}/ci.json")
  end

private
  attr_reader :url, :ignored_projects, :data_dir

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
    @status ||= JSON.parse(File.read("#{data_dir}/ci.json"))
  end
end
