The Bulk Data Submit Provider test suite validates the conformance of a provider system
to the [Draft Bulk Submit IG](https://hackmd.io/@argonaut/rJoqHZrPle).

## Scope

These tests are a **DRAFT** intended to allow implementers to perform
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

You can run the data provider and data recipient suites against each other to
see how the tests work:

1. Start a session in the Bulk Data Submit Draft Provider suite.
1. Select the "Demo: Run Against the Recipient Suite" preset.
1. Click the "Run All Tests" button.
1. In another browser tab, start a session in the Bulk Data Submit Draft
   Recipient suite.
1. Select the "Demo: Run Against the Provider Suite" preset.
1. Click the "Run All Tests" button.
1. Click the link in the modal to indicate that the workflow has completed.
1. In the provider suite session, click the link in the modal to indicate that
   the workflow has completed.

### Known Limitations

This test suite is in a very early state, and a lot of functionality is missing
or incomplete.

* Submit Operation
  * Unhandled parameters - The test suite currently ignores the following
    parameters:
    * `aborted` status
    * `replacesManifestUrl`
    * `outputFormat`
    * `fileRequestHeader`
    * `fileEncryptionKey`
  * Only supports SMART Backend Services authorization
* Polling Request
  * Does not support adding errors to the export manifest
* File Downloads
  * Additional request headers and file encryption are not supported
* Request Validation
  * The tests which verify that requests for OAuth metadata, an access token,
    manifests, and files are made are currently just placeholders. They verify
    that requests were made, but do not perform any validation of the content of
    the requests.
