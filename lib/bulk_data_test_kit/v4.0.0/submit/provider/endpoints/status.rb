# frozen_string_literal: true

require 'smart_app_launch_test_kit'
require_relative '../helpers'
require_relative '../../shared/submission_status'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        module Endpoints
          class Status < Inferno::DSL::SuiteEndpoint
            include URLs
            include Helpers

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['authorization']&.delete_prefix('Bearer ')
              )
            end

            def make_response
              if identity.nil?
                response.status = 400
                response.headers['Content-Type'] = 'application/fhir+json'
                response.body = FHIR::R4::OperationOutcome.new(
                  issue: [
                    FHIR::R4::OperationOutcome::Issue.new(
                      severity: 'error',
                      code: 'invalid',
                      diagnostics: 'The request did not identify a Bulk Submit submission.'
                    )
                  ]
                ).to_json
              else
                response.status = 202
                response.headers['Content-Location'] = poll_url(submission_key(identity))
              end
            end

            def identity
              @identity ||= submission_identity(request_parameters)
            end

            def request_parameters
              body = request.body.read
              request.body.rewind
              FHIR.from_contents(body)
            rescue JSON::ParserError, TypeError
              nil
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
