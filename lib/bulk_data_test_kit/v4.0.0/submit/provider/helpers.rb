# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Provider
        module Helpers
          def complete_manifest(request)
            {
              transactionTime: DateTime.now,
              request: request.url,
              requiresAccessToken: true,
              output: [],
              error: []
            }
          end
        end
      end
    end
  end
end
