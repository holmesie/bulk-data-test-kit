# frozen_string_literal: true

module BulkDataTestKit
  module BulkDataV400
    module Submit
      module Consumer
        module Helpers
          def submit_parameters(submission_id, base_url, status: nil, manifest_url: nil, oauth_metadata_url: nil)
            params = FHIR::R4::Parameters.new

            params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                      name: 'submitter',
                                                                      valueIdentifier: FHIR::R4::Identifier.new({ value: 'test' })
                                                                    })

            params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                      name: 'submissionId',
                                                                      valueString: submission_id
                                                                    })

            params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                      name: 'fhirBaseUrl', # flame using FHIRBaseUrl
                                                                      valueString: base_url
                                                                    })

            unless status.nil?
              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'submissionStatus',
                                                                        # http://hl7.org/fhir/uv/bulkdata/ValueSet/submission-status
                                                                        valueCoding: FHIR::R4::Coding.new({ code: status })
                                                                      })
            end

            unless manifest_url.nil?
              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'manifestUrl',
                                                                        valueString: manifest_url
                                                                      })
            end

            unless oauth_metadata_url.nil?
              params.parameter << FHIR::R4::Parameters::Parameter.new({
                                                                        name: 'oauthMetadataUrl',
                                                                        valueString: oauth_metadata_url
                                                                      })
            end

            params
          end
        end
      end
    end
  end
end
