require "action-controller"
require "action-controller/server"

# Filter out sensitive params that shouldn't be logged
filter_params = ["password", "bearer_token"]
keeps_headers = ["X-Request-ID"]

# Add handlers that should run before your application
ActionController::Server.before(
  ActionController::ErrorHandler.new(Finex.running_in_production?, keeps_headers),
  ActionController::LogHandler.new(filter_params),
  HTTP::CompressHandler.new
)

# Configure session cookies
# NOTE:: Change these from defaults
ActionController::Session.configure do |settings|
  # HTTPS only:
  settings.secure = Finex.running_in_production?
end
