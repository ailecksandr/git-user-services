module Change
  class FileService < Lib::Service
    def initialize(params = {})
      @file_path = params[:file_path]
      @action    = params[:action]
      @data      = params[:data]
      @silent    = params[:silent]
    end

    def call
      prepare!
      return read! if action == READ_ACTION

      write!
    end

    private

    READ_ACTION  = :read
    WRITE_ACTION = :write

    attr_reader :file_path, :action, :data, :silent

    def validate!
      errors.add(:file_path, Error::Type::INVALID_TYPE, class_name: String) unless file_path.is_a?(String)
      errors.add(:action, Error::Type::NOT_INCLUDED, in: actions)           unless actions.include?(action)
      errors.add(:data, Error::Type::BLANK)                                 if action == WRITE_ACTION && data.nil?
    end

    def prepare!
      @file_path.gsub!('~/', "#{ENV['HOME']}/")
    end

    def read!
      puts File.read(file_path)
    end

    def write!
      File.open(file_path, 'w') { |file| file.puts(data) }
      Output.(text: "## <#{file_name}> was changed successfully! ##", silent: silent)
    rescue
      Output.(text: '## Read-only access! ##', silent: silent)
    end

    def actions
      @actions ||= [READ_ACTION, WRITE_ACTION]
    end

    def file_name
      @file_name ||= file_path.split('/').last
    end
  end
end

