# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        class StatusSubmitGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Submit Status Operation - Initialize'

          description %(
            This group verifies that a status submission can be made against the recipient.

            This group will:
            1. Using the provided base URL of the recipient system under test, will perform the $bulk-submit-status operation.
            2. Check that the response contains a `Content-Location` header for status polling.
          )

          id :bulk_data_submit_recipient_status_submit

          run_as_group

          input :smart_auth_info,
                type: :auth_info,
                options: { mode: 'access' },
                optional: false

          output :poll_url

          http_client do
            headers 'Authorization' => smart_auth_info.access_token, 'Content-Type' => 'application/fhir+json'
          end

          test do
            title 'Status Submit'

            description %(
              This test verifies that a status submission can be made against the recipient.
            )

            # TODO: these parameters shouldn't include base url
            run do
              parameters =
                submit_parameters(
                  submission_id,
                  base_url
                )

              post "#{provider_base_url}/$bulk-submit-status",
                   body: parameters.to_json,
                   headers: {
                     'Accept' => 'application/fhir+json',
                     'Prefer' => 'respond-async'
                   }

              output poll_url: request.response_header('content-location')&.value

              assert_response_status(202)
            end
          end
        end
      end
    end
  end
end
