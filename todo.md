# Project ToDo List

This is a comprehensive checklist for building the project in Ruby. Use this as a guide to track your progress and ensure all steps are completed.

---

## **Project Setup**
- [✅] Create a new directory for the project.
- [✅] Initialize a Git repository.
- [✅] Set up a `Gemfile` with the following gems:
  - `csv` (for HTTParty)
  - `httparty` (for API requests)
  - `rspec` (for testing)
  - `solargraph` (for code completion)
- [✅] Run `bundle install` to install dependencies.
- [✅] Create the project structure:
  ```
  buildkite_test_failures/
  ├── lib/
  │   └── main.rb
  ├── spec/
  │   └── main_spec.rb
  ├── .gitignore
  ├── Gemfile
  ├── Gemfile.lock
  └── README.md
  ```
- [✅] Add a `.gitignore` file to exclude unnecessary files (e.g., `Gemfile.lock`, `.DS_Store`, etc.).
- [✅] Write a basic `README.md` with a project description.

---

## **Authentication**
- [✅] Create `BuildkiteConfig` class in `lib/buildkite_config.rb` to handle configuration.
- [✅] Implement method to read the Buildkite API token from `~/.buildkite/config.yml`.
- [✅] Use the `yaml` library to parse the YAML file.
- [✅] Write RSpec tests in `spec/buildkite_config_spec.rb` to verify token reading functionality.
- [✅] Implement error handling for:
  - Missing config file.
  - Malformed YAML file.
  - Missing or invalid API token.

---

## **Fetch Job Details from Buildkite API**
- [✅] Create a method in `lib/main.rb` to fetch job details using the Buildkite API.
- [✅] Use `HTTParty` to make the API request.
- [✅] Write an RSpec test to mock the API response and verify the method works correctly.
- [✅] Implement error handling for:
  - API rate limits.
  - Authentication errors.
  - Network issues.

---

## **Filter for the "RSpec" Job**
- [✅] Create service classes to filter the job list for the "RSpec" job:
  - `JobFilterService` for core filtering logic
  - Integration with `BuildkiteJobService` for API handling
- [✅] Write comprehensive RSpec tests to verify the filtering logic:
  - Test successful job finding
  - Test handling of missing jobs
  - Test edge cases (empty lists, nil values, duplicates)
- [✅] Implement graceful error handling if the "RSpec" job is not found:
  - Display a sorted list of available jobs
  - Raise informative error with available jobs list

---

## **Fetch Logs for the "RSpec" Job**
- [✅] Create a method in `lib/services/buildkite_job_service.rb` to fetch logs for the "RSpec" job using the Buildkite API.
- [✅] Use `HTTParty` to make the API request.
- [✅] Write an RSpec test to mock the log response and verify the method works correctly:
  - Test successful JSON response handling
  - Test non-JSON response handling
  - Test error cases
- [✅] Implement error handling for:
  - API errors when fetching logs (401, 429, 500)
  - Missing or empty logs (404)
  - Network errors
  - Malformed responses

---

## **Parse Logs to Extract Test Failures**
- [ ] Create `LogParserService` in `lib/services/log_parser_service.rb` to handle RSpec test failure extraction:
  - Method to parse raw log content
  - Method to identify test failure blocks
  - Method to extract failure details (file, line, message)
- [ ] Write comprehensive RSpec tests in `spec/services/log_parser_service_spec.rb`:
  - Test parsing of different RSpec failure formats
  - Test handling of multi-line error messages
  - Test handling of ANSI color codes in logs
  - Test edge cases (empty logs, no failures, malformed output)
- [ ] Implement error handling for:
  - Malformed or unexpected log formats
  - Missing or corrupted failure information
  - Invalid line numbers or file paths
  - Logs with no test failures (return empty array)

---

## **Format and Output Test Failures as JSON**
- [ ] Create a method in `lib/main.rb` to format the extracted test failures into the specified JSON structure.
- [ ] Use the `json` gem to generate the JSON output.
- [ ] Write an RSpec test to verify the JSON output matches the expected format:
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
- [ ] Implement error handling for cases where no failures are found (return an empty JSON array).

---

## **Integrate All Components**
- [ ] Create a main script in `lib/main.rb` that ties all the components together:
  1. Read the API token.
  2. Fetch job details.
  3. Filter for the "RSpec" job.
  4. Fetch logs for the "RSpec" job.
  5. Parse logs to extract test failures.
  6. Format and output test failures as JSON.
- [ ] Write an integration test in `spec/main_spec.rb` to verify the entire workflow.
- [ ] Implement final error handling and logging for the main script.

---

## **Final Testing and Validation**
- [ ] Run all RSpec tests:
  - Unit tests for individual methods.
  - Integration tests for the full workflow.
- [ ] Validate the script against a real Buildkite pipeline:
  - Test with a pipeline that has known test failures.
  - Test with a pipeline that has no "RSpec" job.
  - Test with a pipeline that has no test failures.
- [ ] Address any issues found during testing.

---

## **Documentation and Finalization**
- [ ] Update the `README.md` with:
  - Project description.
  - Installation instructions.
  - Usage instructions.
  - Example JSON output.
  - Contribution guidelines.
- [ ] Ensure all code is well-documented with comments.
- [ ] Finalize the project and prepare for deployment:
  - Commit all changes to Git.
  - Push the repository to a remote Git hosting service (e.g., GitHub).

---

## **Optional Enhancements**
- [ ] Add a command-line interface (CLI) for easier usage.
- [ ] Add support for pagination when fetching jobs or logs.
- [ ] Add logging for debugging purposes.
- [ ] Add support for custom configuration paths (e.g., allow users to specify a different config file location).

---

### Notes
- Check off each task as you complete it.
- Use this checklist to ensure no steps are missed and the project is built incrementally.
- Prioritize testing at every step to ensure robustness.