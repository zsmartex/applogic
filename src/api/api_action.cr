# Include modules and add methods that are for all API requests
abstract class ApiAction < Lucky::Action
  include API::Mixins::Auth
  include API::Mixins::Management::JWTAuthenticationMiddleware

  include Lucky::SecureHeaders::SetXSSGuard
  include Lucky::SecureHeaders::SetFrameGuard
  include Lucky::SecureHeaders::SetSniffGuard

  def frame_guard_value : String
    "deny"
  end

  # APIs typically do not need to send cookie/session data.
  # Remove this line if you want to send cookies in the response header.
  disable_cookies
  accepted_formats [:json]

  def error!(body : NamedTuple(errors: Array(String)), code : Int32)
    begin
      raise Exception.new
    rescue e
      report_exception(e)

      json(body, 422)
    end
  end
end
