# frozen_string_literal: true

module DnsService
  # Presents the zone model
  class Zone < Core::ServiceLayer::Model
    validates :name, presence: { message: 'Please provide the domain name' },
                     on: :create
    validates :email, presence: { message: 'Please provide an email' }

    def attributes_for_create
      zone_attributes = {}
      zone_attributes[:ttl] = read('ttl').to_i if read('ttl')
      zone_attributes[:name] = read('name').strip if read('name')
      zone_attributes[:email] = read('email').strip if read('email')
      zone_attributes[:description] = read('description')
      zone_attributes[:attributes] = (read('attributes') || {}).keep_if do |k, _v|
        %w[external label].include?(k)
      end

      zone_attributes.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      zone_attributes = attributes_for_create
      if read('project_id')
        zone_attributes[:project_id] = read('project_id').strip
      end
      zone_attributes.delete(:name)
      zone_attributes.delete_if { |_k, v| v.blank? }
    end
  end
end
