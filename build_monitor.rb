require 'bundler/setup'
require 'sinatra'
require "sinatra/reloader" if development?

get '/' do
  @display_time = Time.now.strftime("%H:%M")
  haml :index
end
