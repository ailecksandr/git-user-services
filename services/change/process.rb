module Change
  class Process < Lib::Service
    STATES = [:initialized, :commented, :replaced]
    FIELDS = [:name, :email]

    multi_state_machine :field_states, STATES

    def initialize(params = {})
      @silent = params[:silent]

      puts field_states
    end

    def call

    end

    private

    GIT_CONFIG_PATH = '~/.gitconfig'

    attr_reader :config, :silent, :left_border, :right_border, :field_states

    def read!
      @config = Change::FileService.(file_path: GIT_CONFIG_PATH, action: :read).try(:split, '\n')
    end

    def valid?
      # @left_border = config.find_index{ |row| row.include? '[user]' }
      # return echo('## There is not user configurations section! ##') if left_border.nil?
      #
      # @left_border += 1
      # set_right_border!
      #
      # return echo('## User configurations section is empty! ##') if left_border >= right_border
      # true
    end

    def change!
      begin
        (left_border..right_border).each { |index| change_row!(index) }
      end while has_commented?
    end

    def write!
      Change::FileService.(file_path: GIT_CONFIG_PATH, action: :write, data: config)
    end

    def set_right_border!
      local_right_border = config[left_border..-1].find_index{ |row| row.match(/\A[\[].*[\]]/) }
      @right_border      = local_right_border.nil? ? config.size - 1 : local_right_border + left_border
    end

    def change_row!(index)
      FIELDS.each { |field| replace(index, field) }
    end

    def replace(index, field)
      patterns = patterns(field)

      case
        when config[index].include?(patterns[:commented]) && commented?(field)
          config[index].gsub!(patterns[:commented], patterns[:uncommented])
          echo("## \"#{config[index].split('=').last.lstrip}\" is current user ##") if field == 'name'
          replaced!(field)
        when config[index].include?(patterns[:uncommented]) && initialized?(field)
          config[index].gsub!(patterns[:uncommented], patterns[:commented])
          commented!(field)
      end
    end

    def patterns(field)
      {
        commented: "\t# #{field}",
        uncommented: "\t#{field}"
      }
    end
  end
end

