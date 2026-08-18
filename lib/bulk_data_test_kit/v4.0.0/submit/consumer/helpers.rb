# frozen_string_literal: true

require_relative '../shared/submission_status'
require_relative '../shared/submitter_identifier'

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        module Helpers
          def submit_parameters(submission_id, base_url, status: nil, manifest_url: nil, oauth_metadata_url: nil)
            params = submission_identification_parameters(submission_id)

            params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                      name: 'fhirBaseUrl',
                                                                      valueUrl: base_url
            })

            unless status.nil?
              status_coding = FHIR::R4::Coding.new({
                                                      system: Shared::SubmissionStatus::SYSTEM,
                                                      code: status
                                                    })

              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'submissionStatus',
                                                                        # http://hl7.org/fhir/uv/bulkdata/ValueSet/submission-status
                                                                        valueCoding: status_coding
                                                                      })
            end

            unless manifest_url.nil?
              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'manifestUrl',
                                                                        valueUrl: manifest_url
                                                                      })
            end

            unless oauth_metadata_url.nil?
              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'oauthMetadataUrl',
                                                                        valueUrl: oauth_metadata_url
                                                                      })
            end

            params
          end

          def status_parameters(submission_id)
            submission_identification_parameters(submission_id)
          end

          private

          def submission_identification_parameters(submission_id)
            params = FHIR::R4::Parameters.new
            submitter_identifier = FHIR::R4::Identifier.new(
              system: Shared::SubmitterIdentifier::SYSTEM,
              value: Shared::SubmitterIdentifier::VALUE
            )

            params.parameter << FHIR::R4::Parameters::Parameter.new(
              name: 'submitter',
              valueIdentifier: submitter_identifier
            )

            params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                      name: 'submissionId',
                                                                      valueString: submission_id
                                                                    })

            params
          end
        end
      end
    end
  end
end
