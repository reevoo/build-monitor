module DataRepository
  extend self

  def save(name, data)
    file = Tempfile.new(name)
    file.write(data)
    file.close
    FileUtils.mv(file.path, "#{data_dir}/#{name}.json")
  end

  def read(name)
    File.read("#{data_dir}/#{name}.json")
  end

  def data_dir
    "config/data"
  end
end
