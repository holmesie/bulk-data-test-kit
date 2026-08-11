# frozen_string_literal: true

module BulkDataTestKit
  module Submit
    module Draft
      module Provider
        class SubmitAbortedGroup < Inferno::TestGroup
          title 'Bulk Submit Operation - Aborted'

          description %(
            This group verifies that a provider successfully made at least one valid completion submission.
          )

          id :bulk_data_submit_provider_submit_aborted

          run_as_group

          optional

          test do
            title 'Aborted Submit Request Was Made'

            description %(
              This test verifies that at least one `aborted` submit request was made.
            )

            run do
              submissions = load_tagged_requests(SUBMIT_TAG)
              found_aborted = false
              submissions.each do |request|
                parameters = FHIR.from_contents(request.request_body)
                status_parameters = parameters.parameter.filter do |parameter|
                  parameter.name == 'submissionStatus'
                end
                status_parameters.each do |status_parameter|
                  found_aborted = true if status_parameter.valueCoding.code == 'aborted'
                end
              end

              skip_if !found_aborted, 'An `aborted` submission was not detected.'
            end
          end
        end
      end
    end
  end
end
