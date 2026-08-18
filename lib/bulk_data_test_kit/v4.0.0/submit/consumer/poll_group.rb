# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class PollGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Data Status Polling Request'

          description %(
            This group verifies that a Data Consumer returns an in-progress response
            to an initial status poll. Inferno sends the terminal `completed`
            submission immediately after this group, then polls for the final result.
          )

          id :bulk_data_v400_submit_consumer_poll

          run_as_group

          input :smart_jwk_set,
                title: 'Data Consumer JSON Web Key Set (JWKS)',
                description: <<~DESCRIPTION
                  The Bulk Submit Data Consumer system's JSON Web Key Set
                  including the key(s) Inferno will need to verify signatures on
                  token requests made by the client. May be provided as either a
                  publicly accessible url containing the JWKS, or the raw JWKS
                  JSON.
                DESCRIPTION

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
            title 'Initial Poll Status'

            description %(
              This test verifies that a provider can poll for status against the Data Consumer under test.
            )

            run do
              get poll_url

              assert_response_status(202)
              assert request.response_header('x-export-status').nil?,
                     'The initial poll response included an unexpected `X-Export-Status` header.'
            end
          end

        end
      end
    end
  end
end
