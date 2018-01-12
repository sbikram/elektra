# frozen_string_literal: true

module DnsService
  # represents the openstack dns recordset
  class Recordset < Core::ServiceLayer::Model
    validate :is_cname

    TYPE_LABELS = {
      'A - Address record' => 'a',
      'AAAA - IPv6 address record' => 'aaaa',
      'CNAME - Canonical name record' => 'cname',
      'MX - Mail exchangerecord' => 'mx',
      'PTR - Pointer record' => 'ptr',
      'SPF - Sender Policy Framework' => 'spf',
      'SRV - Service locator' => 'srv',
      'SSHFP - SSH Public Key Fingerprint' => 'sshfp',
      'TXT - Text record' => 'txt'
    }.freeze

    CONTENT_LABELS = {
      a: { label: 'IPv4 Address', type: 'string' },
      aaaa: { label: 'IPv6 Address', type: 'string' },
      cname: { label: 'Canonical Name', type: 'string' },
      mx: { label: 'Mail Server', type: 'string' },
      ptr: { label: 'PTR Domain Name', type: 'string' },
      spf: { label: 'Text', type: 'text' },
      srv: { label: 'Value', type: 'string' },
      sshfp: { label: 'SSH Public Key', type: 'text' },
      txt: { label: 'Text', type: 'text' }
    }.freeze

    validates :type, presence: { message: 'Please select a type' }
    validates :records, presence: { message: 'Please provide a content' }

    def attributes_for_create
      {
        'type'        => (read('type').nil? ? nil : read('type').upcase),
        'name'        => (read('name').present? ? "#{read('name')}.#{read('zone_name')}" : read('zone_name')),
        'records'     => (read('records').is_a?(Array) ? read('records') : [read('records')]),
        'ttl'         => (read('ttl').present? ? read('ttl').to_i : nil),
        'description' => read('description'),
        #'zone_id'     => read('zone_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def attributes_for_update
      {
        'records'     => (read('records').is_a?(Array) ? read('records') : [read('records')]),
        'ttl'         => (read('ttl').present? ? read('ttl').to_i : nil),
        'description' => read('description'),
        'project_id'  => read('project_id')
      }.delete_if { |_k, v| v.blank? }
    end

    def is_cname
      if type == 'cname'
        records.each do |value|
          unless /\A.+\.\z/.match?(value)
            errors.add('records', 'The Canonical Name should end with a dot.')
          end
        end
      end
    end

    def perform_service_create(create_attributes)
      service.create_recordset(zone_id, create_attributes)
    end

    def perform_service_update(id, update_attributes)
      service.update_recordset(zone_id, id, update_attributes)
    end

    def perform_service_delete(id)
      service.delete_recordset(zone_id, id)
    end
  end
end
