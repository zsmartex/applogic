class SaveCode < Code::SaveOperation
  permit_columns attempts, type

  before_save do
    validate_inclusion_of type, in: Code::TYPES
    validate_numeric attempts, greater_than: 0, less_than: 4
  end
end
