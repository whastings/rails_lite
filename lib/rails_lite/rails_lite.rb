class RailsLite
  attr_reader :router

  def initialize
    @router = Router.new
  end

  def run(request, response)
    router.run(request, response)
  end
end
