module Catalog
  class ServiceOffering
    attr_reader :archived
    attr_reader :order

    def initialize(order_id)
      @order = Order.find_by!(:id => order_id)
      @service_offering_ref = service_offering_ref
    end

    def process
      service_offering = TopologicalInventory.call do |api|
        api.show_service_offering(@service_offering_ref)
      end

      @archived = service_offering.archived_at.present?

      self
    end

    private

    def service_offering_ref
      @order.order_items.first.portfolio_item.service_offering_ref.to_s
    end
  end
end
