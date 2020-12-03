class SaveDocument < Document::SaveOperation
  # To save user provided params to the database, you must permit them
  # https://luckyframework.org/guides/database/validating-saving#perma-permitting-columns
  #
  permit_columns state

  before_save do
    validate_inclusion_of state, in: Document::STATES
  end

  after_commit :create_or_update_label

  def create_or_update_label(document : Document)
    document.create_or_update_label
  end

end
