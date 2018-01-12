# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Subnet
    module Subnet
      def find_subnet!(id)
        return nil unless id
        api.networking.show_subnet_details(id).map_to(Networking::Subnet)
      end

      def find_subnet(id)
        find_subnet!(id)
      rescue
        nil
      end

      def new_subnet(attributes = {})
        map_to(Networking::Subnet, attributes)
      end

      def subnets(filter = {})
        api.networking.list_subnets(filter).map_to(Networking::Subnet)
      end

      def cached_network_subnets(network_id)
        subnets_data = Rails.cache.fetch(
          "network_#{network_id}_subnets", expires_in: 1.hours
        ) do
          api.networking.list_subnets(network_id: network_id).data
        end || []
        subnets_data.collect { |attrs| map_to(Networking::Subnet, attrs) }
      end

      def cached_subnet(id)
        subnet_data = Rails.cache.fetch("subnet_#{id}", expires_in: 2.hours) do
          begin
            api.networking.show_subnet_details(id).data
          rescue => e
            nil
          end
        end
        return nil unless subnet_data
        map_to(Networking::Subnet, subnet_data || [])
      end

      #################### Model Interface #################
      def create_subnet(attributes)
        api.networking.create_subnet(subnet: attributes).data
      end

      def update_subnet(id, attributes)
        api.networking.update_subnet(id, subnet: attributes).data
      end

      def delete_subnet(id)
        api.networking.delete_subnet(id)
      end
    end
  end
end
