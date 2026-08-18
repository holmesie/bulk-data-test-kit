The Bulk Submit Data Provider test suite validates a Data Provider against
the [Bulk Data Access v4.0.0 Submit specification](https://build.fhir.org/ig/HL7/bulk-data/branches/argo25/en/submit.html).

## Scope

These tests are a **PREVIEW** intended to allow implementers to perform
preliminary checks of their systems against the requirements stated for Bulk Submit actors
and [provide feedback](https://github.com/inferno-framework/bulk-data-test-kit/issues)
on the tests. Future versions of these tests may verify other
requirements and may change the test verification logic.

## Running the Tests

### Quick Start

Bulk data access requires the use of SMART Backend Services for authentication.
In order to interact with Inferno's simulated bulk server, the tester must provide
the JSON Web Key Set (JWKS) containing the asymmetric signing key in the
**SMART JSON Web Key Set (JWKS)** input as either a URL that resolves
to a JWKS or a raw JWKS in JSON format. Additionally, testers may provide
a **Client Id** if they want their client assigned a specific one.

Once the client has been registered, it will need to obtain an access token
following the SMART Backend Services flow and use it when making bulk data requests.
If the client is not able to obtain an access token, see the *Demonstration* section
below for how to use the SMART server tests to obtain an access token that the client can use.

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
