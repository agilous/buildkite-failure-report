# Project ToDo List

This is a comprehensive checklist for building the project in Ruby. Use this as a guide to track your progress and ensure all steps are completed.

---

## **Project Setup**
- [ ] Create a new directory for the project.
- [ ] Initialize a Git repository.
- [ ] Set up a `Gemfile` with the following gems:
  - `httparty` (for API requests)
  - `yaml` (for parsing the config file)
  - `rspec` (for testing)
  - `json` (for formatting output)
- [ ] Run `bundle install` to install dependencies.
- [ ] Create the project structure:
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
- [ ] Add a `.gitignore` file to exclude unnecessary files (e.g., `Gemfile.lock`, `.DS_Store`, etc.).
- [ ] Write a basic `README.md` with a project description.

---

## **Authentication**
- [ ] Create a method in `lib/main.rb` to read the Buildkite API token from `~/.buildkite/config.yml`.
- [ ] Use the `yaml` library to parse the YAML file.
- [ ] Write an RSpec test in `spec/main_spec.rb` to mock the config file and verify the token is read correctly.
- [ ] Implement error handling for:
  - Missing config file.
  - Malformed YAML file.
  - Missing or invalid API token.

---

## **Fetch Job Details from Buildkite API**
- [ ] Create a method in `lib/main.rb` to fetch job details using the Buildkite API.
- [ ] Use `HTTParty` to make the API request.
- [ ] Write an RSpec test to mock the API response and verify the method works correctly.
- [ ] Implement error handling for:
  - API rate limits.
  - Authentication errors.
  - Network issues.

---

## **Filter for the "RSpec" Job**
- [ ] Create a method in `lib/main.rb` to filter the job list for the "RSpec" job.
- [ ] Write an RSpec test to mock a list of jobs and verify the filtering logic.
- [ ] Implement graceful error handling if the "RSpec" job is not found:
  - Display a list of available jobs.
  - Return an empty JSON array.

---

## **Fetch Logs for the "RSpec" Job**
- [ ] Create a method in `lib/main.rb` to fetch logs for the "RSpec" job using the Buildkite API.
- [ ] Use `HTTParty` to make the API request.
- [ ] Write an RSpec test to mock the log response and verify the method works correctly.
- [ ] Implement error handling for:
  - API errors when fetching logs.
  - Missing or empty logs.

---

## **Parse Logs to Extract Test Failures**
- [ ] Create a method in `lib/main.rb` to parse the logs and extract test failures.
- [ ] Write RSpec tests for various log formats to ensure the parsing logic is robust.
- [ ] Implement error handling for:
  - Malformed logs.
  - Logs with no test failures.

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