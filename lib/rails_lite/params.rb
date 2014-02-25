require 'uri'
require 'json'
require 'active_support/core_ext/hash'

class Params
  # use your initialize to merge params from
  # 1. query string
  # 2. post body
  # 3. route params
  def initialize(request, route_params = {})
    @params = {}
    if request.query_string
      @params.merge!(parse_www_encoded_form(request.query_string))
    end
    if request.body
      @params.merge!(parse_www_encoded_form(request.body))
    end
  end

  def [](key)
    @params[key]
  end

  def permit(*keys)
  end

  def require(key)
  end

  def permitted?(key)
  end

  def to_s
    @params.to_json
  end

  class AttributeNotFoundError < ArgumentError; end;

  private
  # this should return deeply nested hash
  # argument format
  # user[address][street]=main&user[address][zip]=89436
  # should return
  # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
  def parse_www_encoded_form(www_encoded_form)
    parsed = URI.decode_www_form(www_encoded_form)
    {}.tap do |params_hash|
      parsed.each do |(key, value)|
        keys = parse_key(key)
        params_hash.deep_merge!(assign_value(keys, value))
      end
    end
  end

  # this should return an array
  # user[address][street] should return ['user', 'address', 'street']
  def parse_key(key)
    key.split(/\]\[|\[|\]/)
  end

  def assign_value(keys, value)
    return { keys.first => value } if keys.count == 1
    { keys.shift => assign_value(keys, value) }
  end
end
