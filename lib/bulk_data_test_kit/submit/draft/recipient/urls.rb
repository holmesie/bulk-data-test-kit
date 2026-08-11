# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        RESUME_PASS_ROUTE = '/resume_pass'
        MANIFEST_ROUTE = '/manifest'
        DOWNLOAD_ROUTE = '/example.ndjson'
        SMART_DISCOVERY_ROUTE = '/.well-known/smart-configuration'
        AUTH_SERVER_ROUTE = '/auth'
        SMART_TOKEN_ROUTE = "#{AUTH_SERVER_ROUTE}/token".freeze
        JWKS_ROUTE = '/.well-known/jwks.json'

        module URLs
          def base_url
            "#{Inferno::Application['base_url']}/custom/#{suite_id}"
          end

          def resume_pass_url
            "#{base_url}#{RESUME_PASS_ROUTE}"
          end

          def manifest_url
            "#{base_url}#{MANIFEST_ROUTE}"
          end

          def download_url
            "#{base_url}#{DOWNLOAD_ROUTE}"
          end

          def smart_discovery_url
            "#{base_url}#{SMART_DISCOVERY_ROUTE}"
          end

          def suite_id
            TestSuite.id
          end
        end
      end
    end
  end
end
