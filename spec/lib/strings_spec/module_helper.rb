class PuppetModuleHelper
# Helper methods to handle file operations around generating and loading HTML
  def self.using_module(path, modulename, &block)
    Dir.mktmpdir do |tmp|
      module_location = File.join(path, "examples", modulename)
      FileUtils.cp_r(module_location, tmp)
      old_dir = Dir.pwd
      begin
        Dir.chdir(tmp)
        yield(tmp)
      ensure
        Dir.chdir(old_dir)
      end
    end
  end

  def self.read_html(dir, modulename, file)
    File.read(File.join(dir, modulename, 'doc', file))
  end
end
