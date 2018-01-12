module Compute
  class ServicesController < Compute::ApplicationController
    authorization_context 'compute'
    authorization_required

    def index
      compute_services = services.compute.services(binary: 'nova-compute')
      @compute_services = compute_services.sort_by(&:zone) if compute_services
    end

    def enable
      host = params['id']
      services.compute.enable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def disable
      host = params['id']
      services.compute.disable_service(host, 'nova-compute')
      redirect_to services_url
    end

    def edit
      @service = Compute::Service.new(nil, id: params['id'], reason: params['reason'])
    end

    def update
      host = params['id']
      reason = params['service']['reason']
      if services.compute.disable_service_reason(host, 'nova-compute', reason)
        redirect_to services_url
      else
        render :edit
      end
    end
  end
end
