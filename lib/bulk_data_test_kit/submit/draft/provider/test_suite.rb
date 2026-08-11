# frozen_string_literal: true

require_relative 'urls'
require_relative 'helpers'
require_relative 'endpoints/submit'
require_relative 'endpoints/status'
require_relative 'endpoints/poll'

require_relative 'client_registration_group'
require_relative 'manifest_and_file_retrieval'
require_relative 'poll_group'
require_relative 'wait_group'
require_relative 'submit_group'
require_relative 'submit_aborted_group'
require_relative 'status_submit_group'

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class TestSuite < Inferno::TestSuite
          include URLs

          title 'Bulk Data Submit Draft Provider'

          description File.read(File.join(__dir__, 'docs', 'suite_description.md'))

          id :bulk_data_submit_draft_provider

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

          def self.jwks_json
            bulk_data_jwks = JSON.parse(File.read(
                                          ENV.fetch('BULK_DATA_JWKS',
                                                    File.join(File.expand_path('..', __dir__), 'bulk_data_jwks.json'))
                                        ))
            @jwks_json ||= JSON.pretty_generate(
              { keys: bulk_data_jwks['keys'].select { |key| key['key_ops']&.include?('verify') } }
            )
          end

          def self.jwks_route_handler
            ->(_env) { [200, { 'Content-Type' => 'application/json' }, [jwks_json]] }
          end

          route(:get, JWKS_ROUTE, jwks_route_handler)

          input :recipient_auth_info,
                type: :auth_info,
                title: 'Bulk Submit Data Recipient Client Credentials',
                description: <<~DESCRIPTION,
                  Inferno will use these credentials when making requests to the
                  data provider under test
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
                      default: 'inferno_demo_recipient_client_id'
                    },
                    {
                      name: :requested_scopes,
                      default: 'system/*.r'
                    }
                  ]
                }

          group from: :bulk_submit_client_registration

          group do
            title 'Provider Sequence'

            run_as_group

            group from: :bulk_data_submit_provider_wait
            group from: :bulk_data_submit_provider_submit
            group from: :bulk_data_submit_provider_status_submit
            group from: :bulk_data_submit_provider_poll
            group from: :bulk_data_submit_provider_submit_aborted

            group from: :bulk_data_submit_provider_manifest_file_retrieval
          end
        end
      end
    end
  end
end
