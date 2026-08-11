require_relative 'version'

module BulkDataTestKit
  class Metadata < Inferno::TestKit
    id :bulk_data_test_kit
    title 'Bulk Data Test Kit'
    suite_ids %w[
      bulk_data_v101
      bulk_data_v200
      bulk_data_v200_client
      bulk_data_submit_draft_recipient
      bulk_data_submit_draft_provider
    ]
    tags ['Bulk Data']
    last_updated ::BulkDataTestKit::LAST_UPDATED
    version ::BulkDataTestKit::VERSION
    maturity 'Low'
    authors ['Inferno Team']
    repo 'https://github.com/inferno-framework/bulk-data-test-kit'
    description <<~DESCRIPTION
        The Bulk Data Access Test Kit validates the conformance of a server
        implementation to a specified version of the
        [Bulk Data Access Implementation Guide](http://hl7.org/fhir/uv/bulkdata/).
        This Test Kit currently includes tests for
        [STU1](http://hl7.org/fhir/uv/bulkdata/STU1.0.1/) and
        [STU2](http://hl7.org/fhir/uv/bulkdata/STU2/) versions of this
        implementation guide.

        <!-- break -->

        This test kit is split into three different types of bulk data export:

        - All Patients: FHIR Operation to obtain a detailed set of FHIR resources
          of diverse resource types pertaining to all patients
        - Group of Patients: FHIR Operation to obtain a detailed set of FHIR
          resources of diverse resource types pertaining to all members of a specified
          Group
        - System Level Export: FHIR Operation to export data from a FHIR server,
          whether or not it is associated with a patient

        The Bulk Data Access Test Kit is built using the
        [Inferno Framework](https://inferno-framework.github.io/). The Inferno
        Framework is designed for reuse and aims to make it easier to build test
        kits for any FHIR-based data exchange.

        ## Reporting Issues

        Please report any issues with this set of tests in the
        [GitHub Issues](https://github.com/inferno-framework/bulk-data-test-kit/issues)
        section of this repository.
    DESCRIPTION
  end
end
