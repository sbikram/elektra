# frozen_String_literal: true

module SharedFilesystemStorage
  # share networks
  class ShareNetworksController < ApplicationController
    def index
      render json: services.shared_filesystem_storage.share_networks_detail
    end

    def update
      share_network = services.shared_filesystem_storage
                                 .new_share_network(share_network_params)
      share_network.id = params[:id]

      if share_network.save
        render json: share_network
      else
        render json: { errors: share_network.errors }
      end
    end

    def networks
      render json: services.networking.networks('router:external' => false)
    end

    def subnets
      render json: services.networking.subnets(
        network_id: params[:network_id]
      )
    end

    def create
      share_network = services.shared_filesystem_storage
                                 .new_share_network(share_network_params)

      if share_network.save
        if params[:share_network][:cidr]
          share_network.cidr = params[:share_network][:cidr]
        end
        render json: share_network
      else
        render json: { errors: share_network.errors }
      end
    end

    def destroy
      share_network = services.shared_filesystem_storage.new_share_network
      share_network.id = params[:id]

      if share_network.destroy
        head :no_content
      else
        render json: { errors: share_network.errors }
      end
    end

    protected

    def share_network_params
      params.require(:share_network)
            .permit(:name, :description, :neutron_net_id, :neutron_subnet_id)
    end
  end
end
