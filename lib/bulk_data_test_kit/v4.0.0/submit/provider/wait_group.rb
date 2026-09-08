# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class WaitGroup < Inferno::TestGroup
          include URLs

          title 'Wait For Requests'

          description %(
            This group will capture bulk data submit requests until the user confirms they are finished.
          )

          id :bulk_data_v400_submit_provider_wait

          run_as_group

          test do
            id :bulk_data_v400_submit_provider_wait_for_requests
            title 'Wait For Submit Sequence'

            output :provider_submission_outcomes, type: :textarea

            input :client_id,
                  title: 'Client Id',
                  type: 'text',
                  optional: true,
                  locked: true,
                  description: SMARTAppLaunch::INPUT_CLIENT_ID_DESCRIPTION_LOCKED

            run do
              output provider_submission_outcomes: '{}'
              identifier = client_id.presence || test_session_id

              wait(
                identifier:,
                message: %(
                  This test will wait and capture all requests made while the tester performs a bulk data submit
                  operation (as a Data Provider) against the provided endpoint(s).

                  Use the following URL as the base Data Consumer endpoint:

                  #{fhir_base_url}

                  Start a bulk submit operation (as a Data Provider) by performing a POST request with a submit
                  manifest against the following URL:

                  #{submit_url}

                  Use client id `#{identifier}` to obtain a backend services access token from the SMART authorization
                  server for this FHIR server and include the access token on all subsequent requests.

                  Send all requests for each submission through the terminal
                  `completed` request, then use the link below to allow Inferno
                  to retrieve every completed submission.

                  The entire request sequence will be recorded and verified to check conformance to the
                  [Bulk Data Access v4.0.0 Submit specification](https://build.fhir.org/ig/HL7/bulk-data/branches/argo25/en/submit.html).

                  [Click here](#{resume_pass_url}?id=#{identifier}) when finished.
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
