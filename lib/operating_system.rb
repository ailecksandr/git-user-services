class OperatingSystem
  class << self
    def windows?
      !(RUBY_PLATFORM =~ WINDOWS_REGEXP).nil?
    end

    def mac?
      !(RUBY_PLATFORM =~ MAC_REGEXP).nil?
    end

    def unix?
      !windows?
    end

    def linux?
      unix? && !mac?
    end

    private

    WINDOWS_REGEXP = /cygwin|mswin|mingw|bccwin|wince|emx/
    MAC_REGEXP     = /darwin/
  end
end
