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
		write!
	end

	private

	STATES    = [:initialized, :commented, :replaced]
	FIELDS    = [:name, :email]
	FILE_NAME = "#{ENV['HOME']}/.gitconfig"

	attr_reader :config, :silent, :left_border, :right_border, :field_states

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
			echo("## \"#{config[index].split('=').last.lstrip}\" is current user ##") if field == :name
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

	def echo(text)
		puts(text) unless silent	
	end
end

ChangeGitUser.()
