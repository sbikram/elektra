# frozen_string_literal: true

module Image
  class Image < Core::ServiceLayer::Model
    def publish
      rescue_api_errors do
        self.attributes = service.publish_image(id)
      end
    end

    def unpublish
      rescue_api_errors do
        self.attributes = service.unpublish_image(id)
      end
    end

    # returns member
    def add_member(member)
      rescue_api_errors do
        return service.add_member_to_image(id, member.member_id)
      end
    end

    # returns true
    def remove_member(member)
      rescue_api_errors do
        service.remove_member_from_image(id, member.member_id)
      end
    end
  end
end
