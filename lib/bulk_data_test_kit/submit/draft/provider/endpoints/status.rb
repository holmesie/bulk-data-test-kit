# frozen_string_literal: true

require 'smart_app_launch_test_kit'

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        module Endpoints
          class Status < Inferno::DSL::SuiteEndpoint
            include URLs

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['Authorization']&.delete_prefix('Bearer ')
              )
            end

            def make_response
              response.status = 202
              response.headers['Content-Location'] = poll_url
            end

            def tags
              [STATUS_SUBMIT_TAG]
            end
          end
        end
      end
    end
  end
end
