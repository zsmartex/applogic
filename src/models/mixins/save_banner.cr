class SaveBanner < Banner::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/validating-saving#perma-permitting-columns
  #
  permit_columns state

  before_save do
    validate_inclusion_of state, in: Banner::STATES
  end
end
