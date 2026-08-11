# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class StatusSubmitGroup < Inferno::TestGroup
          title 'Bulk Submit Status Operation'

          description %(
            This group verifies that a provider successfully made a status submit request.
          )

          id :bulk_data_submit_provider_status_submit

          run_as_group

          test do
            title 'Status Submit Request Was Made'

            description %(
              This test verifies that at least one status submit request was made.
            )

            run do
              assert load_tagged_requests(STATUS_SUBMIT_TAG).any?, 'Did not receive a status submit request.'
            end
          end

          test do
            title 'Submitter Identifier Provided via `submitter`'

            description %(
              This test verifies that a submission included the required submitter parameter.
            )

            run do
              submissions = load_tagged_requests(STATUS_SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'submitter'
                end
              end

              assert with_requirement.any?, 'No submission included the required submitter parameter `submitter`'
            end
          end

          test do
            title 'Submission ID Provided via `submissionId`'

            description %(
              This test verifies that a submission included the required submission ID parameter.
            )

            run do
              submissions = load_tagged_requests(STATUS_SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'submissionId'
                end
              end

              assert with_requirement.any?, 'No submission included the required submission ID parameter `submissionId`'
            end
          end

          test do
            title 'Submission Provided optional `_outputFormat` with type `string`'

            description %(
              This test verifies that a submission included the optional `_outputFormat` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(STATUS_SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == '_outputFormat' && !parameter.valueString.nil?
                end
              end

              assert with_requirement.any?, 'No submission included the optional `_outputFormat` parameter'
            end
          end
        end
      end
    end
  end
end
