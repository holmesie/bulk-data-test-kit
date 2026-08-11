# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class SubmitGroup < Inferno::TestGroup
          title 'Bulk Submit Operation'

          description %(
            This group verifies that a provider successfully made at least one
            valid complete submission.
          )

          id :bulk_data_submit_provider_submit

          run_as_group

          test do
            title 'In-Progress Submit Request Was Made'

            description %(
              This test verifies that at least one `in-progress` submit request was made.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_in_progress = false
              submissions.each do |request|
                parameters = FHIR.from_contents(request.request_body)
                status_parameters = parameters.parameter.filter do |parameter|
                  parameter.name == 'submissionStatus'
                end

                found_in_progress = true if status_parameters.empty?

                status_parameters.each do |status_parameter|
                  found_in_progress = true if status_parameter.valueCoding.code == 'in-progress'
                end
              end

              skip_if !found_in_progress, 'An `in-progress` submission was not detected.'
            end
          end

          test do
            title 'Complete Submit Request Was Made'

            description %(
              This test verifies that at least one `complete` submit request was made.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_complete = false
              submissions.each do |request|
                parameters = FHIR.from_contents(request.request_body)
                status_parameters = parameters.parameter.filter do |parameter|
                  parameter.name == 'submissionStatus'
                end
                status_parameters.each do |status_parameter|
                  found_complete = true if status_parameter.valueCoding.code == 'complete'
                end
              end

              assert found_complete, 'A `complete` submission was not detected.'
            end
          end

          test do
            title 'Required Submitter Identifier Provided via `submitter`'

            description %(
              This test verifies that a submission included the required submitter parameter.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
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
            title 'Required Submission ID Provided via `submissionId`'

            description %(
              This test verifies that a submission included the required submission ID parameter.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
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
            title 'Recieved `submissionStatus` has a valid code'

            description %(
              This test verifies that when a `submissionStatus` is included, it is valid.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              submissions.each do |request|
                parameters = FHIR.from_contents(request.request_body)
                status_parameters = parameters.parameter.filter do |parameter|
                  parameter.name == 'submissionStatus' && !parameter.valueCoding.nil?
                end
                status_parameters.each do |status_parameter|
                  assert %w[in-progress complete aborted].include?(status_parameter.valueCoding.code),
                         "#{status_parameter.valueCoding.code} is not a valid submissionStatus code"
                end
              end
            end
          end

          test do
            title 'Submission Provided optional `manifestUrl` with type `string`'

            description %(
              This test verifies that a submission included the optional `manifestUrl` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'manifestUrl' && !parameter.valueString.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `manifestUrl` parameter'
            end
          end

          test do
            title 'Submission Provided optional `replacesManifestUrl` with type `string`'

            description %(
              This test verifies that a submission included the optional `replacesManifestUrl` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'replacesManifestUrl' && !parameter.valueString.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `replacesManifestUrl` parameter'
            end
          end

          test do
            title 'Submission Provided optional `outputFormat` with type `string`'

            description %(
              This test verifies that a submission included the optional `outputFormat` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'outputFormat' && !parameter.valueString.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `outputFormat` parameter'
            end
          end

          test do
            title 'Submission Provided optional `fhirBaseUrl` with type `string`'

            description %(
              This test verifies that a submission included the optional `fhirBaseUrl` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'fhirBaseUrl' && !parameter.valueString.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `fhirBaseUrl` parameter'
            end
          end

          test do
            title 'Submission Provided optional `fileRequestHeader` with type `part`'

            description %(
              This test verifies that a submission included the optional `fileRequestHeader` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'fileRequestHeader' && !parameter.part.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `fileRequestHeader` parameter'
            end
          end

          test do
            title 'Submission Provided optional `oauthMetadataUrl` with type `string`'

            description %(
              This test verifies that a submission included the optional `oauthMetadataUrl` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'oauthMetadataUrl' && !parameter.valueString.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `oauthMetadataUrl` parameter'
            end
          end

          test do
            title 'Submission Provided optional `fileEncryptionKey` with type `part`'

            description %(
              This test verifies that a submission included the optional `fileEncryptionKey` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'fileEncryptionKey' && !parameter.part.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `fileEncryptionKey` parameter'
            end
          end

          test do
            title 'Submission Provided optional `metadata` with type `part`'

            description %(
              This test verifies that a submission included the optional `metadata` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'metadata' && !parameter.part.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `metadata` parameter'
            end
          end

          test do
            title 'Submission Provided optional `import` with type `part`'

            description %(
              This test verifies that a submission included the optional `import` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              with_requirement = submissions.filter do |request|
                parameters = FHIR.from_contents(request.request_body)
                parameters.parameter.any? do |parameter|
                  parameter.name == 'import' && !parameter.part.nil?
                end
              end

              skip_if !with_requirement.any?, 'No submission included the optional `import` parameter'
            end
          end
        end
      end
    end
  end
end
