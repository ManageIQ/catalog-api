module Catalog
  module RBAC
    class Access
      def initialize(user)
        @user = user
      end

      def update_access_check
        resource_check('update')
      end

      def read_access_check
        resource_check('read')
      end

      def create_access_check
        permission_check('create')
      end

      def destroy_access_check
        resource_check('delete')
      end

      def resource_check(verb, id = @user.params[:id], klass = @user.controller_name.classify.constantize)
        return unless Insights::API::Common::RBAC::Access.enabled?
        return if Catalog::RBAC::Role.catalog_administrator?

        ids = access_id_list(verb, klass)
        if klass.try(:supports_access_control?)
          raise Catalog::NotAuthorized, "#{verb.titleize} access not authorized for #{klass}" if ids.exclude?(id.to_s)
        end
      end

      def permission_check(verb, klass = @user.controller_name.classify.constantize)
        return unless Insights::API::Common::RBAC::Access.enabled?

        unless access_object(klass.table_name, verb).accessible?
          raise Catalog::NotAuthorized, "#{verb.titleize} access not authorized for #{klass}"
        end
      end

      private

      def access_id_list(verb, klass)
        unless access_object(@user.controller_name.classify.constantize.table_name, verb).accessible?
          raise Catalog::NotAuthorized, "#{verb.titleize} access not authorized for #{klass}"
        end

        Catalog::RBAC::AccessControlEntries.new.ace_ids(verb, klass)
      end

      def access_object(table_name, verb)
        Insights::API::Common::RBAC::Access.new(table_name, verb).process
      end
    end
  end
end
