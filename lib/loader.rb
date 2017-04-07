module Lib
  class Loader
    class << self
      def call
        require!
      end

      private

      def require!
        app_folders.each { |folder| require_folder(folder) }
      end

      def require_folder(folder)
        Dir[path(folder)].each { |file| require(file) }
      end

      def app_folders
        @app_folders ||= %w(lib services)
      end

      def path(folder)
        File.join('.', "#{folder}/**/*.rb")
      end
    end
  end
end
