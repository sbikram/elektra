# frozen_string_literal: true
module ViewHelper
  def project_name(id)
    # try to find project in friendly ids
    remote_project = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
      'Project', @scoped_domain_id, id
    )
    # project not found in friendly ids -> load from api
    remote_project ||= service_user.identity.find_project_by_name_or_id(
      @scoped_domain_id, id
    )
    remote_project ||= services.identity.find_project(id)
    # projects where the service user does not have permissions
    # or deleted projects get 'N/A'
    remote_project ? remote_project.name : ''
  end

  def project_id_and_name(project)
    if project
      # try to find project in friendly ids
      remote_project = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
        'Project', @scoped_domain_id, project
      )
      # project not found in friendly ids -> load from api
      remote_project ||= service_user.identity.find_project_by_name_or_id(
        @scoped_domain_id, project
      )
      remote_project ||= services.identity.find_project(project)
      # projects where the service user does not have permissions or
      # deleted projects get 'N/A'
      project_name = remote_project ? remote_project.name : ''

      if current_user.is_allowed?('lookup:os_object_show_project')
        project_name ||= project
        return haml_concat(
          link_to(project_name, plugin('lookup').projects_path(query: project))
        )
      end

      # "#{project} (#{project_name})"
      unless project_name.blank?
        haml_concat project_name.to_s
        haml_tag :br
      end
      haml_tag :span, class: 'info-text' do
        haml_concat project.to_s
      end
    else
      haml_concat 'N/A'
    end
  end

  def domain_id_and_name(domain)
    if domain
      # try to find domain in friendly ids
      remote_domain = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
        'Domain', nil, domain
      )
      remote_domain ||= service_user.identity.find_domain(domain)
      # domains where the service user does not have permissions or
      # deleted domains get 'N/A'
      domain_name = remote_domain ? remote_domain.name : ''
      # "#{domain} (#{domain_name})"
      unless domain_name.blank?
        haml_concat domain_name.to_s
        haml_tag :br
      end
      haml_tag :span, class: 'info-text' do
        haml_concat domain.to_s
      end
    else
      haml_concat 'N/A'
    end
  end

  def render_available_regions
    # read regions config, select only available regions
    regs = ::Core::StaticConfig.regions
    available_regions = regs.blank? ? Array.new : regs.select{ |dc| dc['available']}
    base_url = request.base_url
    domain_path = request.path.split('/')[1] # get domain from path

    # render list with available regions
    unless available_regions.blank?
      capture_haml do
        haml_tag :ul, class: 'dropdown-menu', role: 'menu' do
          available_regions.each do |region|
            class_name = current_region == region['regionkey'] ? 'active' : ''
            haml_tag :li, class: class_name do
              # for now use only the base url for the link (i.e. no domain,
              # no project path since those might not exist in the new region)
              region_url = "#{base_url.sub(current_region, region["regionkey"])}/#{domain_path}"
              haml_tag :a, href: region_url do
                haml_concat region['regionname']
              end
            end
          end
        end
      end
    end
  end
end
