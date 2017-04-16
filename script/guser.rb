require 'fileutils'

class ChangeGitUser
	def self.call(args = {})
		new(args).call
	end

	def initialize(params = {})
		@silent    = params[:silent]

		prepare!
	end

	def call
		read!
		return unless valid?

		change!
		check_ssh!
		write!
	end

	private

	STATES         				 = [:initialized, :commented, :replaced]
	FIELDS         				 = [:name, :email]
	FILE_NAME      				 = "#{ENV['HOME']}/.gitconfig"
	SSH_FOLDER_NAME_COLUMN = :email
	SSH_PATH       				 = "#{ENV['HOME']}/.ssh"
	GIT_USERS_PATH 				 = 'git-users'

	attr_reader :config, :silent, :left_border, :right_border, :field_states, :ssh_replaced

	STATES.each do |key|
		define_method "#{key}!" do |field|
			@field_states[field] = key
		end

		define_method "#{key}?" do |field|
			field_states[field] == key
		end

		define_method "has_#{key}?" do
			field_states.values.any? { |state| state == key }
		end
	end

	def prepare!
		@field_states = Hash.new
		FIELDS.each { |field| initialized!(field) }
	end

	def read!
		@config = File.read(FILE_NAME).split("\n")
	end

	def valid?
		@left_border = config.find_index{ |row| row.include? '[user]' }
		return echo('## There is not user configurations section! ##') if left_border.nil?

		@left_border += 1
		set_right_border!

		return echo('## User configurations section is empty! ##') if left_border >= right_border
		true
	end

	def change!
		begin
			(left_border..right_border).each { |index| change_row!(index) }
		end while has_commented?
	end

	def check_ssh!
		return echo('## SSH keys were replaced ##') if ssh_replaced

		echo('## SSH keys were not replaced ##')
	end

	def write!
		File.open(FILE_NAME, "w") { |file| file.puts(config) }
		echo('## Config was changed successfully! ##')
	rescue
		echo('## Read-only access! ##')
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
			value = config[index].split('=').last.lstrip
			echo("## \"#{value}\" is current user ##") if field == :name
			replace_ssh!(value)                        if field == SSH_FOLDER_NAME_COLUMN
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

	def replace_ssh!(name)
		return unless ssh_valid?(name)

		FileUtils.cp_r(ssh_files(name), SSH_PATH, remove_destination: true)
		@ssh_replaced = true
	end

	def ssh_valid?(name)
		Dir.exist?(user_ssh_path(name)) && ssh_files(name).all? { |file| File.exist?(file) }
	end

	def echo(text)
		puts(text) unless silent	
	end

	def user_ssh_path(name)
		File.join(SSH_PATH, GIT_USERS_PATH, name)
	end

	def ssh_files(name)
		[private_key(name), public_key(name)]
	end

	def private_key(name)
		File.join(user_ssh_path(name), 'id_rsa')
	end

	def public_key(name)
		File.join(user_ssh_path(name), 'id_rsa.pub')
	end
end

ChangeGitUser.(silent: ARGV[0])
