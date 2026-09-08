The Bulk Submit Data Consumer test suite validates a Data Consumer
implementation of the [Bulk Submit Operation](https://hl7.org/fhir/uv/bulkdata/4.0.0-202609-ballot/en/)
within the Bulk Data Access v4.0.0 IG.

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
1. When the Data Consumer suite pauses after sending `completed`, advance the
   Data Provider suite from its initial wait.
1. The Data Provider suite will retrieve the manifest and file synchronously,
   then pause while waiting for the final status poll.
1. Advance the Data Consumer suite. It will make one final status poll.
1. After that poll completes, advance the Data Provider suite to finish the
   paired workflow.
