# frozen_string_literal: true

require 'smart_app_launch/smart_stu2_suite'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        class BackendServicesGroup < Inferno::TestGroup
          title 'SMART Backend Services'

          id :bulk_data_v400_submit_consumer_backend_services

          run_as_group

          optional

          group from: :smart_discovery_stu2,
                config: {
                  inputs: {
                    url: { name: :consumer_fhir_base_url },
                    smart_auth_info: {
                      options: {
                        components: [
                          { name: :requested_scopes, default: 'system/bulk-submit' }
                        ]
                      }
                    }
                  }
                }

          group from: :backend_services_authorization,
                config: {
                  inputs: {
                    url: { name: :consumer_fhir_base_url },
                    smart_auth_info: {
                      options: {
                        components: [
                          { name: :requested_scopes, default: 'system/bulk-submit' }
                        ]
                      }
                    }
                  }
                },
                run_as_group: true
        end
      end
    end
  end
end
