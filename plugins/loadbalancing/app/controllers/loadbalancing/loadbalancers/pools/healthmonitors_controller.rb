# frozen_string_literal: true

module Loadbalancing
  module Loadbalancers
    module Pools
      class HealthmonitorsController < ApplicationController
        before_action :load_objects

        # set policy context
        authorization_context 'loadbalancing'
        # enforce permission checks. This will automatically investigate
        # the rule name.
        authorization_required except: []

        def new
          @healthmonitor = services_ng.loadbalancing.new_healthmonitor
          @healthmonitor.http_method = 'GET'
          @healthmonitor.expected_codes = '200'
          @healthmonitor.url_path = '/'
        end

        def create
          @healthmonitor = services_ng.loadbalancing.new_healthmonitor
          @healthmonitor.attributes = healthmonitor_params.delete_if do |_k, v|
            v.blank?
          end.merge(pool_id: params[:pool_id])

          if @healthmonitor.save
            audit_logger.info(current_user, 'has created', @healthmonitor)
            render template: 'loadbalancing/loadbalancers/pools/healthmonitors/update_item_with_close.js'
            #redirect_to show_details_pool_path(@pool.id), notice: 'Healthmonitor was successfully created.'
          else
            render :new
          end
        end

        def edit; end

        def update
          params[:healthmonitor][:type] = @healthmonitor.type
          if @healthmonitor.update(healthmonitor_params)
            audit_logger.info(current_user, 'has updated', @healthmonitor)
            render template: 'loadbalancing/loadbalancers/pools/healthmonitors/update_item_with_close.js'
          else
            @pool = services_ng.loadbalancing.find_pool(params[:pool_id])
            render :edit
          end
        end

        def destroy
          @healthmonitor.destroy
          audit_logger.info(current_user, 'has deleted', @healthmonitor)
          render template: 'loadbalancing/loadbalancers/pools/healthmonitors/destroy_item.js'
        end


        private

        def load_objects
          if params[:loadbalancer_id]
            @loadbalancer = services_ng.loadbalancing.find_loadbalancer(
              params[:loadbalancer_id]
            )
          end
          if params[:pool_id]
            @pool = services_ng.loadbalancing.find_pool(params[:pool_id])
          end
          if params[:id]
            @healthmonitor = services_ng.loadbalancing.find_healthmonitor(
              params[:id]
            )
          end
        end

        def healthmonitor_params
          hp = params[:healthmonitor].to_unsafe_hash.symbolize_keys if params[:healthmonitor]
          unless (hp[:type] == 'HTTP' || hp[:type] == 'HTTPS')
            hp.delete(:url_path)
            hp.delete(:http_method)
            hp.delete(:expected_codes)
          end
          hp
        end
      end
    end
  end
end
