require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'json'
require 'haml'
require 'yaml'
require_relative 'pull_requests'

set :raise_errors, false
set :show_exceptions, false

def h(html)
  CGI.escapeHTML html
end

def config_file_name
  File.join(File.dirname(__FILE__), "config", "build-monitor.yml")
end

def config
  @config ||= YAML.load(File.read(config_file_name))
end

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  ci = CI.new(ignored_projects: config[:ignored_projects])
  pr = PullRequests.new(config)
  @broken_projects = ci.broken_projects
  @in_progress_projects = ci.in_progress_projects
  @recently_built_projects = ci.recently_built_projects
  @pull_requests = pr.pull_requests
  haml :index
end

error 500 do
  haml :error
end

class CI
  def initialize(opts={})
    @url = opts.fetch(:url, "http://ci/api/json?tree=jobs[name,builds[timestamp,result]]")
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

private
  attr_reader :url, :ignored_projects

  def projects
    @projects ||= status["jobs"].map do |hash|
      Project.new(hash.merge(ignored: ignored_projects.include?(hash["name"])))
    end
  end

  def non_ignored_projects
    projects.delete_if(&:ignored?)
  end

  def status
    @status ||= JSON.parse(open(url).read)
  end
end

class Project
  attr_reader :name

  def initialize(opts={})
    @name = opts.fetch("name")
    @builds = opts.fetch("builds").map{|hash| Build.new(hash)}
    @ignored = opts.fetch(:ignored)
  end

  def latest_complete_build
    @builds.find(&:complete?)
  end

  def build_in_progress?
    @builds.first.in_progress?
  end

  def ignored?
    @ignored
  end
end

class Build
  attr_reader :result, :timestamp

  def initialize(opts={})
    @result = opts.fetch("result")
    @result = @result.downcase.to_sym if @result
    @timestamp = Time.at(opts.fetch("timestamp").to_i)
  end

  def complete?
    !in_progress?
  end

  def in_progress?
    !@result
  end

  def failed?
    complete? && result != :success
  end
end
