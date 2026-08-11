# frozen_string_literal: true

require 'smart_app_launch_test_kit'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        class ClientRegistrationGroup < Inferno::TestGroup
          id :bulk_data_v400_submit_provider_client_registration

          title 'Client Registration'

          config(
            inputs: {
              client_id: {
                title: 'Provider Client ID',
                description: <<~DESCRIPTION
                  Client ID of the Bulk Data Submit Provider system under test.
                  If no value is provided, the Inferno session id will be used.
                DESCRIPTION
              },
              smart_jwk_set: {
                title: 'Provider JSON Web Key Set (JWKS)',
                description: <<~DESCRIPTION
                  The Bulk Data Submit Provider system's JSON Web Key Set
                  including the key(s) Inferno will need to verify signatures on
                  token requests made by the client. May be provided as either a
                  publicly accessible url containing the JWKS, or the raw JWKS
                  JSON.
                DESCRIPTION
              }
            }
          )

          test from: :smart_client_registration_bsca_verification,
               title: 'Verify Provider Client Registration'
        end
      end
    end
  end
end
