require_relative 'tags'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class ManifestAndFileRetrieval < Inferno::TestGroup
          include Helpers

          title 'Manifest and File Retrieval'
          id :bulk_data_v400_submit_provider_manifest_file_retrieval

          input :provider_submission_outcomes, type: :textarea, optional: true

          test do
            id :bulk_data_v400_submit_provider_completed_submissions_processed
            title 'Completed submissions were processed successfully'
            description <<~DESCRIPTION
              This test verifies that Inferno successfully retrieved every
              completed submission.
            DESCRIPTION

            run do
              outcomes = JSON.parse(provider_submission_outcomes.presence || '{}')
              skip_if outcomes.empty?, 'No completed submissions were processed'

              failures = outcomes.values.select { |outcome| outcome['status'] == 'failed' }
              assert failures.empty?, 'Inferno was unable to retrieve one or more completed submissions.'
            end
          end

          test do
            id :bulk_data_v400_submit_provider_oauth_metadata_retrieved
            title 'OAuth metadata retrieved'
            description <<~DESCRIPTION
              This test verifies that the provider's OAuth metadata could be
              retrieved.
            DESCRIPTION

            run do
              submit_requests = load_tagged_requests Provider::SUBMIT_TAG
              completed_submissions = valid_completed_submission_parameters(submit_requests)
              oauth_metadata_submitted = completed_submissions.any? do |parameters|
                manifest_submitted = parameters.parameter.any? do |parameter|
                  parameter.name == 'manifestUrl' && parameter.valueUrl.present?
                end
                oauth_metadata_url_submitted = parameters.parameter.any? do |parameter|
                  parameter.name == 'oauthMetadataUrl' && parameter.valueUrl.present?
                end

                manifest_submitted && oauth_metadata_url_submitted
              end

              skip_if !oauth_metadata_submitted, 'No OAuth metadata URL was submitted'

              oauth_metadata_requests = load_tagged_requests Provider::OAUTH_METADATA_TAG

              assert oauth_metadata_requests.present?, 'No OAuth Metadata request made'

              failed_requests = oauth_metadata_requests.reject { |request| request.status.to_i == 200 }
              assert failed_requests.empty?,
                     "OAuth metadata retrieval failed: #{failed_requests.map { |request| "#{request.url} returned #{request.status}" }.join(', ')}"
            end
          end

          test do
            id :bulk_data_v400_submit_provider_token_request_success
            title 'Successful token request made'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              submit_requests = load_tagged_requests Provider::SUBMIT_TAG
              completed_submissions = valid_completed_submission_parameters(submit_requests)
              oauth_metadata_submitted = completed_submissions.any? do |parameters|
                manifest_submitted = parameters.parameter.any? do |parameter|
                  parameter.name == 'manifestUrl' && parameter.valueUrl.present?
                end
                oauth_metadata_url_submitted = parameters.parameter.any? do |parameter|
                  parameter.name == 'oauthMetadataUrl' && parameter.valueUrl.present?
                end

                manifest_submitted && oauth_metadata_url_submitted
              end

              skip_if !oauth_metadata_submitted, 'No OAuth metadata URL was submitted'

              token_requests = load_tagged_requests Provider::TOKEN_TAG

              assert token_requests.present?, 'No token request made'

              failed_requests = token_requests.reject { |request| request.status.to_i == 200 }
              assert failed_requests.empty?,
                     "Token request failed: #{failed_requests.map { |request| "#{request.url} returned #{request.status}" }.join(', ')}"
            end
          end

          test do
            id :bulk_data_v400_submit_provider_manifests_retrieved
            title 'Manifests for each submission were retrieved'
            description <<~DESCRIPTION
              This test verifies that all manifests included in the submissions
              were retrieved.
            DESCRIPTION

            run do
              submit_requests = load_tagged_requests Provider::SUBMIT_TAG
              completed_submissions = valid_completed_submission_parameters(submit_requests)
              expected_manifest_count = completed_submissions.sum do |parameters|
                parameters.parameter.count do |parameter|
                  parameter.name == 'manifestUrl' && parameter.valueUrl.present?
                end
              end

              skip_if expected_manifest_count.zero?, 'No manifest URLs were submitted'

              manifest_requests = load_tagged_requests Provider::MANIFEST_TAG

              assert manifest_requests.count == expected_manifest_count,
                     "Expected #{expected_manifest_count} manifest retrievals, " \
                     "but received #{manifest_requests.count}"

              failed_requests = manifest_requests.reject { |request| request.status.to_i == 200 }
              assert failed_requests.empty?,
                     "Manifest retrieval failed: #{failed_requests.map { |request| "#{request.url} returned #{request.status}" }.join(', ')}"
            end
          end

          test do
            id :bulk_data_v400_submit_provider_files_retrieved
            title 'Files retrieved'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              manifest_requests = load_tagged_requests Provider::MANIFEST_TAG

              expected_file_count = manifest_requests
                .select { |request| request.status.to_i == 200 }
                .sum do |request|
                  manifest = JSON.parse(request.response_body)
                  Array(manifest['output']).count
                end

              skip_if expected_file_count.zero?, 'No files were listed in the retrieved manifests'

              file_requests = load_tagged_requests Provider::FILE_DOWNLOAD_TAG

              assert file_requests.count == expected_file_count,
                     "Expected #{expected_file_count} file downloads, but received #{file_requests.count}"

              failed_requests = file_requests.reject { |request| request.status.to_i == 200 }
              assert failed_requests.empty?,
                     "File retrieval failed: #{failed_requests.map { |request| "#{request.url} returned #{request.status}" }.join(', ')}"
            end
          end
        end
      end
    end
  end
end
