# frozen_string_literal: true

module Networking
  # Implements FloatingIp actions
  class FloatingIpsController < DashboardController
    # set policy context
    authorization_context 'networking'
    # enforce permission checks. This will automatically
    # investigate the rule name.
    authorization_required

    def index
      per_page = params[:per_page] || 20
      @floating_ips = paginatable(per_page: per_page) do |pagination_options|
        services.networking.project_floating_ips(
          @scoped_project_id,
          pagination_options.merge(
            sort_key: [:floating_ip_address], sort_dir: [:desc]
          )
        )
      end
      @quota_data = []
      if current_user.is_allowed?("access_to_project")
        @quota_data = services.resource_management.quota_data(
          current_user.domain_id || current_user.project_domain_id,
          current_user.project_id,
          [
            { service_type: :network, resource_name: :floating_ips,
              usage: @floating_ips.length }
          ]
        )
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { floating_ips: @floating_ips }
      else
        # comon case, render index page with layout
        render action: :index
      end
    end

    def show
      @floating_ip = services.networking.find_floating_ip(params[:id])
      @port = services.networking.find_port(@floating_ip.port_id)
      @network = services.networking.find_network(@floating_ip.floating_network_id)
    end

    def new
      @floating_networks = services.networking.networks(
        'router:external' => true
      )
      @floating_ip = services.networking.new_floating_ip
      return unless @floating_networks.length == 1
      @floating_ip.floating_network_id = @floating_networks.first.id
    end

    def create
      @floating_networks = services.networking.networks(
        'router:external' => true
      )
      @floating_ip = services.networking.new_floating_ip(params[:floating_ip])
      @floating_ip.tenant_id = @scoped_project_id

      if @floating_ip.save
        audit_logger.info(current_user, 'has created', @floating_ip)
        render action: :create
      else
        render action: :new
      end
    end

    def edit
      @floating_ip = services.networking.find_floating_ip(params[:id])
    end

    def update
      @floating_ip = services.networking.find_floating_ip(params[:id])
      # save existing port_id and fixed_ip_address, blame neutron API for needing that on no-op
      port_id = @floating_ip.attributes['port_id']
      fixed_ip_address = @floating_ip.attributes['fixed_ip_address']
      @floating_ip.attributes = params[:floating_ip]
      @floating_ip.port_id = port_id
      @floating_ip.fixed_ip_address = fixed_ip_address

      if @floating_ip.save
        respond_to do |format|
          format.html { redirect_to floating_ips_url }
          format.js { render 'update.js' }
        end
      else
        render action: :edit
      end
    end

    def destroy
      @floating_ip = services.networking.new_floating_ip
      @floating_ip.id = params[:id]

      if @floating_ip.destroy
        @deleted = true
        audit_logger.info(current_user, 'has deleted floating ip', params[:id])
        flash.now[:notice] = 'Floating IP deleted!'
      else
        @deleted = false
        flash.now[:error] = 'Could not delete floating IP.'
      end
    end
  end
end
