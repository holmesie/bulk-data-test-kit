# frozen_string_literal: true

require 'smart_app_launch_test_kit'
require_relative '../helpers'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        module Endpoints
          class Poll < Inferno::DSL::SuiteEndpoint
            include URLs
            include Helpers

            def test_run_identifier
              return request.params[:session_path] if request.params[:session_path].present?

              SMARTAppLaunch::MockSMARTServer.issued_token_to_client_id(
                request.headers['authorization']&.delete_prefix('Bearer ')
              )
            end

            def make_response
              case submission_outcome[:status]
              when 'succeeded'
                make_completed_response
              when 'failed'
                make_error_response(500, submission_outcome[:diagnostic])
              else
                make_in_progress_response
              end
            end

            def submission_id
              submission_outcome[:submission_id]
            end

            def submission_outcome
              @submission_outcome ||= submission_outcomes
                .fetch(request.params[:submission_key].to_s, {})
                .deep_symbolize_keys
            end

            def submission_outcomes
              raw_outcomes = Inferno::Repositories::SessionData.new.load(
                test_session_id: test_run.test_session_id,
                name: :provider_submission_outcomes
              )

              JSON.parse(raw_outcomes.presence || '{}')
            rescue JSON::ParserError
              {}
            end

            def make_in_progress_response
              response.status = 202
              response.headers['Retry-After'] = '1'
            end

            def make_completed_response
              response.status = 200
              response.headers['Content-Type'] = 'application/json'
              response.body = complete_manifest(submission_id).to_json
            end

            def make_error_response(status, diagnostic)
              operation_outcome = FHIR::R4::OperationOutcome.new(
                issue: [
                  FHIR::R4::OperationOutcome::Issue.new(
                    severity: 'error',
                    code: 'processing',
                    diagnostics: diagnostic
                  )
                ]
              )

              response.status = status
              response.headers['Content-Type'] = 'application/fhir+json'
              response.body = operation_outcome.to_json
            end

            def tags
              [POLL_TAG]
            end
          end
        end
      end
    end
  end
end
