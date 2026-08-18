# frozen_string_literal: true

require 'smart_app_launch_test_kit'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        module Endpoints
          class Manifest < Inferno::DSL::SuiteEndpoint
            include URLs

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['authorization']&.delete_prefix('Bearer ')
              )
            end

            def download_url
              "#{Inferno::Application['base_url']}/custom/#{TestSuite.id}#{DOWNLOAD_ROUTE}"
            end

            def manifest_url
              "#{Inferno::Application['base_url']}/custom/#{TestSuite.id}#{MANIFEST_ROUTE}"
            end

            def manifest
              {
                transactionTime: DateTime.now,
                requiresAccessToken: true,
                output: [
                  {
                    type: 'Patient',
                    url: download_url
                  }
                ]
              }
            end

            def make_response
              response.status = 200
              response.headers['Content-Type'] = 'application/json'
              response.body = manifest.to_json
            end

            def tags
              [MANIFEST_TAG]
            end
          end
        end
      end
    end
  end
end
