# frozen_string_literal: true

module ServiceLayer
  module IdentityServices
    # This module implements Openstack Credential API
    module OsCredential
      def new_credential(attributes = {})
        map_to(Identity::OsCredential, attributes)
      end

      def find_credential(id = nil)
        return nil if id.blank?
        api.identity.show_credential_details(id).map_to(Identity::OsCredential)
      end

      def credentials(filter = {})
        @user_credentials ||= api.identity.list_credentials(filter)
                                 .map_to(Identity::OsCredential)
      end
    end
  end
end
