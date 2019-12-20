module Catalog
  class SurveyCompare
    attr_reader :base
    class << self
      def changed?(plan)
        potential = new(plan)
        potential.topo_base != potential.base
      end
    end

    def initialize(plan)
      @base = plan.base.deep_stringify_keys
      @reference = plan.portfolio_item.service_offering_ref
    end

    def topo_base
      TopologicalInventory.call do |api_instance|
        survey = api_instance.list_service_offering_service_plans(@reference)
        survey.data.first.create_json_schema.deep_stringify_keys
      end
    end
  end
end
