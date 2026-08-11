# frozen_string_literal: true

require 'smart_app_launch_test_kit'

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        module Endpoints
          class FileDownload < Inferno::DSL::SuiteEndpoint
            include URLs

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['Authorization']&.delete_prefix('Bearer ')
              )
            end

            def file_contents
              '{"resourceType": "Patient"}'
            end

            def update_result
              results_repo.update(result.id, result: 'pass')
            end

            def make_response
              response.status = 200
              response.body = file_contents
              response.headers['Content-Type'] = 'application/fhir+ndjson'
            end

            def tags
              [FILE_DOWNLOAD_TAG]
            end
          end
        end
      end
    end
  end
end
