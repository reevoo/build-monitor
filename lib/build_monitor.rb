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

set :raise_errors, false
set :show_exceptions, false

def config_file_name
  File.join(File.dirname(__FILE__), "..", "config", "build-monitor.yml")
end

def config
  @config ||= YAML.load(File.read(config_file_name))
end

helpers do
  def random_good_image
    [
      "http://placekitten.com/300/#{301 + rand(10)}",
      'http://stream1.gifsoup.com/view/437149/roomba-kittens-o.gif',
      'http://i.imgur.com/tAlRlje.gif',
    ].sample
  end

  def random_bad_image
    [
      'http://laughingthroughthepain.files.wordpress.com/2011/03/crazy-cat.gif',
      'http://i.imgur.com/C9EtF56.gif',
      'http://i.imgur.com/tAgFfQa.gif',
      'http://i.imgur.com/2XaQEnK.gif',
      'http://i.imgur.com/dLaAl1M.gif',
    ].sample
  end
end

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  ci = CI.new(ignored_projects: config[:ignored_projects])
  pr = PullRequests.new(config)
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
