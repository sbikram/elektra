# frozen_string_literal: true

module Networking
  module CloudAdmin
    # Implements Network actions
    class NetworkUsageStatsController < DashboardController
      authorization_required context: '::networking'

      def index
        @domain, @project = services.identity.find_domain_and_project(
          params.permit(:domain, :project)
        )

        @projects = if @project
                      [@project]
                    elsif @domain
                      services.identity.projects(domain_id: @domain.id)
                    end
        return if @projects.blank?

        @projects_quotas = load_projects_quotas
        @projects_networks = load_projects_networks
        @networks = load_networks
        @networks_usage = load_networks_usage

        @projects_networks.each do |project_id, network_ids|
          next unless @projects_quotas[project_id]
          network_ids.each do |network_id|
            next unless @networks_usage[network_id]
            @networks_usage[network_id].floatingip_total_quota ||= 0
            @networks_usage[network_id].floatingip_total_quota +=
              @projects_quotas[project_id].floatingip
          end
        end

        # byebug
      end

      protected

      def load_projects_networks(project_id = nil)
        options = { object_type: 'network' }
        options[:target_tenant] = project_id if project_id
        services.networking.rbacs(options)
                   .each_with_object({}) do |rbac, rbacs|
                     rbacs[rbac.target_tenant] ||= []
                     rbacs[rbac.target_tenant] << rbac.read('object_id')
                   end
      end

      def load_networks
        #options = 'fields=tenant_id&fields=name&fields=id'
        options = 'router:external=true&fields=tenant_id&fields=name&fields=id'
        services.networking.networks(options)
                   .each_with_object({}) { |n, networks| networks[n.id] = n }
      end

      def load_networks_usage(network_id = nil)
        if network_id
          { network_id => services.networking.network_ip_availability(id) }
        else
          services.networking.network_ip_availabilities
                     .each_with_object({}) do |availability, usage|
                       usage[availability.network_id] = availability
                     end
        end
      end

      def load_projects_quotas(projects = nil)
        if projects && projects.length == 1
          quota = services.networking.project_quotas(projects.first.id)
          { projects.first.id => quota }
        else
          quotas = services.networking.quotas.each_with_object({}) do |quota, quotas|
            quotas[quota.project_id || quota.tenant_id] = quota
          end
          # # projects with default quotas are not contained in quotas.
          # # load missing quotas
          # projects.each do |project|
          #   unless quotas[project.id]
          #     quotas[project.id] = services.networking
          #                                     .project_quotas(project.id)
          #   end
          # end
          # quotas
        end
      end
    end
  end
end
