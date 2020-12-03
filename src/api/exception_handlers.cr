# This class handles error responses and reporting.
#
# https://luckyframework.org/guides/http-and-routing/error-handling
class ExceptionHandlers < Lucky::ErrorAction
  default_format :json
  dont_report [Lucky::RouteNotFoundError, Avram::RecordNotFoundError]

  def path_with_dot
    (request.path.split("/") - ["", nil]).join(".")
  end

  def render(error : Lucky::RouteNotFoundError | Avram::RecordNotFoundError)
    plain_text "404 Not Found", status: 404
  end

  # When an InvalidOperationError is raised, show a helpful error with the
  # param that is invalid, and what was wrong with it.
  def render(error : Avram::InvalidOperationError)
    error_json \
      message: error.renderable_message,
      status: 400
  end

  # Always keep this below other 'render' methods or it may override your
  # custom 'render' methods.
  def render(error : Lucky::RenderableError)
    error_json error.renderable_message, status: error.renderable_status
  end

  def render(error : Lucky::MissingParamError)
    error_json({ errors: ["#{path_with_dot}.missing_#{error.param_name}"] }, 422)
  end

  def render(error : Lucky::MissingNestedParamError)
    error_json({ errors: ["#{path_with_dot}.missing_#{error.nested_key}"] }, 422)
  end

  def render(error : Lucky::InvalidParamError)
    error_json({ errors: ["#{path_with_dot}.invalid_#{error.param_name}"] }, 422)
  end

  def render(error : Lucky::ParamParsingError)
    error_json({ errors: ["server.method.invalid_message_body"] }, 400)
  end

  # If none of the 'render' methods return a response for the raised Exception,
  # Lucky will use this method.
  def default_render(error : Exception) : Lucky::Response
    error_json({ errors: ["server.internal_error"] }, status: 500)
  end

  private def error_json(message, status : Int)
    json message, status: status
  end

  private def report(error : Exception) : Nil
    # Send to Rollbar, send an email, etc.
  end
end
