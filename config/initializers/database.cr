database_name = "peatio_#{Lucky::Env.name}"

AppDatabase.configure do |settings|
  if Lucky::Env.production?
    settings.credentials = Avram::Credentials.parse(ENV["DB_URL"])
  else
    settings.credentials = Avram::Credentials.parse?(ENV["DB_URL"]?) || Avram::Credentials.new(
      database: ENV["DATABASE_NAME"]? || database_name,
      hostname: ENV["DATABASE_HOST"]? || "localhost",
      port: ENV["DATABASE_PORT"]?.try(&.to_i) || 5432,
      # Some common usernames are "postgres", "root", or your system username (run 'whoami')
      username: ENV["DATABASE_USER"]? || "postgres",
      # Some Postgres installations require no password. Use "" if that is the case.
      password: ENV["DATABASE_PASS"]? || "postgres"
    )
  end
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase

  # In production, allow lazy loading (N+1).
  # In development and test, raise an error if you forget to preload associations
  settings.lazy_load_enabled = Lucky::Env.production?
end
