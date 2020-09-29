require "jennifer"
require "jennifer/adapter/mysql"

Jennifer::Config.configure do |conf|
  conf.host = ENV["DATABASE_HOST"]
  conf.port = ENV["DATABASE_PORT"].to_i
  conf.user = ENV["DATABASE_USER"]
  conf.password = ENV["DATABASE_PASS"]
  conf.adapter = ENV["DATABASE_ADAPTER"]
  conf.db = ENV["DATABASE_NAME"]
  conf.pool_size = 12
  conf.retry_attempts = 500
end

Jennifer::Config.configure do |conf|
  conf.logger.level = Log::Severity::Debug
end

require "../../src/models/base_model"
require "../../src/models/*"
