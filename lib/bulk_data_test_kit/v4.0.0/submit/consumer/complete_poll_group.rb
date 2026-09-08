# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class CompletePollGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Data Status Polling Request - Complete'

          description %(
            This group verifies that a Data Consumer supports polling requests by a provider after a submission is complete.
          )

          id :bulk_data_v400_submit_consumer_poll_complete

          run_as_group

          input :smart_auth_info,
                type: :auth_info,
                options: { mode: 'access' },
                optional: false

          input :poll_url

          http_client do
            headers 'Authorization' => "Bearer #{smart_auth_info.access_token}",
                    'Accept' => 'application/json'
          end

          test do
            id :bulk_data_v400_submit_consumer_complete_poll_status
            title 'Complete Poll Status'

            description %(
              This test verifies that a provider can poll for status once the Data Consumer has finished processing.
            )

            makes_request :complete_poll_status

            run do
              get poll_url, name: :complete_poll_status

              assert_response_status(200)

              content_type = request.response_header('content-type')&.value
              media_type = content_type&.split(';')&.first&.strip
              assert media_type&.casecmp?('application/json'),
                     'The completed poll response `Content-Type` must be `application/json`.'

              assert request.response_header('x-export-status').nil?,
                     'The completed poll response included an unexpected `X-Export-Status` header.'
            end
          end

          test do
            id :bulk_data_v400_submit_consumer_complete_poll_response
            title 'Status Response After Completion Is Valid'

            description %(
              This test verifies that the Data Consumer responded with a valid status manifest after completion.

              The manifest should contain the following things:
              - `submissionId`
              - `transactionTime`
              - `requiresAccessToken`
            )

            uses_request :complete_poll_status

            run do
              begin
                manifest = JSON.parse(response[:body])
              rescue JSON::ParserError, TypeError
                assert false, 'The completed poll response body was not valid JSON.'
              end

              assert manifest.is_a?(Hash), 'The completed poll response body must be a JSON object.'

              assert manifest.key?('submissionId'), 'The status manifest was missing a `submissionId` value.'
              manifest_submission_id = manifest['submissionId']
              assert manifest_submission_id.is_a?(String) && manifest_submission_id.present?,
                     'The status manifest `submissionId` must be a non-empty string.'
              assert manifest_submission_id == submission_id,
                     'The status manifest `submissionId` did not match the requested submission.'

              assert manifest.key?('transactionTime'), 'The status manifest was missing a `transactionTime` value.'
              transaction_time = manifest['transactionTime']
              instant_regex = Regexp.new('\A' + FHIR::R4::PRIMITIVES.dig('instant', 'regex') + '\z')
              assert transaction_time.is_a?(String) && instant_regex.match?(transaction_time),
                     'The status manifest `transactionTime` must be a valid FHIR instant.'

              assert manifest.key?('requiresAccessToken'),
                     'The status manifest was missing a `requiresAccessToken` value.'
              assert [true, false].include?(manifest['requiresAccessToken']),
                     'The status manifest `requiresAccessToken` must be a boolean.'
            end
          end
        end
      end
    end
  end
end
