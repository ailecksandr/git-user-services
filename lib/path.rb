class Path
  attr_reader :name

  def initialize(path)
    @path = path
    prepare!

    validate!

    @name = path.split('/').last
  end

  def to_str
    path
  end

  def to_s
    path
  end

  private

  attr_reader :path

  def prepare!
    @path.gsub!(/^~\//, "#{ENV['HOME']}/")
  end

  def validate!
    raise 'Path not exist' unless Dir.exist?(path) || File.exist?(path)
  end
end
