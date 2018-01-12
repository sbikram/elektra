# frozen_string_literal: true

module ServiceLayer
  class ResourceManagementService < Core::ServiceLayer::Service
    def available?(_action_name_sym = nil)
      elektron.service?('limes')
    end

    def elektron_limes
      @elektron_limes ||= elektron.service(
        'limes', path_prefix: '/v1', interface: 'public'
      )
    end

    def cluster_map
      @cluster_map ||= class_map_proc(ResourceManagement::Cluster)
    end

    def domain_map
      @domain_map ||= class_map_proc(ResourceManagement::Domain)
    end

    ############################################################################
    # cloud-admin level

    def find_current_cluster(query = {})
      elektron_limes.get('clusters/current', query)
                    .map_to('body.cluster', &cluster_map)
    end

    def list_clusters(query = {})
      # Returns a pair of cluster list and ID of current cluster.
      # .map_to() does not work here because the toplevel JSON object contains
      # multiple keys ("clusters" and "current_cluster"), so instantiate the
      # models manually.
      response = elektron_limes.get('clusters', query)
      [
        response.map_to('body.clusters', &cluster_map),
        response.body['current_cluster']
      ]
    end

    def put_cluster_data(services)
      elektron_limes.put('clusters/current') do
        { cluster: { services: services } }
      end
    end

    ############################################################################
    # domain-admin level

    def find_domain(id, query = {})
      elektron_limes.get("domains/#{id}", query)
                    .map_to('body.domain', &domain_map)
    end

    def list_domains(query = {})
      elektron_limes.get('domains', query)
                    .map_to('body.domains', &domain_map)
    end

    def put_domain_data(domain_id, services)
      elektron_limes.put("domains/#{domain_id}") do
        { domain: { services: services } }
      end
    end

    def discover_projects(domain_id)
      elektron_limes.post("domains/#{domain_id}/projects/discover")
    end

    ############################################################################
    # project-admin level

    def find_project(domain_id, project_id, query = {})
      # give the domain_id to enrich the Project object with domain_id
      elektron_limes.get("domains/#{domain_id}/projects/#{project_id}", query)
                    .map_to('body.project') do |data|
        ResourceManagement::Project.new(self, data.merge(domain_id: domain_id))
      end
    end

    def has_project_quotas?(domain_id, project_id, project_domain_id = nil)
      project = find_project(
        domain_id || project_domain_id,
        project_id,
        service:  %w[compute network object-store],
        resource: %w[instances ram cores networks capacity]
      )
      # return true if approved_quota of the resource networking:networks
      # is greater than 0 OR
      # return true if the sum of approved_quota of the resources
      # compute:instances, compute:ram, compute:cores and
      # object_storage:capacity is greater than 0
      project.resources.any? { |r| r.quota.positive? }
    end

    def list_projects(domain_id, query = {})
      # give the domain_id to enrich the Project object with domain_id
      elektron_limes.get("domains/#{domain_id}/projects", query).map_to(
        'body.projects'
      ) do |data|
        ResourceManagement::Project.new(self, data.merge(domain_id: domain_id))
      end
    end

    def sync_project_asynchronously(domain_id, project_id)
      elektron_limes.post("domains/#{domain_id}/projects/#{project_id}/sync")
    end

    def put_project_data(domain_id, project_id, services)
      elektron_limes.put("domains/#{domain_id}/projects/#{project_id}") do
        { project: { services: services } }
      end
    end

    def quota_data(domain_id,project_id,options=[])
      return [] if options.empty?

      project = find_project(
        domain_id,
        project_id,
        service: options.collect { |values| values[:service_type] },
        resource: options.collect { |values| values[:resource_name] }
      )

      options.each_with_object([]) do |values, result|
        service = project.services.find do |srv|
          srv.type == values[:service_type].to_sym
        end
        next if service.nil?
        resource = service.resources.find do |res|
          res.name == values[:resource_name].to_sym
        end
        next if resource.nil?

        if values[:usage] && values[:usage].is_a?(Integer)
          resource.usage = values[:usage]
        end

        result << resource
      end
    rescue => e
      Rails.logger.error "Error trying to get quota data for project: #{project_id}. Error: #{e}"
      []
    end
  end
end
