# Specification: Extracting Test Failures from Buildkite

## Overview
The goal is to create a script that interacts with the Buildkite REST API to extract test failure details from a specific job, named "RSpec," within a build. The script will produce a JSON output containing the `file`, `line`, and `error_message` for each test failure.

## Requirements
- **Buildkite API Integration**: The script will interact with the Buildkite REST API to retrieve logs and job details.
- **Job Filtering**: The script will specifically target jobs named "RSpec," which contain the test failures.
- **Output Format**: The script will output the test failure details in JSON format, structured with keys `file`, `line`, and `error_message`.
- **Graceful Failure Handling**: If the "RSpec" job is not found, the script should fail gracefully, displaying a list of available jobs, and returning an empty JSON array.

## Architecture & Workflow
1. **Authentication**:
   - The script will use the API token stored in `~/.buildkite/config.yml` for authentication.
   - The token should be scoped to access the relevant Buildkite organization, pipeline, and job data.

2. **API Endpoints**:
   - Retrieve job details and logs using:
     - `GET /organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs`
     - `GET /organizations/{org.slug}/pipelines/{pipeline.slug}/builds/{build.number}/jobs/{job.id}/log`
   - The first endpoint lists all jobs for a build, allowing the script to identify the "RSpec" job.
   - The second endpoint retrieves the logs for the "RSpec" job, which will contain the test results.

3. **Log Parsing**:
   - The script will parse the log of the "RSpec" job to identify failed test cases. The test failures will typically be in a format like:
     - `File: /path/to/file_spec.rb`
     - `Line: 42`
     - `Failure/Error: expected something but got something else`
   - Each failure will be extracted and stored as an object in the output JSON.

4. **Graceful Error Handling**:
   - If the "RSpec" job is not found, the script will list the available jobs and exit without crashing. It will output an empty JSON array (`[]`).

## Data Handling
- **Test Failures**:
  - Each failure will be extracted with the following details:
    - `file`: The path to the spec file containing the failure.
    - `line`: The line number in the file where the failure occurred.
    - `error_message`: The failure message or error description.
- **Output Structure**:
  ```json
  [
    {
      "file": "/path/to/file_spec.rb",
      "line": 42,
      "error_message": "expected something but got something else"
    },
    ...
  ]
  ```

## Error Handling Strategy
- **Missing "RSpec" Job**:
  - If no "RSpec" job is found, the script will list all available jobs and display a message like:
    ```bash
    "No 'RSpec' job found. Available jobs: [Job1, Job2, Job3]"
    ```
  - The script will then return an empty JSON array.
- **API Errors**:
  - The script will handle any API-related errors (e.g., rate limits, authentication issues) and log appropriate error messages without crashing.

## Testing Plan
1. **Unit Tests**:
   - Mock the API responses for both job listing and job logs.
   - Test parsing logic for various test failure formats.
2. **Integration Tests**:
   - Run the script on a real Buildkite pipeline with known test failures in the "RSpec" job.
   - Validate the output format and ensure accuracy of failure data (e.g., correct `file`, `line`, and `error_message`).
3. **Edge Cases**:
   - Test when no failures are present in the "RSpec" job (the output should be an empty array).
   - Test when the "RSpec" job does not exist (output an empty JSON array and list available jobs).

## Next Steps
1. **Set Up API Access**: Ensure the API token has the appropriate permissions and is available in the configuration file.
2. **Implement Script**: Develop the script to interact with the API, fetch job details, parse logs, and output failures in the specified JSON format.
3. **Run Tests**: Implement the test suite and run it on real data to verify accuracy.
