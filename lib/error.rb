class Error
  attr_reader :column, :error_type, :options

  def initialize(column, error_type, options = {})
    @column     = column
    @error_type = error_type
    @options    = options

    validate!
  end

  def full_message
    "<#{column}> #{reason}"
  end

  def reason
    reasons[error_type]
  end

  private

  def validate!
    return if required_columns[error_type].nil?

    invalid_columns = required_columns[error_type]
      .inject([]) { |selected, column| options[column].nil? ? selected << column : selected }

    raise_invalid_columns(invalid_columns) unless invalid_columns.empty?
  end

  def raise_invalid_columns(columns)
    wrapped_columns = columns.map { |column| "#{column}" }.join(', ')

    raise "Error must have next options: <#{wrapped_columns}>"
  end

  def reasons
    @reasons ||= {
      Error::Type::BLANK        => 'can\'t be blank',
      Error::Type::INVALID_TYPE => "is not a #{options[:class_name]}",
      Error::Type::NOT_INCLUDED => "isn't included in #{options[:in]}",
    }
  end

  def required_columns
    @required_columns ||= {
      Error::Type::INVALID_TYPE => [:class_name],
      Error::Type::NOT_INCLUDED => [:in]
    }
  end
end