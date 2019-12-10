module Catalog
  class ShareInfo
    require 'rbac-api-client'
    attr_reader :result

    def initialize(options)
      @object = options[:object]
    end

    def process
      group_permissions = {}
      @object.access_control_entries.each do |ace|
        group_permissions[ace.group_uuid] = group_permissions.fetch(ace.group_uuid, []) << ace.permission
      end
      @result = group_permissions.each_with_object([]) do |(k, v), memo|
        memo << { :group_name => group_names[k], :group_uuid => k, :permissions => v }
      end
      self
    end

    private

    def group_names
      @group_names ||= Insights::API::Common::RBAC::Service.call(RBACApiClient::GroupApi) do |api|
        Insights::API::Common::RBAC::Service.paginate(api, :list_groups, {}).each_with_object({}) do |group, memo|
          memo[group.uuid] = group.name
        end
      end
    end
  end
end
