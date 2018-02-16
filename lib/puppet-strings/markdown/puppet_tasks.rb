require_relative 'puppet_task'

module PuppetStrings::Markdown
  module PuppetTasks

    # @return [Array] list of classes
    def self.in_tasks
      arr = YARD::Registry.all(:puppet_task).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::PuppetTask.new(a) }
    end

    def self.contains_private?
      false
    end

    def self.render
      final = in_tasks.length > 0 ? "## Tasks\n\n" : ""
      in_tasks.each do |task|
        final << task.render unless task.private?
      end
      final
    end

    def self.toc_info
      final = ["Tasks"]

      in_tasks.each do |task|
        final.push(task.toc_info)
      end

      final
    end
  end
end
