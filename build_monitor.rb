require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'json'
require 'haml'

set :raise_errors, false
set :show_exceptions, false

def h(html)
  CGI.escapeHTML html
end

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  ci = CI.new
  @broken_projects = ci.broken_projects
  @in_progress_projects = ci.in_progress_projects
  @recently_built_projects = ci.recently_built_projects
  haml :index
end


error 500 do
  haml :error
end

class CI
  def initialize(url="http://ci/api/json?tree=jobs[name,color,builds[timestamp,result]]&pretty")
    @url = url
  end

  def broken_projects
    projects_with_color('red')
  end

  def in_progress_projects
    projects_with_color('blue_anime')
  end

  def recently_built_projects(n=5)
    projects.sort_by{|project| project.latest_build.timestamp}.reverse.first(n)
  end

private
  attr_reader :url

  def projects
    @projects ||= status["jobs"].map{|hash| Project.new(hash)}
  end

  def projects_with_color(color)
    projects.select{|project| project.color == color}
  end

  def status
    @status ||= JSON.parse(open(url).read)
  end
end

class Project
  attr_reader :name, :color

  def initialize(opts={})
    @name = opts.fetch("name")
    @color = opts.fetch("color")
    @builds = opts.fetch("builds").map{|hash| Build.new(hash)}
  end

  def latest_build
    @builds.first
  end
end

class Build
  attr_reader :result, :timestamp

  def initialize(opts={})
    @result = opts.fetch("result").downcase.to_sym
    @timestamp = Time.at(opts.fetch("timestamp").to_i)
  end
end
