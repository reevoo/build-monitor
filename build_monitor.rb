require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?
require 'open-uri'

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  @broken_builds = CI.new.broken_builds
  haml :index
end

class CI
  def initialize(url="http://ci/api/json")
    @url = url
  end

  def broken_builds
    status["jobs"].select{|job| job["color"] == 'red' }
  end

private
  attr_reader :url

  def status
    JSON.parse(open(url).read)
  end
end