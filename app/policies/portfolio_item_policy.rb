class PortfolioItemPolicy < ApplicationPolicy
  def index?
    rbac_access.permission_check('read', Portfolio)
  end

  def create?
    portfolio_id = @record.class == Portfolio ? @record.id : @record.portfolio_id
    rbac_access.resource_check('update', portfolio_id, Portfolio)
  end

  def update?
    rbac_access.resource_check('update', @record.portfolio_id, Portfolio)
  end

  def destroy?
    rbac_access.resource_check('update', @record.portfolio_id, Portfolio)
  end

  def copy?
    destination_id = @user.try(:params).try(:dig, :portfolio_id) || @record.portfolio_id

    if destination_id == @record.portfolio_id
      can_read_and_update_destination?(destination_id)
    else
      rbac_access.resource_check('read', @record.portfolio_id, Portfolio) &&
        can_read_and_update_destination?(destination_id)
    end
  end

  private

  def can_read_and_update_destination?(destination_id)
    rbac_access.resource_check('read', destination_id, Portfolio) &&
      rbac_access.resource_check('update', destination_id, Portfolio)
  end

  class Scope < Scope
    def resolve
      scopes = user.catalog_access.scopes(Portfolio, 'read')
      if scopes.include?('admin')
        scope.all
      elsif scopes.include?('group')
        ids = Catalog::RBAC::AccessControlEntries.new.ace_ids('read', Portfolio)
        scope.where(:portfolio_id => ids)
      end
    end
  end
end
