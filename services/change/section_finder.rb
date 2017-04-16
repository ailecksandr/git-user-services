module Change
  class SectionFinder < Lib::Service
    def initialize(params = {})
      @name   = params[:name]
      @config = params[:config]
      @silent = params[:silent]
    end

    def call
      set_left_border!
      return section_not_found! if left_border.nil?

      set_right_border!
      return section_is_blank!  if left_border >= right_border

      borders
    end

    private

    attr_reader :name, :config, :left_border, :right_border, :silent

    def validate!
      errors.add(:name, Error::Type::BLANK) if name.nil?
      errors.add(:config, Error::Type::INVALID_TYPE, class_name: Array) unless config.is_a?(Array)
    end

    def set_left_border!
      @left_border = config.find_index{ |row| row.include?("[#{name}]") }
      return if left_border.nil?

      @left_border += 1
    end

    def set_right_border!
      local_right_border = config[left_border..-1].find_index{ |row| row.match(/\A[\[].*[\]]/) }
      @right_border      = local_right_border.nil? ? config.size - 1 : local_right_border + left_border
    end

    def borders
      {
        left:  left_border,
        right: right_border
      }
    end

    def section_not_found!
      Output.(text: "## There is not #{decorated_name} configurations section! ##", silent: silent)
    end

    def section_is_blank!
      Output.(text: "## #{decorated_name} configurations section is empty! ##", silent: silent)
    end

    def decorated_name
      name.capitalize
    end
  end
end
