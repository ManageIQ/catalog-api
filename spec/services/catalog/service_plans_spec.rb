describe Catalog::ServicePlans do
  let(:service_offering_ref) { "998" }
  let(:tenant) { create(:tenant) }
  let(:portfolio) { create(:portfolio, :tenant_id => tenant.id) }
  let(:portfolio_item) { create(:portfolio_item, :tenant_id => tenant.id, :portfolio => portfolio, :service_offering_ref => service_offering_ref) }
  let(:params) { portfolio_item.id }
  let(:service_plans) { described_class.new(params) }
  let(:api_instance) { double }
  let(:ti_class) { class_double("TopologicalInventory").as_stubbed_const(:transfer_nested_constants => true) }

  before do
    allow(ti_class).to receive(:call).and_yield(api_instance)
  end

  it "fetches the array of plans" do
    SvcPlan = Struct.new(:name, :id, :description, :create_json_schema)
    plan1 = SvcPlan.new("Plan A", "1", "Plan A", {})
    plan2 = SvcPlan.new("Plan B", "2", "Plan B", {})
    result = double('links' => {}, 'meta' => {}, 'data' => [plan1, plan2])
    expect(api_instance).to receive(:list_service_offering_service_plans).with(portfolio_item.service_offering_ref).and_return(result)

    expect(service_plans.process.items.count).to eq(2)
  end

  context "invalid portfolio item" do
    let(:params) { 1 }
    it "raises exception" do
      expect { service_plans.process }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
