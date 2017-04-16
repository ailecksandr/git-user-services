module Change
  class Output < Service
    def initialize(params = {})
      @text   = params[:text]
      @silent = params[:silent]
    end

    def call
      puts(text) unless silent
    end

    private

    attr_reader :text, :silent
  end
end
