module DnsService
  class CreateZoneWizardController < ::DashboardController
    before_action :load_inquiry

    def new
      @zone_request = ::DnsService::ZoneRequest.new(nil)

      return if @inquiry.nil?
      payload = @inquiry.payload
      @zone_request.attributes = payload
      @pool = load_pool(@zone_request.domain_pool)
    end

    def create
      @zone_request = ::DnsService::ZoneRequest.new(nil, params[:zone_request])
      @zone = services.dns_service.new_zone(@zone_request.attributes)
      @zone.name = @zone_request.zone_name
      @pool = load_pool(@zone_request.domain_pool)
      @zone.write('attributes', @pool.read('attributes'))

      if @zone.save
        @zone_transfer_request = services.dns_service.new_zone_transfer_request(
          @zone.id, target_project_id: @inquiry.project_id
        )
        if @zone_transfer_request.save
          @zone_transfer_request.accept(@inquiry.project_id)
          if @inquiry
            services.inquiry.set_inquiry_state(@inquiry.id, :approved, "Domain #{@zone.name} approved and created by #{current_user.full_name}")
          end
        else
          @zone_transfer_request.errors.each { |k, m| @zone_request.errors.add(k,m) }
        end
      else
        @zone.errors.each{|k,m| @zone_request.errors.add(k,m)}
      end

      if @zone_request.errors.empty?
        render action: :create
      else
        render action: :new
      end
    end

    protected
    def load_inquiry
      return if params[:inquiry_id].blank?
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])
    end

    def load_pool(pool_id)
      cloud_admin.dns_service.find_pool(pool_id)
    end
  end
end
