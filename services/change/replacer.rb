module Change
  class Replacer < Service
    def initialize(params = {})
      @config  = params[:config]
      @borders = params[:borders]
      @fields  = params[:fields]
      @silent  = params[:silent]
    end

    def call
      init_field_states!(fields)
      replace!
      check!
      check_ssh!

      config
    end

    private

    STATES                 = [:initialized, :commented, :replaced]
    SSH_FOLDER_NAME_COLUMN = :email
    multi_state_machine :field_states, STATES

    attr_reader :config, :borders, :fields, :ssh_replaced, :silent

    def validate!
      errors.add(:config, Error::Type::INVALID_TYPE, class_name: Array) unless config.is_a?(Array)
      errors.add(:borders, Error::Type::INVALID_TYPE, class_name: Hash) unless borders.is_a?(Hash)
      errors.add(:fields, Error::Type::INVALID_TYPE, class_name: Array) unless fields.is_a?(Array)
    end

    def replace!
      begin
        (borders[:left]..borders[:right]).each { |index| change_row!(index) }
      end while has_commented?
    end

    def check!
      fields.each { |field| nothing_changed!(field) if initialized?(field) }
    end

    def check_ssh!
      return ssh_replaced! if ssh_replaced

      ssh_not_replaced!
    end

    def change_row!(index)
      fields.each { |field| replace(index, field) }
    end

    def replace(index, field)
      patterns = patterns(field)

      case
      when config[index].include?(patterns[:commented]) && commented?(field)
        config[index].gsub!(patterns[:commented], patterns[:uncommented])
        value = config[index].split('=').last.lstrip
        replace_ssh!(value) if field == SSH_FOLDER_NAME_COLUMN
        inform!(field, value)
        replaced!(field)
      when config[index].include?(patterns[:uncommented]) && not_commented?(field)
        config[index].gsub!(patterns[:uncommented], patterns[:commented])
        commented!(field) if not_replaced?(field)
      end
    end

    def replace_ssh!(value)
      @ssh_replaced = Change::SSHReplacer.(name: value)
    end

    def patterns(field)
      {
        commented: "\t# #{field}",
        uncommented: "\t#{field}"
      }
    end

    def inform!(field, value)
      Output.(text: "## #{decorated_field(field)} was replaced to #{value} ##", silent: silent)
    end

    def ssh_replaced!
      Output.(text: '## SSH keys were replaced ##', silent: silent)
    end

    def ssh_not_replaced!
      Output.(text: '## SSH keys were not replaced ##', silent: silent)
    end

    def nothing_changed!(field)
      Output.(text: "## #{decorated_field(field)} was not replaced ##", silent: silent)
    end

    def decorated_field(field)
      field.capitalize
    end
  end
end
