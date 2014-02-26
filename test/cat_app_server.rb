require 'bundler/setup'
require 'webrick'
require 'active_record_lite'
require 'rails_lite'

class Cat < SQLObject
end

class CatsController < ControllerBase
  def index
    @cats = Cat.all
  end

  def show
    @cat = Cat.find(params[:id].to_i)
  end
end

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

rails_lite = RailsLite.new

rails_lite.router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
end

server.mount_proc '/' do |req, res|
  rails_lite.run(req, res)
end

server.start
