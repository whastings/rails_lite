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
    store_session_id
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
    session_cookie.path = '/'
    response.cookies << session_cookie
  end

  def session_id
    @attributes['session_id']
  end

  private

  def store_session_id
    return unless @attributes['session_id'].nil?
    @attributes['session_id'] = SecureRandom.urlsafe_base64(16)
  end
end
