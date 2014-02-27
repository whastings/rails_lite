class RailsLite
  attr_reader :router

  def initialize
    @router = Router.new
    @resources = {}
    @resources[:csrf_token] = CSRFToken.new
  end

  def run(request, response)
    router.run(request, response, @resources)
  end
end
