require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'
require 'json'
require 'haml'
require 'yaml'

require 'pull_requests'
require 'ci'
require 'project'
require 'build'

set :raise_errors, false
set :show_exceptions, false
set :root, File.join(File.dirname(__FILE__), '..')
# set :root, Proc.new { File.join(root, "views") }
# set :public_folder, Proc.new { File.join(root, "public") }

def h(html)
  CGI.escapeHTML html
end

def config_file_name
  File.join(File.dirname(__FILE__), "..", "config", "build-monitor.yml")
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
