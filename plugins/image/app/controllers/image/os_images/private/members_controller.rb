# frozen_string_literal: true

module Image
  module OsImages
    module Private
      # Implements Image members
      class MembersController < ::Image::ApplicationController
        def index
          @image = services.image.find_image(params[:private_id])
          @members = services.image.members(params[:private_id])
        end

        def create
          @image = services.image.find_image(params[:private_id])
          @member = services.image.new_member(params[:member])

          @project = service_user.identity.find_project_by_name_or_id(
            @scoped_domain_id, @member.member_id
          )

          if @project.nil?
            @error = "Could not find project #{@member.member_id}"
          else
            @member.member_id = @project.id
            @member = @image.add_member(@member)
          end
        end

        def destroy
          image = services.image.new_image
          image.id = params[:private_id]
          member = services.image.new_member
          member.member_id = params[:id]

          @success = image.remove_member(member)
        end
      end
    end
  end
end
