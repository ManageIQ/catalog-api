describe Catalog::ImportServicePlans, :type => [:service, :topology, :current_forwardable] do
  let(:service_offering_ref) { "1" }
  let(:portfolio_item) { create(:portfolio_item, :service_offering_ref => service_offering_ref) }
  let(:subject) { described_class.new(portfolio_item.id) }
  let(:service_plan) do
    TopologicalInventoryApiClient::ServicePlan.new(
      :name               => "The Plan",
      :id                 => "1",
      :description        => "A Service Plan",
      :create_json_schema => {"schema" => {}}
    )
  end
  let(:service_plan_response) { TopologicalInventoryApiClient::ServicePlansCollection.new(:data => data) }
  let(:service_offering_response) do
    TopologicalInventoryApiClient::ServiceOffering.new(:extra => {"survey_enabled" => true})
  end

  before do
    stub_request(:get, topological_url("service_offerings/1"))
      .to_return(:status => 200, :body => service_offering_response.to_json, :headers => default_headers)
    stub_request(:get, topological_url("service_offerings/1/service_plans"))
      .to_return(:status => 200, :body => service_plan_response.to_json, :headers => default_headers)
  end

  describe "#process" do
    context "when there is one plan" do
      let(:data) { [service_plan] }

      before do
        subject.process
      end

      it "reaches out to topology twice" do
        expect(a_request(:get, /topological-inventory\/v2.0\/service_offerings/)).to have_been_made.twice
      end

      it "adds the ServicePlan to the portfolio_item" do
        expect(portfolio_item.service_plans.count).to eq 1
      end
    end

    context "when there are multiple plans" do
      let(:data) { [service_plan, service_plan.dup] }

      before do
        subject.process
      end

      it "reaches out to topology twice" do
        expect(a_request(:get, /topological-inventory\/v2.0\/service_offerings/)).to have_been_made.twice
      end

      it "adds both the ServicePlans to the portfolio_item" do
        expect(portfolio_item.service_plans.count).to eq 2
      end
    end
  end
end
