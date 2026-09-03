# frozen_string_literal: true

require_relative 'urls'
require_relative 'helpers'
require_relative '../shared/jwks'

require_relative 'backend_services_group'
require_relative 'complete_poll_group'
require_relative 'endpoints/file_download'
require_relative 'endpoints/manifest'
require_relative 'manifest_and_file_retrieval'
require_relative 'poll_group'
require_relative 'processing_wait_group'
require_relative 'submit_group'
require_relative 'submit_completed_group'
require_relative 'status_submit_group'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class TestSuite < Inferno::TestSuite
          include URLs
          extend Shared::JWKS

          title 'Bulk Data Access v4.0.0 Submit - Data Consumer (Preview)'

          description File.read(File.join(__dir__, 'docs', 'suite_description.md'))

          id :bulk_data_v400_submit_consumer

          requirement_sets(
            {
              identifier: 'hl7.fhir.uv.smart-app-launch_2.2.0',
              title: 'SMART App Launch',
              actor: 'Server',
              requirements: '30,251,253-256,258,372-374,377,381-383,385,393,394'
            }
          )

          links [
            {
              label: 'Report Issue',
              url: 'https://github.com/inferno-framework/bulk-data-test-kit/issues/'
            },
            {
              label: 'Open Source',
              url: 'https://github.com/inferno-framework/bulk-data-test-kit/'
            },
            {
              label: 'Download',
              url: 'https://github.com/inferno-framework/bulk-data-test-kit/releases'
            }
          ]

          input :consumer_fhir_base_url,
                title: 'Bulk Data Consumer Base FHIR URL',
                description: 'The URL Inferno should use as the base for the Data Consumer under test.',
                type: 'text',
                optional: false

          input :submission_id,
                title: 'Submission ID',
                description: 'Set the submission ID that will be used for the submission flow.',
                type: 'text',
                optional: false,
                default: '123'

          route(:get, SMART_DISCOVERY_ROUTE, lambda { |_env|
                  SMARTAppLaunch::MockSMARTServer.smart_server_metadata(id)
                })
          suite_endpoint :post, SMART_TOKEN_ROUTE, SMARTAppLaunch::MockSMARTServer::TokenEndpoint

          route(:get, JWKS_ROUTE, jwks_route_handler)

          config(
            inputs: {
              smart_auth_info: {
                title: 'Bulk Submit Data Provider Client Credentials',
                description: 'Inferno will use these credentials when making requests to the Data Consumer under test.'
              }
            },
            options: {
              post_authorization_uri: "#{Inferno::Application['base_url']}/custom/smart_stu2/post_auth"
            }
          )

          resume_test_route :get, RESUME_PASS_ROUTE do |request|
            request.query_parameters['id']
          end

          suite_endpoint :get, MANIFEST_ROUTE, Endpoints::Manifest
          suite_endpoint :get, DOWNLOAD_ROUTE, Endpoints::FileDownload

          group from: :bulk_data_v400_submit_consumer_backend_services

          group do
            id :bulk_data_v400_submit_consumer_sequence
            title 'Data Consumer Sequence'

            run_as_group

            group from: :bulk_data_v400_submit_consumer_submit
            group from: :bulk_data_v400_submit_consumer_status_submit
            group from: :bulk_data_v400_submit_consumer_poll
            group from: :bulk_data_v400_submit_consumer_submit_completed
            group from: :bulk_data_v400_submit_consumer_processing_wait
            group from: :bulk_data_v400_submit_consumer_poll_complete

            group from: :bulk_data_v400_submit_consumer_manifest_file_retrieval
          end
        end
      end
    end
  end
end
