# frozen_string_literal: true

require 'uri'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class StatusSubmitGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Submit Status Operation - Initialize'

          description %(
            This group verifies that a status submission can be made against the Data Consumer.

            This group will:
            1. Using the provided base URL of the Data Consumer system under test, will perform the $bulk-submit-status operation.
            2. Check that the response contains a `Content-Location` header for status polling.
          )

          id :bulk_data_v400_submit_consumer_status_submit

          run_as_group

          input :smart_auth_info,
                type: :auth_info,
                options: { mode: 'access' },
                optional: false

          output :poll_url

          http_client do
            headers 'Authorization' => "Bearer #{smart_auth_info.access_token}",
                    'Content-Type' => 'application/fhir+json'
          end

          test do
            title 'Status Submit'

            description %(
              This test verifies that a status submission can be made against the Data Consumer.
            )

            run do
              parameters = status_parameters(submission_id)

              post "#{consumer_fhir_base_url}/$bulk-submit-status",
                   body: parameters.to_json,
                   headers: {
                     'Accept' => 'application/fhir+json',
                     'Prefer' => 'respond-async'
                   }

              assert_response_status(202)

              poll_url = request.response_header('content-location')&.value
              assert poll_url.present?, 'Status response headers did not include "Content-Location".'

              begin
                parsed_poll_url = URI.parse(poll_url)
              rescue URI::InvalidURIError
                assert false, '"Content-Location" must be an absolute HTTP(S) URL.'
              end

              assert %w[http https].include?(parsed_poll_url.scheme&.downcase) && parsed_poll_url.host.present?,
                     '"Content-Location" must be an absolute HTTP(S) URL.'

              output poll_url:
            end
          end
        end
      end
    end
  end
end
