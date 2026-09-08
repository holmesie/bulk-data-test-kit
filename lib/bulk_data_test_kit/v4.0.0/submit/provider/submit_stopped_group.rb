# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class SubmitStoppedGroup < Inferno::TestGroup
          include Helpers

          title 'Bulk Submit Operation - Stopped'

          description %(
            This group verifies that a provider made at least one submission with a status of `stopped`.
          )

          id :bulk_data_v400_submit_provider_submit_stopped

          run_as_group

          optional

          test do
            id :bulk_data_v400_submit_provider_stopped_submit
            title 'Stopped Submit Request Was Made'

            description %(
              This test verifies that at least one `stopped` submit request was made.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_stopped = submissions.any? do |request|
                request_has_submission_status?(request, 'stopped')
              end

              skip_if !found_stopped, 'A `stopped` submission was not detected.'
            end
          end
        end
      end
    end
  end
end
