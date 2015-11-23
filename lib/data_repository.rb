module DataRepository
  extend self

  def save(name, data)
    file = Tempfile.new(name)
    file.write(data)
    file.close
    FileUtils.mv(file.path, "#{data_dir}/#{name}.json")
  end

  def read(name)
    File.open("#{data_dir}/#{name}.json", "r:utf-8", &:read)
  end

  def data_dir
    "config/data"
  end
end
