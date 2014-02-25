require 'json'
require 'webrick'

class Session
  SESSION_COOKIE_NAME = '_rails_lite_app'

  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(request)
    request.cookies.each do |cookie|
      next unless cookie.name == SESSION_COOKIE_NAME
      @attributes = JSON.parse(cookie.value)
    end
    @attributes ||= {}
  end

  def [](key)
    @attributes[key]
  end

  def []=(key, value)
    if value.nil?
      @attributes.delete(key)
    else
      @attributes[key] = value
    end
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(response)
    value = @attributes.to_json
    session_cookie = WEBrick::Cookie.new(SESSION_COOKIE_NAME, value)
    response.cookies << session_cookie
  end
end
