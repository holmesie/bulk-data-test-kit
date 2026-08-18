# frozen_string_literal: true

require_relative 'retrieval'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class ProcessingWaitGroup < Inferno::TestGroup
          include URLs

          title 'Retrieve Submissions and Wait For Final Polls'

          description %(
            After the tester confirms that all submit requests have been sent,
            Inferno retrieves each completed submission. It then pauses while
            the Data Provider makes its final status polling requests.
          )

          id :bulk_data_v400_submit_provider_processing_wait

          run_as_group

          input :client_id,
                title: 'Client Id',
                type: 'text',
                optional: true,
                locked: true,
                description: SMARTAppLaunch::INPUT_CLIENT_ID_DESCRIPTION_LOCKED

          test do
            include Helpers
            include Retrieval

            title 'Retrieve Completed Submissions and Wait For Final Polls'

            output :provider_submission_outcomes, type: :textarea

            run do
              identities = completed_submission_identities
              skip_if identities.empty?, 'No completed submissions were received.'

              outcomes = identities.each_with_object({}) do |identity, submission_outcomes|
                key = submission_key(identity)

                begin
                  retrieve_submission(identity)
                  submission_outcomes[key] = {
                    status: 'succeeded',
                    submission_id: identity[:submission_id]
                  }
                rescue StandardError
                  submission_outcomes[key] = {
                    status: 'failed',
                    submission_id: identity[:submission_id],
                    diagnostic: Retrieval::FAILURE_DIAGNOSTIC
                  }
                end
              end

              output provider_submission_outcomes: outcomes.to_json

              identifier = client_id.presence || test_session_id
              wait(
                identifier:,
                message: %(
                  Inferno has finished retrieving the completed submissions.
                  The Data Provider may now make its final request to each
                  Content-Location returned by `$bulk-submit-status`.

                  [Click here](#{resume_pass_url}?id=#{identifier}) after all
                  final polling requests have been made.
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
