module Change
  class SSHReplacer < Service
    def initialize(params = {})
      @name = params[:name]
    end

    def call
      return false unless valid?
      FileUtils.cp_r(ssh_files, ssh_folder_path, remove_destination: true)

      true
    end

    private

    SSH_PATH       = '~/.ssh'
    GIT_USERS_PATH = 'git-users'

    attr_reader :name

    def validate!
      errors.add(:name, Error::Type::BLANK) if name.nil?
    end

    def valid?
      Dir.exist?(user_ssh_path) && ssh_files.all? { |file| File.exist?(file) }
    end

    def ssh_folder_path
      @ssh_folder_path ||= Path.new(SSH_PATH)
    end

    def user_ssh_path
      @user_ssh_path ||= File.join(ssh_folder_path, GIT_USERS_PATH, name)
    end

    def ssh_files
      [private_key, public_key]
    end

    def private_key
      File.join(user_ssh_path, 'id_rsa')
    end

    def public_key
      File.join(user_ssh_path, 'id_rsa.pub')
    end
  end
end
