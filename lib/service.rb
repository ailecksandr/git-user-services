class Service
  extend Concerns::StateMachine

  def self.call(params = {})
    new(params).send(:run)
  end

  private

  attr_reader :errors

  def run
    @errors = Error::Collection.new

    validate!
    return invalid_params! unless service_valid?

    call
  end

  def validate!; end

  def service_valid?
    errors.empty?
  end

  def invalid_params!
    return if errors.empty?

    print_errors!
  end

  def print_errors!
    puts "## #{self.class.name} wasn't called for next errors: ##"

    errors.full_messages.each_with_index { |error, index| puts "#{index + 1}) #{error}" }
  end
end
