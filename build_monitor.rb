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

def github_config
  @github_config ||= YAML.load(File.read("config/github.yml"))
end

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  ci = CI.new
  pr = PullRequests.new(github_config)
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
  def initialize(url="http://ci/api/json?tree=jobs[name,builds[timestamp,result]]")
    @url = url
  end

  def broken_projects
    projects.select{|project| project.latest_complete_build.failed?}
  end

  def in_progress_projects
    projects.select(&:build_in_progress?)
  end

  def recently_built_projects(n=5)
    projects.sort_by{|project| project.latest_complete_build.timestamp}.reverse.first(n)
  end

private
  attr_reader :url

  def projects
    @projects ||= status["jobs"].map{|hash| Project.new(hash)}
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
  end

  def latest_complete_build
    @builds.find(&:complete?)
  end

  def build_in_progress?
    @builds.first.in_progress?
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
