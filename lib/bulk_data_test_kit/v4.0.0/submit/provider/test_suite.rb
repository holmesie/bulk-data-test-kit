# frozen_string_literal: true

require_relative 'urls'
require_relative 'helpers'
require_relative '../shared/jwks'
require_relative 'endpoints/submit'
require_relative 'endpoints/status'
require_relative 'endpoints/poll'

require_relative 'client_registration_group'
require_relative 'manifest_and_file_retrieval'
require_relative 'poll_group'
require_relative 'processing_wait_group'
require_relative 'wait_group'
require_relative 'submit_group'
require_relative 'submit_stopped_group'
require_relative 'status_submit_group'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class TestSuite < Inferno::TestSuite
          include URLs
          extend Shared::JWKS

          title 'Bulk Data Access v4.0.0 Submit - Data Provider (Preview)'

          description File.read(File.join(__dir__, 'docs', 'suite_description.md'))

          id :bulk_data_v400_submit_provider

          requirement_sets(
            {
              identifier: 'hl7.fhir.uv.smart-app-launch_2.2.0',
              title: 'SMART App Launch',
              actor: 'Client',
              requirements: '22,293,294'
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

          suite_endpoint :post, SUBMIT_ROUTE, Endpoints::Submit
          suite_endpoint :post, STATUS_SUBMIT_ROUTE, Endpoints::Status
          suite_endpoint :get, POLL_ROUTE, Endpoints::Poll

          resume_test_route :get, RESUME_PASS_ROUTE do |request|
            request.query_parameters['id']
          end

          route(:get, SMART_DISCOVERY_ROUTE, lambda { |_env|
            SMARTAppLaunch::MockSMARTServer.smart_server_metadata(id)
          })
          suite_endpoint :post, SMART_TOKEN_ROUTE, SMARTAppLaunch::MockSMARTServer::TokenEndpoint

          route(:get, JWKS_ROUTE, jwks_route_handler)

          input :consumer_auth_info,
                type: :auth_info,
                title: 'Bulk Submit Data Consumer Client Credentials',
                description: <<~DESCRIPTION,
                  Inferno will use these credentials when making requests to the
                  Data Provider under test
                DESCRIPTION
                options: {
                  mode: :auth,
                  components: [
                    {
                      name: :auth_type,
                      default: 'backend_services',
                      locked: true
                    },
                    {
                      name: :use_discovery,
                      locked: true
                    },
                    {
                      name: :client_id,
                      default: 'inferno_demo_consumer_client_id'
                    },
                    {
                      name: :requested_scopes,
                      default: 'system/*.r'
                    }
                  ]
                }

          group from: :bulk_data_v400_submit_provider_client_registration

          group do
            id :bulk_data_v400_submit_provider_sequence
            title 'Data Provider Sequence'

            run_as_group

            group from: :bulk_data_v400_submit_provider_wait
            group from: :bulk_data_v400_submit_provider_submit
            group from: :bulk_data_v400_submit_provider_status_submit
            group from: :bulk_data_v400_submit_provider_processing_wait
            group from: :bulk_data_v400_submit_provider_poll

            group from: :bulk_data_v400_submit_provider_manifest_file_retrieval
          end
        end
      end
    end
  end
end
