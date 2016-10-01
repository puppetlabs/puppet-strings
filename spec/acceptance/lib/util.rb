module PuppetStrings
  module Acceptance
    module Util
      def read_file_on(host, filename)
        on(host, "cat #{filename}").stdout
      end

      def get_test_module_path(host, module_regex)
        modules = JSON.parse(on(host, puppet('module', 'list', '--render-as', 'json')).stdout)
        test_module_info = modules['modules_by_path'].values.flatten.find { |mod_info| mod_info =~ module_regex }
        test_module_info.match(/\(([^)]*)\)/)[1]
      end
    end
  end
end
