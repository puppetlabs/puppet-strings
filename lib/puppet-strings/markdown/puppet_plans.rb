require_relative 'puppet_plan'

module PuppetStrings::Markdown
  module PuppetPlans

    # @return [Array] list of classes
    def self.in_plans
      arr = YARD::Registry.all(:puppet_plan).sort_by!(&:name).map!(&:to_hash)
      arr.map! { |a| PuppetStrings::Markdown::PuppetPlan.new(a) }
    end

    def self.contains_private?
      result = false
      unless in_plans.nil?
        in_plans.find { |plan| plan.private? }.nil? ? false : true
      end
    end

    def self.render
      final = in_plans.length > 0 ? "## Plans\n\n" : ""
      in_plans.each do |plan|
        final << plan.render unless plan.private?
      end
      final
    end

    def self.toc_info
      final = ["Plans"]

      in_plans.each do |plan|
        final.push(plan.toc_info)
      end

      final
    end
  end
end
