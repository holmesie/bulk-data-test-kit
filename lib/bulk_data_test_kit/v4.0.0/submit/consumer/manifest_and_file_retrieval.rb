require_relative 'tags'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class ManifestAndFileRetrieval < Inferno::TestGroup
          title 'Manifest and File Retrieval'
          id :bulk_data_v400_submit_consumer_manifest_file_retrieval

          test do
            id :bulk_data_v400_submit_consumer_token_request
            title 'Token request received'
            description <<~DESCRIPTION
              This test verifies that the Data Consumer requested an access
              token.
            DESCRIPTION

            run do
              load_tagged_requests SMARTAppLaunch::TOKEN_TAG

              assert requests.present?, 'No token request was received'
            end
          end

          test do
            id :bulk_data_v400_submit_consumer_manifests_retrieved
            title 'Manifests retrieved'
            description <<~DESCRIPTION
              This test verifies that all manifests included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Consumer::MANIFEST_TAG

              assert requests.present?, 'No manifests were downloaded'
            end
          end

          test do
            id :bulk_data_v400_submit_consumer_files_retrieved
            title 'Files retrieved'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Consumer::FILE_DOWNLOAD_TAG

              assert requests.present?, 'No files were downloaded'
            end
          end
        end
      end
    end
  end
end
