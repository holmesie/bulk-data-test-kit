# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class SubmitGroup < Inferno::TestGroup
          include URLs
          include Helpers

          title 'Bulk Submit Operation'

          description %(
            This group verifies that a submission can be made against the Data Consumer.

            This group will:
            1. Using the provided base URL of the Data Consumer system under test, will perform a "kick off" $bulk-submit operation.
            2. Check that the response is valid.
          )

          id :bulk_data_v400_submit_consumer_submit

          run_as_group

          input :smart_auth_info,
                type: :auth_info,
                options: { mode: 'access' },
                optional: false

          http_client do
            headers 'Authorization' => "Bearer #{smart_auth_info.access_token}",
                    'Content-Type' => 'application/fhir+json'
          end

          test do
            id :bulk_data_v400_submit_consumer_manifest_url_submit
            title 'Submit Manifest URL'

            description %(
              This test verifies that a submission can be made against the Data Consumer.
            )

            run do
              parameters =
                submit_parameters(
                  submission_id,
                  base_url,
                  status: 'in-progress',
                  manifest_url: manifest_url,
                  oauth_metadata_url: smart_discovery_url
                )

              post "#{consumer_fhir_base_url}/$bulk-submit",
                   body: parameters.to_json,
                   headers: {
                     'Accept' => 'application/fhir+json'
                   }

              assert_response_status(200)
            end
          end
        end
      end
    end
  end
end
