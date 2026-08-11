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
            This group verifies that a Data Consumer supports polling requests by a provider.

            This group will:
            1. Perform an initial status poll against the URL given by the Data Consumer during the status submission phase.
            2. Waits until the user verifies that the reciever is finished processing all files.
          )

          id :bulk_data_v400_submit_consumer_poll

          run_as_group

          input :consumer_client_id,
                title: 'Data Consumer Client ID',
                description: <<~DESCRIPTION
                  Client ID of the Bulk Submit Data Consumer system under test.
                  If no value is provided, the Inferno session id will be used.
                DESCRIPTION

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
            headers 'Authorization' => smart_auth_info.access_token
          end

          test do
            title 'Initial Poll Status'

            description %(
              This test verifies that a provider can poll for status against the Data Consumer under test.
            )

            run do
              get poll_url

              assert [200, 202].include?(response[:status]), 'Invalid response status.'
            end
          end

          test do
            title 'Wait For Processing'

            run do
              identifier = consumer_client_id || test_session_id

              wait(
                identifier: identifier,
                message: %(
                  When the Data Consumer under test has finished processing all submission files, [click here](#{resume_pass_url}?id=#{identifier}).
                ),
                timeout: 900
              )
            end
          end
        end
      end
    end
  end
end
