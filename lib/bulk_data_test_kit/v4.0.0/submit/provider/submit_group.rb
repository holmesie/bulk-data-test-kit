# frozen_string_literal: true

require_relative '../shared/submission_status'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class SubmitGroup < Inferno::TestGroup
          include Helpers

          title 'Bulk Submit Operation'

          description %(
            This group verifies that a provider successfully made at least one
            valid completed submission.
          )

          id :bulk_data_v400_submit_provider_submit

          run_as_group

          test do
            id :bulk_data_v400_submit_provider_in_progress_submit
            title 'In-Progress Submit Request Was Made'

            description %(
              This test verifies that at least one `in-progress` submit request was made.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_in_progress = submissions.any? do |request|
                request_has_submission_status?(request, 'in-progress')
              end

              skip_if !found_in_progress, 'An `in-progress` submission was not detected.'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_completed_submit
            title 'Completed Submit Request Was Made'

            description %(
              This test verifies that at least one `completed` submit request was made.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_completed = submissions.any? do |request|
                request_has_submission_status?(request, 'completed')
              end

              assert found_completed, 'A `completed` submission was not detected.'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_submitter_identifier
            title '`submitter` Identifier Is Valid and Consistent'

            description %(
              This test verifies that every submission includes exactly one
              populated `submitter` Identifier and uses the same Identifier
              throughout the submission.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_submitter_identifiers(
                submissions,
                '$bulk-submit'
              )
            end
          end

          test do
            id :bulk_data_v400_submit_provider_submission_id
            title 'Required Submission ID Provided via `submissionId`'

            description %(
              This test verifies that every submission request includes exactly one
              populated `submissionId` string parameter.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_submission_ids(submissions, '$bulk-submit')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_submission_status
            title 'Received `submissionStatus` has a valid Coding'

            description %(
              This test verifies that when a `submissionStatus` is included, its system and code are valid.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_submission_statuses(submissions)
            end
          end

          test do
            id :bulk_data_v400_submit_provider_manifest_url
            title 'Submission Provided optional `manifestUrl` with type `url`'

            description %(
              This test verifies that a submission included the optional `manifestUrl` parameter, and had type `url`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              manifest_url_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == 'manifestUrl'
              end

              skip_if manifest_url_parameters.empty?, 'No submission included the optional `manifestUrl` parameter'
              assert manifest_url_parameters.all? { |parameter| !parameter.valueUrl.nil? },
                     '`manifestUrl` must have type `url`'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_replaces_manifest_url
            title 'Submission Provided optional `replacesManifestUrl` with type `url`'

            description %(
              This test verifies that a submission included the optional `replacesManifestUrl` parameter, and had type `url`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              replaces_manifest_url_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == 'replacesManifestUrl'
              end

              skip_if replaces_manifest_url_parameters.empty?,
                      'No submission included the optional `replacesManifestUrl` parameter'
              assert replaces_manifest_url_parameters.all? { |parameter| !parameter.valueUrl.nil? },
                     '`replacesManifestUrl` must have type `url`'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_output_format
            title 'Submission Provided optional `outputFormat` with type `string`'

            description %(
              This test verifies that a submission included the optional `outputFormat` parameter, and had type `string`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              output_format_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == 'outputFormat'
              end

              skip_if output_format_parameters.empty?,
                      'No submission included the optional `outputFormat` parameter'
              assert output_format_parameters.all? { |parameter| !parameter.valueString.nil? },
                     '`outputFormat` must have type `string`'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_fhir_base_url
            title 'Submission Provided optional `fhirBaseUrl` with type `url`'

            description %(
              This test verifies that a submission included the optional `fhirBaseUrl` parameter, and had type `url`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              fhir_base_url_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == 'fhirBaseUrl'
              end

              skip_if fhir_base_url_parameters.empty?, 'No submission included the optional `fhirBaseUrl` parameter'
              assert fhir_base_url_parameters.all? { |parameter| !parameter.valueUrl.nil? },
                     '`fhirBaseUrl` must have type `url`'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_file_request_header
            title 'Submission Provided optional `fileRequestHeader` with type `part`'

            description %(
              This test verifies that a submission included the optional `fileRequestHeader` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_optional_part_parameter(submissions, 'fileRequestHeader')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_oauth_metadata_url
            title 'Submission Provided optional `oauthMetadataUrl` with type `url`'

            description %(
              This test verifies that a submission included the optional `oauthMetadataUrl` parameter, and had type `url`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              oauth_metadata_url_parameters = submissions.flat_map do |request|
                FHIR.from_contents(request.request_body).parameter
              end.select do |parameter|
                parameter.name == 'oauthMetadataUrl'
              end

              skip_if oauth_metadata_url_parameters.empty?,
                      'No submission included the optional `oauthMetadataUrl` parameter'
              assert oauth_metadata_url_parameters.all? { |parameter| !parameter.valueUrl.nil? },
                     '`oauthMetadataUrl` must have type `url`'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_file_encryption_key
            title 'Submission Provided optional `fileEncryptionKey` with type `part`'

            description %(
              This test verifies that a submission included the optional `fileEncryptionKey` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_optional_part_parameter(submissions, 'fileEncryptionKey')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_metadata
            title 'Submission Provided optional `metadata` with type `part`'

            description %(
              This test verifies that a submission included the optional `metadata` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_optional_part_parameter(submissions, 'metadata')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_import
            title 'Submission Provided optional `import` with type `part`'

            description %(
              This test verifies that a submission included the optional `import` parameter, and had type `part`.
            )

            optional

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_optional_part_parameter(submissions, 'import')
            end
          end

          test do
            id :bulk_data_v400_submit_provider_terminal_submission_order
            title 'No Requests Follow a Terminal Submission Status'

            description %(
              This test verifies that no additional `$bulk-submit` request was
              made for a submission after it was marked `completed` or `stopped`.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              validate_terminal_submission_order(submissions)
            end
          end
        end
      end
    end
  end
end
