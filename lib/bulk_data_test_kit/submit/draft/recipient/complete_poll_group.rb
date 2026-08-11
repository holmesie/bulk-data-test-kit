# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        class CompletePollGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Data Status Polling Request - Complete'

          description %(
            This group verifies that a recipient supports polling requests by a provider after a submission is complete.
          )

          id :bulk_data_submit_recipient_poll_complete

          run_as_group

          input :smart_auth_info,
                type: :auth_info,
                options: { mode: 'access' },
                optional: false

          input :poll_url

          http_client do
            headers 'Authorization' => smart_auth_info.access_token
          end

          test do
            title 'Complete Poll Status'

            description %(
              This test verifies that a provider can poll for status once the recipient has finished processing.
            )

            makes_request :complete_poll_status

            run do
              get poll_url, name: :complete_poll_status

              assert response[:status] == 200, 'Invalid response status. Once complete, a status of 200 is expected.'
            end
          end

          test do
            title 'Status Response After Completion Is Valid'

            description %(
              This test verifies that the recipient responded with a valid status manifest after completion.

              The manifest should contain the following things:
              - `transactionTime`
              - `request`
              - `requiresAccessToken`
              - `output`
              - `error`
            )

            uses_request :complete_poll_status

            run do
              puts response
              manifest = JSON.parse(response[:body])
              assert manifest.key?('transactionTime'), 'The status manifest was missing a `transactionTime` value.'
              assert manifest.key?('request'), 'The status manifest was missing a `request` value.'
              assert manifest.key?('requiresAccessToken'),
                     'The status manifest was missing a `requiresAccessToken` value.'
              assert manifest.key?('output'), 'The status manifest was missing a `output` value.'
              assert manifest.key?('error'), 'The status manifest was missing a `error` value.'
            end
          end
        end
      end
    end
  end
end
