describe 'Metrics' do
  let(:header) do
    %w[
      tenant
      portfolio_count
      product_count
      portfolio_share_count
    ].collect(&:titleize)
  end

  let(:tenant) do
    create(
      :tenant,
      :name            => 'tenant_portfolio_shared_context',
      :external_tenant => 'external_tenant_portfolio_shared'
    )
  end

  def create_portfolio
    portfolio = create(:portfolio)
    create(:access_control_entry, :aceable => portfolio)
    portfolio.update_metadata
  end

  def create_shared_portfolio
    portfolio = create(:portfolio)
    create(
      :access_control_entry,
      :has_read_and_update_permission,
      :aceable => portfolio
    )
    portfolio.update_metadata
  end

  def create_portfolio_for_tenant
    ActsAsTenant.with_tenant(tenant) { create_portfolio }
  end

  def create_shared_portfolio_for_tenant
    ActsAsTenant.with_tenant(tenant) { create_shared_portfolio }
  end

  describe '`.portfolio_count`' do
    before do
      create(:portfolio)
    end

    it 'returns metric' do
      expect(TaskHelpers::Metrics.portfolio_count).to eq(1)
    end
  end

  describe '`.number_of_products`' do
    before do
      create(:portfolio_item)
    end

    it 'returns metric' do
      expect(TaskHelpers::Metrics.product_count).to eq(1)
    end
  end

  describe '`.portfolio_share_count`' do
    before do
      create_portfolio
      create_shared_portfolio
    end

    it 'returns metrics' do
      expect(TaskHelpers::Metrics.portfolio_share_count).to eq(1)
    end
  end

  describe '`.per_tenant`' do
    context '#without_data' do
      it 'returns only header' do
        expect(TaskHelpers::Metrics.per_tenant).to eq([header])
      end
    end

    context '#with_data' do
      let(:expected_result) do
        [
          header,
          [Tenant.first.external_tenant, 2, 0, 1],
          [tenant.external_tenant, 3, 0, 2]
        ]
      end

      before do
        create_portfolio
        create_portfolio_for_tenant
        create_shared_portfolio
        create_shared_portfolio_for_tenant
        create_shared_portfolio_for_tenant
      end

      context '#with_full_tenants' do
        it 'returns metrics' do
          expect(TaskHelpers::Metrics.per_tenant).to eq(expected_result)
        end
      end

      context '#with_empty_tenants' do
        before do
          create(:tenant, :external_tenant => 'empty_tenant')
        end

        it 'filters out tenants with no data' do
          expect(Tenant.count).to eq(3)
          expect(TaskHelpers::Metrics.per_tenant).to eq(expected_result)
        end
      end
    end
  end
end
