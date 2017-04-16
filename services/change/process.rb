module Change
  class Process < Service
    def initialize(params = {})
      @silent  = params[:silent]
    end

    def call
      read!
      return if config.nil?

      prepare!
      find_user_configurations!
      return if borders.nil?

      change!
      write!
    end

    private

    FIELDS          = [:name, :email]
    GIT_CONFIG_PATH = '~/.gitconfig'

    attr_reader :config, :silent, :borders

    def read!
      @config = Change::FileService.(file_path: GIT_CONFIG_PATH, action: :read, silent: silent)
    end

    def prepare!
      @config = config.split("\n")
    end

    def find_user_configurations!
      @borders = Change::SectionFinder.(name: 'user', config: config, silent: silent)
    end

    def change!
      @config = Change::Replacer.(config: config, borders: borders, fields: FIELDS, silent: silent)
    end

    def write!
      Change::FileService.(file_path: GIT_CONFIG_PATH, action: :write, data: config, silent: silent)
    end
  end
end
