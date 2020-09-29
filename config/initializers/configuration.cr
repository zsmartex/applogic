require "yaml"

environment = ENV["ATHENA_ENV"]? || "development"

def default_config
  YAML.parse({{ read_file("config/config.yml") }})
end

default_config[environment].as_h.each do |key, value|
  ENV[key.to_s] = value.to_s unless ENV.has_key?(key.to_s)
end
