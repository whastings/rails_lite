require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'


class ControllerBase
  attr_reader :params, :req, :res
  alias_method :request, :req
  alias_method :response, :res

  TEMPLATES_BASE_PATH = "views"

  # setup the controller
  def initialize(request, response, route_params = {})
    @req, @res = request, response
    @params = Params.new(request)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    check_already_rendered
    session.store_session(response)
    response.content_type = type
    response.body = content
    @already_rendered = true
  end

  # helper method to alias @already_rendered
  def already_rendered?
    !!@already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    check_already_rendered
    session.store_session(response)
    response.status = 302
    response['Location'] = url
    @already_rendered = true
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    template_content = File.read(template_path(template_name))
    template = ERB.new(template_content)
    response_body = template.result(get_binding)
    render_content(response_body, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(request)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    unless already_rendered?
      render(name)
    end
  end

  private

  def get_binding
    binding
  end

  def check_already_rendered
    raise RuntimeError, 'Tried to respond more than once' if already_rendered?
  end

  def controller_name
    self.class.to_s.underscore
  end

  def template_path(template)
    File.join(TEMPLATES_BASE_PATH, controller_name, "#{template}.html.erb")
  end
end
