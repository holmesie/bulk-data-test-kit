# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Shared
        module JWKS
          DEFAULT_JWKS_PATH = File.expand_path('../../../bulk_data_jwks.json', __dir__)

          def jwks_json
            bulk_data_jwks = JSON.parse(
              File.read(ENV.fetch('BULK_DATA_JWKS', DEFAULT_JWKS_PATH))
            )

            @jwks_json ||= JSON.pretty_generate(
              { keys: bulk_data_jwks['keys'].select { |key| key['key_ops']&.include?('verify') } }
            )
          end

          def jwks_route_handler
            ->(_env) { [200, { 'Content-Type' => 'application/json' }, [jwks_json]] }
          end
        end
      end
    end
  end
end
