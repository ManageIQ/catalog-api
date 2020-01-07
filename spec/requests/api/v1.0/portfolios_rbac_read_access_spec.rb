describe "v1.0 - Portfolios Read Access RBAC API", :type => [:request, :v1] do
  let!(:portfolio1) { create(:portfolio) }
  let!(:portfolio2) { create(:portfolio) }
  let(:access_obj) { instance_double(Insights::API::Common::RBAC::Access, :owner_scoped? => false, :accessible? => true) }
  let(:valid_attributes) { {:name => 'Fred', :description => "Fred's Portfolio" } }
  let(:block_access_obj) { instance_double(Insights::API::Common::RBAC::Access, :accessible? => false) }
  let(:graphql_query) { '{ portfolios { id name } }' }
  let(:graphql_body) { { 'query' => graphql_query } }
  let(:group1) { instance_double(RBACApiClient::GroupOut, :name => 'group1', :uuid => "123") }
  let(:rs_class) { class_double("Insights::API::Common::RBAC::Service").as_stubbed_const(:transfer_nested_constants => true) }
  let(:api_instance) { double }
  let(:list_group_options) { {:scope=>"principal"} }

  before do
    allow(rs_class).to receive(:call).with(RBACApiClient::GroupApi).and_yield(api_instance)
    allow(Insights::API::Common::RBAC::Service).to receive(:paginate).with(api_instance, :list_groups, list_group_options).and_return([group1])
  end

  describe "GET /portfolios" do
    context "no permission to read portfolios" do
      before do
        create(:access_control_entry, :group_uuid => group1.uuid, :permission => 'read', :aceable => portfolio2)
      end

      it "no access" do
        allow(Insights::API::Common::RBAC::Access).to receive(:new).with('portfolios', 'read').and_return(block_access_obj)
        allow(Insights::API::Common::RBAC::Roles).to receive(:assigned_role?).with(catalog_admin_role).and_return(false)

        allow(block_access_obj).to receive(:process).and_return(block_access_obj)
        get "#{api_version}/portfolios/#{portfolio1.id}", :headers => default_headers
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "Catalog User should not see any portfolios by default" do
      before do
        allow(Insights::API::Common::RBAC::Access).to receive(:new).with('portfolios', 'read').and_return(access_obj)
        allow(Insights::API::Common::RBAC::Roles).to receive(:assigned_role?).with(catalog_admin_role).and_return(false)
        allow(access_obj).to receive(:process).and_return(access_obj)
      end

      it "gets an empty list" do
        get "#{api_version}/portfolios", :headers => default_headers
        expect(response).to have_http_status(:ok)
        expect(json['meta']['count']).to be_zero
        expect(json['data']).to be_empty
      end
    end

    context "Catalog Administrator can see all" do
      before do
        allow(Insights::API::Common::RBAC::Roles).to receive(:assigned_role?).with(catalog_admin_role).and_return(true)
      end

      it 'specific portfolio' do
        get "#{api_version}/portfolios/#{portfolio1.id}", :headers => default_headers
        expect(response).to have_http_status(:ok)
      end

      it 'all portfolios' do
        get "#{api_version}/portfolios", :headers => default_headers
        expect(response).to have_http_status(:ok)
        expect(json['data'].collect { |x| x['id'] }).to match_array([portfolio1.id.to_s, portfolio2.id.to_s])
      end
    end

    context "permission to read specific portfolios" do
      before do
        allow(Insights::API::Common::RBAC::Access).to receive(:new).with('portfolios', 'read').and_return(access_obj)
        allow(Insights::API::Common::RBAC::Roles).to receive(:assigned_role?).with(catalog_admin_role).and_return(false)
        allow(rs_class).to receive(:call).with(RBACApiClient::GroupApi).and_yield(api_instance)
        allow(Insights::API::Common::RBAC::Service).to receive(:paginate).with(api_instance, :list_groups, list_group_options).and_return([group1])
        allow(access_obj).to receive(:process).and_return(access_obj)
        create(:access_control_entry, :group_uuid => group1.uuid, :permission => 'read', :aceable => portfolio1)
      end

      it 'ok' do
        get "#{api_version}/portfolios/#{portfolio1.id}", :headers => default_headers
        expect(response).to have_http_status(:ok)
      end

      it 'forbidden' do
        get "#{api_version}/portfolios/#{portfolio2.id}", :headers => default_headers
        expect(response).to have_http_status(:forbidden)
      end

      context "via graphql" do
        let(:graphql_query) { "{ portfolios(id: #{portfolio1.id}) { id name } }" }
        it 'ok' do
          post "#{api_version}/graphql", :headers => default_headers, :params => graphql_body
          expect(response).to have_http_status(:ok)
          expect(json['data']['portfolios'][0]['name']).to eq(portfolio1.name)
        end
      end

      context "via graphql fetch an inaccessible portfolio" do
        let(:graphql_query) { "{ portfolios(id: #{portfolio2.id}) { id name } }" }
        it 'gives an empty body' do
          post "#{api_version}/graphql", :headers => default_headers, :params => graphql_body
          expect(response).to have_http_status(:ok)
          expect(json['data']['portfolios']).to be_empty
        end
      end
    end
  end

  describe "POST /graphql" do
    context "no permission to read portfolios" do
      it "no access" do
        allow(Insights::API::Common::RBAC::Access).to receive(:new).with('portfolios', 'read').and_return(block_access_obj)
        allow(Insights::API::Common::RBAC::Roles).to receive(:assigned_role?).with(catalog_admin_role).and_return(false)
        allow(block_access_obj).to receive(:process).and_return(block_access_obj)
        post "#{api_version}/graphql", :headers => default_headers, :params => graphql_body
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
