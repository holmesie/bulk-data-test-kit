# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Shared
        module SubmissionStatus
          SYSTEM = 'http://hl7.org/fhir/event-status'
          CODES = %w[in-progress completed stopped].freeze
        end
      end
    end
  end
end
