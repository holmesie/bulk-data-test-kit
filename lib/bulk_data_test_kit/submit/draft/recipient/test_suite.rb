# frozen_string_literal: true

require_relative 'urls'
require_relative 'helpers'

require_relative 'backend_services_group'
require_relative 'complete_poll_group'
require_relative 'endpoints/file_download'
require_relative 'endpoints/manifest'
require_relative 'manifest_and_file_retrieval'
require_relative 'poll_group'
require_relative 'submit_group'
require_relative 'submit_complete_group'
require_relative 'status_submit_group'

module BulkDataTestKit
  module Submit
    module Draft
      module Recipient
        class TestSuite < Inferno::TestSuite
          include URLs

          title 'Bulk Data Submit Draft Recipient'

          description File.read(File.join(__dir__, 'docs', 'suite_description.md'))

          id :bulk_data_submit_draft_recipient

          input :provider_base_url,
                title: 'Bulk Data Recipient Base FHIR URL',
                description: 'The URL Inferno should use as the base for the Recipient Server under test.',
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

          config(
            inputs: {
              smart_auth_info: {
                title: 'Bulk Submit Data Provider Client Credentials',
                description: 'Inferno will use these credentials when making requests to the data recipient under test.'
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

          group from: :bulk_data_submit_recipient_backend_services

          group do
            title 'Recipient Sequence'

            run_as_group

            group from: :bulk_data_submit_recipient_submit
            group from: :bulk_data_submit_recipient_status_submit
            group from: :bulk_data_submit_recipient_poll
            group from: :bulk_data_submit_recipient_submit_complete
            group from: :bulk_data_submit_recipient_poll_complete

            group from: :bulk_data_submit_recipient_manifest_file_retrieval
          end
        end
      end
    end
  end
end
