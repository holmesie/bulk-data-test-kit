# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class WaitGroup < Inferno::TestGroup
          include URLs

          title 'Wait For Requests'

          description %(
            This group will capture bulk data submit requests until the user confirms they are finished.
          )

          id :bulk_data_submit_provider_wait

          run_as_group

          test do
            title 'Wait For Submit Sequence'

            input :client_id,
                  title: 'Client Id',
                  type: 'text',
                  optional: true,
                  locked: true,
                  description: SMARTAppLaunch::INPUT_CLIENT_ID_DESCRIPTION_LOCKED

            run do
              wait(
                identifier: client_id,
                message: %(
                  This test will wait and capture all requests made while the tester performs a bulk data submit
                  operation (as a Provider) against the provided endpoint(s).

                  Use the following URL as the base "recipient" system endpoint:

                  #{fhir_base_url}

                  Start a bulk submit operation (as a Provider) by performing a POST request with a submit
                  manifest against the following URL:

                  #{submit_url}

                  Use client id `#{client_id}` to obtain a backend services access token from the SMART authorization
                  server for this FHIR server and include the access token on all subsequent requests.

                  After the submit is made, the tester should proceed through the rest of the bulk submit sequence.

                  The entire request sequence will be recorded and verified to check conformance to the
                  [FHIR Bulk Submit Operation Draft](https://hackmd.io/@argonaut/rJoqHZrPle).

                  [Click here](#{resume_pass_url}?id=#{client_id}) when finished.
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
