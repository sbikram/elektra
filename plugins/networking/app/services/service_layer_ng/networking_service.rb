# frozen_string_literal: true

module ServiceLayerNg
  # Implements Openstack Neutron API
  class NetworkingService < Core::ServiceLayerNg::Service
    include NetworkingServices::Network
    include NetworkingServices::Subnet
    include NetworkingServices::Port
    include NetworkingServices::FloatingIp
    include NetworkingServices::SecurityGroup
    include NetworkingServices::SecurityGroupRule
    include NetworkingServices::Router
    include NetworkingServices::Rbac
    include NetworkingServices::Quota
    include NetworkingServices::DhcpAgent

    def available?(_action_name_sym = nil)
      elektron.service?('network')
    end

    def elektron_networking
      @elektron_networking ||= elektron.service(
        'network', path_prefix: '/v2.0'
      )
    end
  end
end
