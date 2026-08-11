# Bulk Data Access Test Kit

The **Bulk Data Access Test Kit** is a testing tool that will demonstrate the
ability to exporting bulk data from a FHIR server to a pre-authorized client
following the requirements from the FHIR Bulk Data Access IG
[v1.0.1](http://hl7.org/fhir/uv/bulkdata/STU1.0.1) and
[v2.0.0](http://build.fhir.org/ig/HL7/bulk-data). This test kit will test the
APIs through which an authenticated and authorized client may request a Bulk
Data Export from a server, receive status information regarding progress in the
generation of the requested files, and retrieve these files.

This test kit is split into three different types of bulk data export: 
  - All Patients: FHIR Operation to obtain a detailed set of FHIR resources of
    diverse resource types pertaining to all patients
  - Group of Patients: FHIR Operation to obtain a detailed set of FHIR resources
    of diverse resource types pertaining to all members of a specified Group
  - System Level Export: FHIR Operation to export data from a FHIR server,
    whether or not it is associated with a patient

## Bulk Submit Preview

The test kit also includes preliminary suites for the
[Bulk Data Access v4.0.0 Submit specification](https://build.fhir.org/ig/HL7/bulk-data/branches/argo25/en/submit.html):

- **Data Provider**: Inferno simulates a Data Consumer while the system under
  test submits data and reports submission status.
- **Data Consumer**: Inferno simulates a Data Provider while the system under
  test accepts submissions and retrieves submitted data.

These suites are previews with incomplete coverage and may change as support
for the specification is expanded.

The BulkData Access Test Kit is built using the [Inferno
Framework](https://inferno-framework.github.io/).  The Inferno Framework is
designed for reuse and aims to make it easier to build test kits for any
FHIR-based data exchange.

## Reporting Issues

Please report any issues with this set of tests in the [GitHub
Issues](https://github.com/inferno-framework/bulk-data-test-kit/issues)
section of this repository.

## Instructions

It is highly recommended that you use [Docker](https://www.docker.com/) to run
these tests.

- Clone this repo.
- Run `setup.sh` in this repo.
- Run `run.sh` in this repo.
- Navigate to `http://localhost`. The Bulk Data test suite will be available.


## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
