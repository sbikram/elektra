module SharedFilesystemStorage
  module Shares
    class RulesController < ApplicationController
      
      def index
        render json: services.shared_filesystem_storage.share_rules(params[:share_id])
      end
      
      def create
        rule = services.shared_filesystem_storage.new_share_rule(params[:share_id],rule_params)

        if rule.save
          rule.permissions = {
            delete: current_user.is_allowed?("shared_filesystem_storage:rule_delete"), 
            update: current_user.is_allowed?("shared_filesystem_storage:rule_update")
          }
          render json: rule
        else
          render json: rule.errors, status: :unprocessable_entity
        end
      end
      
      def destroy
        rule = services.shared_filesystem_storage.new_share_rule(params[:share_id])
        rule.id=params[:id]
      
        if rule.destroy
          head :no_content
        else
          render json: rule.errors, status: :unprocessable_entity
        end
      end
      
      protected
      def rule_params
        params.require(:rule).permit(:access_type,:access_level,:access_to)
      end
      
    end
  end
end