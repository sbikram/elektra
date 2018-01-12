# frozen_string_literal: true

module Networking
  class NetworkWizardController < DashboardController
    before_action :find_floatingip_network, :load_rbacs

    def new
      @network_wizard = services.networking.new_network_wizard(
        setup_options: ['advanced'], setup_option: 'advanced'
      )
      if @floatingip_network
        @network_wizard.floatingip_network_name = @floatingip_network.name
        # if @rbacs and @rbacs.length>0
        #   @network_wizard.setup_options = ["simple"]
        #   @network_wizard.setup_option = "simple"
        # end
      else
        @network_wizard.errors.add(
          :floatingip_network, 'Could not find FloatingIP-Network'
        )
      end
    end

    def create
      @network_wizard = services.networking.new_network_wizard(
        params[:network_wizard]
      )

      if @floatingip_network
        @network_wizard.floatingip_network_name = @floatingip_network.name

        if @rbacs.nil? || @rbacs.length.zero?
          rbac = cloaud_admin_networking.new_rbac(
            object_id: @floatingip_network.id, object_type: 'network',
            action: 'access_as_shared', target_tenant: @scoped_project_id
          )
          unless rbac.save
            rbac.errors.each do |name, message|
              @network_wizard.errors.add(name, message)
            end
          end
        end
        # if @network_wizard.setup_option == 'simple'
        #
        # end
      else
        @network_wizard.errors.add(:floatingip_network,
                                   'Could not find FloatingIP-Network')
      end

      if @network_wizard.errors.empty?
        render action: :create
      else
        render action: :new
      end
    end

    protected

    def cloaud_admin_networking
      @cloaud_admin_networking ||= cloud_admin.networking
    end

    def find_floatingip_network
      @floatingip_network = cloaud_admin_networking.domain_floatingip_network(
        @scoped_domain_name
      )
    end

    def load_rbacs
      return unless @floatingip_network
      @rbacs = cloaud_admin_networking.rbacs(
        object_id: @floatingip_network.id,
        object_type: 'network',
        target_tenant: @scoped_project_id
      )
    end
  end
end
