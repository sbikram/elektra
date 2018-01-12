# frozen_string_literal: true

module ServiceLayer
  # Implements Openstack Neutron API
  class NetworkingService < Core::ServiceLayer::Service
    include NetworkingServices::Network
    include NetworkingServices::Subnet
    include NetworkingServices::Port
    include NetworkingServices::FloatingIp
    include NetworkingServices::SecurityGroup
    include NetworkingServices::SecurityGroupRule
    include NetworkingServices::Router
    include NetworkingServices::Rbac
    include NetworkingServices::Quota

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('network', region)
    end
  end
end
