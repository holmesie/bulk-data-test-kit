# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        class PollGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Data Status Polling Request'

          description %(
            This group verifies that a recipient supports polling requests by a provider.

            This group will:
            1. Perform an initial status poll against the URL given by the recipient during the status submission phase.
            2. Waits until the user verifies that the reciever is finished processing all files.
          )

          id :bulk_data_submit_recipient_poll

          run_as_group

          input :recipient_client_id,
                title: 'Recipient Client ID',
                description: <<~DESCRIPTION
                  Client ID of the Bulk Data Submit Recipient system under test.
                  If no value is provided, the Inferno session id will be used.
                DESCRIPTION

          input :smart_jwk_set,
                title: 'Recipient JSON Web Key Set (JWKS)',
                description: <<~DESCRIPTION
                  The Bulk Data Submit Recipient system's JSON Web Key Set
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
              This test verifies that a provider can poll for status against the recipient under test.
            )

            run do
              get poll_url

              assert [200, 202].include?(response[:status]), 'Invalid response status.'
            end
          end

          test do
            title 'Wait For Processing'

            run do
              identifier = recipient_client_id || test_session_id

              wait(
                identifier: identifier,
                message: %(
                  When the recipient under test has finished processing all submission files, [click here](#{resume_pass_url}?id=#{identifier}).
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
