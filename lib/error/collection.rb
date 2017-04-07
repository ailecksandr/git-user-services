class Error
  class Collection
    include Enumerable

    attr_reader :errors

    def initialize(*errors)
      @errors = errors
    end

    def messages
      errors.map{ |error| [error.column, error.reason] }
    end

    def full_messages
      errors.map(&:full_message)
    end

    def add(error, error_type = nil, options = {})
      raise "#{self.class.name} can contain only Error" if error_type.nil? && !error.is_a?(Error)

      error = Error.new(error, error_type, options)
      errors << error
    end

    def clear
      errors.clear
    end

    def delete(object)
      errors.delete(object)
    end

    def empty?
      errors.empty?
    end

    def each
      errors.each{ |error| yield(error) }
    end
  end
end
