# frozen_string_literal: true

module ServiceLayer
  # implements manila api
  class SharedFilesystemStorageService < Core::ServiceLayer::Service
    include SharedFilesystemStorageServices::Share
    include SharedFilesystemStorageServices::ShareRule
    include SharedFilesystemStorageServices::ShareNetwork
    include SharedFilesystemStorageServices::SecurityService
    include SharedFilesystemStorageServices::Snapshot

    MICROVERSION = 2.15

    def available?(_action_name_sym = nil)
      elektron.service?('sharev2')
    end

    def elektron_shares
      @elektron_shares ||= elektron.service(
        'sharev2',
        headers: { 'X-OpenStack-Manila-API-Version' => MICROVERSION.to_s }
      )
    end

    def microversion_newer_than?(version)
      version > MICROVERSION
    end
  end
end
