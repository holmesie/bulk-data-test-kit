# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class StatusSubmitGroup < Inferno::TestGroup
          include Helpers

          title 'Bulk Submit Status Operation'

          description %(
            This group verifies that a provider successfully made a status submit request.
          )

          id :bulk_data_v400_submit_provider_status_submit

          run_as_group

          optional

          test do
            id :bulk_data_v400_submit_provider_status_submit_request
            title 'Status Submit Request Was Made'

            description %(
              This test verifies that at least one status submit request was made.
            )

            run do
              assert load_tagged_requests(STATUS_SUBMIT_TAG).any?, 'Did not receive a status submit request.'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_status_submit_identity
            title '`submitter` and `submissionId` Match Submission'

            description %(
              This test verifies that every status submission includes exactly one
              populated `submitter` Identifier and `submissionId`, and that the
              combination matches a submit request.
            )

            run do
              validate_status_submission_identities(
                load_tagged_requests(STATUS_SUBMIT_TAG),
                load_tagged_requests(SUBMIT_TAG)
              )
            end
          end

          test do
            id :bulk_data_v400_submit_provider_status_submit_submission_id
            title 'Submission ID Provided via `submissionId`'

            description %(
              This test verifies that every status request includes exactly one
              populated `submissionId` string parameter.
            )

            run do
              submissions = load_tagged_requests(STATUS_SUBMIT_TAG)
              validate_submission_ids(submissions, '$bulk-submit-status')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_status_submit_output_format
            title 'Submission Provided optional `_outputFormat` with type `string`'

            description %(
              This test verifies that a submission included the optional `_outputFormat` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(STATUS_SUBMIT_TAG)
              output_format_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == '_outputFormat'
              end

              skip_if output_format_parameters.empty?,
                      'No submission included the optional `_outputFormat` parameter'
              assert output_format_parameters.all? { |parameter| !parameter.valueString.nil? },
                     '`_outputFormat` must have type `string`'
            end
          end
        end
      end
    end
  end
end
