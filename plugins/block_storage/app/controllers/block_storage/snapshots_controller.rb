require_dependency "block_storage/application_controller"

module BlockStorage
  class SnapshotsController < ApplicationController
    before_action :set_snapshot, except: [:index]

    authorization_context 'block_storage'
    authorization_required

    # GET /snapshots
    def index
      if @scoped_project_id
        @snapshots = paginatable(per_page: (params[:per_page] || 20)) do |pagination_options|
          services.block_storage.snapshots(pagination_options)
        end

        @quota_data = []
        if current_user.is_allowed?("access_to_project")
          @quota_data = services.resource_management.quota_data(
            current_user.domain_id || current_user.project_domain_id,
            current_user.project_id,[
            {service_type: :volumev2, resource_name: :snapshots, usage: @snapshots.length},
            {service_type: :volumev2, resource_name: :capacity}
          ])
        end

        # this is relevant in case an ajax paginate call is made.
        # in this case we don't render the layout, only the list!
        if request.xhr?
          render partial: 'list', locals: {snapshots: @snapshots}
        else
          # comon case, render index page with layout
          render action: :index
        end
      end
    end

    # GET /snapshots/1
    def show
    end

    # GET /snapshots/1/edit
    def edit
    end

    # PATCH/PUT /snapshots/1
    def update
      if @snapshot.update(snapshot_params)
        audit_logger.info(current_user, 'has updated', @snapshot)
        redirect_to @snapshot, notice: 'Snapshot was successfully updated.'
      else
        @snapshot.errors[:base]
        render :edit
      end
    end

    # DELETE /snapshots/1
    def destroy
      if @snapshot.destroy
        audit_logger.info(current_user, 'has deleted', @snapshot)
      else
        flash.now[:error] = 'Error during Snapshot deletion!'
      end
      redirect_to snapshots_url, notice: 'Snapshot was successfully deleted.'
    end

    def create_volume
      @volume = services.block_storage_.new_volume
      @volume.name = 'vol-' + @snapshot.name
      @volume.description = @snapshot.description
      @volume.size = @snapshot.size
      @volume.snapshot_id = @snapshot.id
      render 'block_storage/volumes/new.html'
    end


    def new_status
    end

    def reset_status
      @snapshot.reset_status(params[:snapshot][:status])
      # reload snapshot
      @snapshot = services.block_storage.find_snapshot(params[:id])
      if @snapshot.status == params[:snapshot][:status]
        audit_logger.info(current_user, 'has reset', @snapshot)
        render template: 'block_storage/snapshots/reset_status.js'
      else
        render action: :new_status
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_snapshot
      @snapshot = services.block_storage.find_snapshot(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def snapshot_params
      params[:snapshot]
    end
  end
end
