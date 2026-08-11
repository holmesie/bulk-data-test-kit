The Bulk Submit Data Consumer test suite validates a Data Consumer against
the [Bulk Data Access v4.0.0 Submit specification](https://build.fhir.org/ig/HL7/bulk-data/branches/argo25/en/submit.html).

## Scope

These tests are a **PREVIEW** intended to allow implementers to perform
preliminary checks of their systems against the requirements stated for Bulk Submit actors
and [provide feedback](https://github.com/inferno-framework/bulk-data-test-kit/issues)
on the tests. Future versions of these tests may verify other
requirements and may change the test verification logic.

## Running the Tests

### Quick Start

These tests verify the behavior of a Data Consumer by simulating a Data
provider. The tests perform authorization, make a data submission, poll for the
submission status, and wait for the Data Consumer to retrieve the data.

First, the Data Consumer will likely need to register Inferno as a client. The
registered client id must be provided in the test inputs. A JWKS for Inferno to
use when signing requests can also be provided, or it will use a default key set
if none is provided. The FHIR endpoint of the Data Consumer and an ID to use for the
submission must also be provided, then the user can run the tests against the
Data Consumer system.

### Demonstration

You can run the Data Provider and Data Consumer suites against each other to
see how the tests work:

1. Start a session in the Bulk Data Access v4.0.0 Submit - Data Provider (Preview) suite.
1. Select the "Demo: Run Data Provider Against Inferno Data Consumer" preset.
1. Click the "Run All Tests" button.
1. In another browser tab, start a session in the Bulk Data Access v4.0.0
   Submit - Data Consumer (Preview) suite.
1. Select the "Demo: Run Data Consumer Against Inferno Data Provider" preset.
1. Click the "Run All Tests" button.
1. Click the link in the modal to indicate that the workflow has completed.
1. In the provider suite session, click the link in the modal to indicate that
   the workflow has completed.

### Known Limitations

This test suite is in a very early state, and a lot of functionality is missing
or incomplete.

* Submit Operation
  * Unsupported Parameters - The test suite does not test the following
    parameters as part of its submissions
    * `aborted` status
    * `replacesManifestUrl`
    * `outputFormat`
    * `fileRequestHeader`
    * `fileEncryptionKey`
  * Only supports SMART Backend Services authorization
* File Downloads
  * Additional request headers and file encryption are not supported
* Request Validation
  * The tests which verify that requests for an access token, manifests, and
    files are made are currently just placeholders. They verify that requests
    were made, but do not perform any validation of the content of the requests.
* Some use cases may require the ability to include resources conforming to
  specific profiles in the submission. This would likely require the ability for
  users to provide the data to be submitted as inputs.
