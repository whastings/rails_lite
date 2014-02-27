class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
      pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(request)
    request.request_method.downcase.to_sym == http_method &&
      !!(request.path =~ pattern)
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(request, response, resources)
    controller = controller_class.new(request, response,
                                      resources, route_params(request))
    controller.invoke_action(action_name.to_sym)
  end

  private

  def route_params(request)
    params = {}
    matches = pattern.match(request.path)
    matches.names.each do |name|
      value = matches[name]
      params[name] = value unless value.nil?
    end
    params
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
    @matched_routes = {}
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  def draw(&proc)
    self.instance_eval(&proc)
  end

  # make each of these methods that
  # when called add route
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(request)
    request_match = RequestMatch.new(request.path, request.request_method)
    return @matched_routes[request_match] if @matched_routes[request_match]
    matched_route = @routes.find { |route| route.matches?(request) }
    @matched_routes[request_match] = matched_route
    matched_route
  end

  # either throw 404 or call run on a matched route
  def run(request, response, resources)
    route = match(request)
    if route
      route.run(request, response, resources)
    else
      response.status = 404
    end
  end

  class RequestMatch
    def initialize(path, http_method)
      @path, @http_method = path, http_method
    end

    def eql?(other)
      self.path == other.path && self.http_method == other.http_method
    end

    def hash
      @path.hash ^ @http_method.hash
    end

    protected

    attr_reader :path, :http_method
  end
end
