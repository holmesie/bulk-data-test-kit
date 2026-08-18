# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        RESUME_PASS_ROUTE = '/resume_pass'
        FHIR_BASE_ROUTE = '/fhir'
        SUBMIT_ROUTE = "#{FHIR_BASE_ROUTE}/$bulk-submit".freeze
        STATUS_SUBMIT_ROUTE = "#{FHIR_BASE_ROUTE}/$bulk-submit-status".freeze
        POLL_ROUTE = "#{FHIR_BASE_ROUTE}/status/:submission_key".freeze
        SMART_DISCOVERY_ROUTE = "#{FHIR_BASE_ROUTE}/.well-known/smart-configuration".freeze
        AUTH_SERVER_ROUTE= '/auth'
        SMART_TOKEN_ROUTE = "#{AUTH_SERVER_ROUTE}/token".freeze
        JWKS_ROUTE = '/.well-known/jwks.json'

        module URLs
          def base_url
            "#{Inferno::Application['base_url']}/custom/#{suite_id}"
          end

          def resume_pass_url
            "#{base_url}#{RESUME_PASS_ROUTE}"
          end

          def fhir_base_url
            "#{base_url}#{FHIR_BASE_ROUTE}"
          end

          def submit_url
            "#{base_url}#{SUBMIT_ROUTE}"
          end

          def status_submit_url
            "#{base_url}#{STATUS_SUBMIT_ROUTE}"
          end

          def poll_url(submission_key = ':submission_key')
            "#{base_url}#{POLL_ROUTE.sub(':submission_key', submission_key)}"
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
