require_relative 'tags'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class ManifestAndFileRetrieval < Inferno::TestGroup
          title 'Manifest and File Retrieval'
          id :bulk_data_v400_submit_provider_manifest_file_retrieval

          test do
            title 'OAuth metadata retrieved'
            description <<~DESCRIPTION
              This test verifies that the provider's OAuth metadata could be
              retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Provider::OAUTH_METADATA_TAG

              assert requests.present?, 'No OAuth Metadata request made'
            end
          end

          test do
            title 'Successful token request made'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Provider::TOKEN_TAG

              assert requests.present?, 'No token request made'
            end
          end

          test do
            title 'Manifests for each submission were retrieved'
            description <<~DESCRIPTION
              This test verifies that all manifests included in the submissions
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Provider::MANIFEST_TAG

              assert requests.present?, 'No manifest requests made'
            end
          end

          test do
            title 'Files retrieved'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Provider::FILE_DOWNLOAD_TAG

              assert requests.present?, 'No files were downloaded'
            end
          end
        end
      end
    end
  end
end
