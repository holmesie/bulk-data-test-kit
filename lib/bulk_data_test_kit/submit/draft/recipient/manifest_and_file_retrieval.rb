require_relative 'tags'

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        class ManifestAndFileRetrieval < Inferno::TestGroup
          title 'Manifest and File Retrieval'
          id :bulk_data_submit_recipient_manifest_file_retrieval

          test do
            title 'Token request received'
            description <<~DESCRIPTION
              This test verifies that the recipient requested an access
              token.
            DESCRIPTION

            run do
              load_tagged_requests SMARTAppLaunch::TOKEN_TAG

              assert requests.present?, 'No token request was received'
            end
          end

          test do
            title 'Manifests retrieved'
            description <<~DESCRIPTION
              This test verifies that all manifests included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Recipient::MANIFEST_TAG

              assert requests.present?, 'No manifests were downloaded'
            end
          end

          test do
            title 'Files retrieved'
            description <<~DESCRIPTION
              This test verifies that all files included in the manifest
              were retrieved.
            DESCRIPTION

            run do
              load_tagged_requests Recipient::FILE_DOWNLOAD_TAG

              assert requests.present?, 'No files were downloaded'
            end
          end
        end
      end
    end
  end
end
