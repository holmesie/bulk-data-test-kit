# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class PollGroup < Inferno::TestGroup
          title 'Bulk Data Status Polling Request'

          description %(
            This group verifies that a provider successfully polled for status.
          )

          id :bulk_data_submit_provider_poll

          run_as_group

          test do
            title 'Poll Request Was Made'

            description %(
              This test verifies that at least one poll request was made.
            )

            run do
              assert load_tagged_requests(POLL_TAG).any?, 'Did not receive a poll request.'
            end
          end
        end
      end
    end
  end
end
