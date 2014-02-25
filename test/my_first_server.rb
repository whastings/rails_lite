# A little request/response handling warm-up.

require 'webrick'

server = WEBrick::HTTPServer.new(Port: 8080)

server.mount_proc('/') do |request, response|
  response.content_type = 'text/text'
  response.body = request.path
end

trap('INT') { server.shutdown }

if __FILE__ == $PROGRAM_NAME
  server.start
end
