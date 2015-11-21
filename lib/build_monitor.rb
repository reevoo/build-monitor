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
require 'helpers'
require 'kitten'
require 'seasonal_fun'

set :raise_errors, false
set :show_exceptions, false

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  ci = CI.new
  pr = PullRequests.new
  @broken_projects = ci.broken_projects
  @in_progress_projects = ci.in_progress_projects
  @recently_built_projects = ci.recently_built_projects
  @pull_requests = pr.pull_requests

  @flattened_pull_requests = @pull_requests.values.flatten
  @pull_request_count = @flattened_pull_requests.count
  @pull_request_days = @flattened_pull_requests.reduce(0) { |memo, request| memo + request.days_since_last_update }

  haml :index
end

error 500 do
  haml :error
end
