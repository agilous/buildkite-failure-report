# Step-by-Step Blueprint for Building the Project

## 1. **Set Up the Project Environment**
   - **Step 1.1**: Create a new directory for the project.
   - **Step 1.2**: Initialize a new Git repository.
   - **Step 1.3**: Set up a `Gemfile` for managing dependencies.
   - **Step 1.4**: Install necessary gems (`httparty`, `yaml`, `rspec`).
   - **Step 1.5**: Create a basic project structure:
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

## 2. **Implement Authentication**
   - **Step 2.1**: Create a method to read the Buildkite API token from `~/.buildkite/config.yml`.
   - **Step 2.2**: Write an RSpec test to mock the config file and verify the token is read correctly.
   - **Step 2.3**: Implement error handling for missing or malformed config files.

## 3. **Fetch Job Details from Buildkite API**
   - **Step 3.1**: Create a method to fetch job details using the Buildkite API with `HTTParty`.
   - **Step 3.2**: Write an RSpec test to mock the API response and verify the method works correctly.
   - **Step 3.3**: Implement error handling for API errors (e.g., rate limits, authentication issues).

## 4. **Filter for the "RSpec" Job**
   - **Step 4.1**: Create a method to filter the job list for the "RSpec" job.
   - **Step 4.2**: Write an RSpec test to mock a list of jobs and verify the filtering logic.
   - **Step 4.3**: Implement graceful error handling if the "RSpec" job is not found.

## 5. **Fetch Logs for the "RSpec" Job**
   - **Step 5.1**: Create a method to fetch logs for the "RSpec" job using the Buildkite API.
   - **Step 5.2**: Write an RSpec test to mock the log response and verify the method works correctly.
   - **Step 5.3**: Implement error handling for API errors when fetching logs.

## 6. **Parse Logs to Extract Test Failures**
   - **Step 6.1**: Create a LogParserService class in lib/services/log_parser_service.rb to handle RSpec test failure extraction.
   - **Step 6.2**: The service should include methods for parsing raw log content, identifying test failure blocks, and extracting failure details (file, line, message).
   - **Step 6.3**: Write comprehensive RSpec tests in spec/services/log_parser_service_spec.rb to verify parsing of different RSpec failure formats, handling of multi-line error messages, ANSI color codes, and edge cases.
   - **Step 6.4**: Implement robust error handling for malformed logs, missing information, and invalid data.
   - **Step 6.5**: The service should return structured data that can be easily converted to JSON in the next step.

## 7. **Format and Output Test Failures as JSON**
   - **Step 7.1**: Create a method to format the extracted test failures into the specified JSON structure using `json` gem.
   - **Step 7.2**: Write an RSpec test to verify the JSON output matches the expected format.
   - **Step 7.3**: Implement error handling for cases where no failures are found.

## 8. **Integrate All Components**
   - **Step 8.1**: Create a main script that ties all the components together.
   - **Step 8.2**: Write an integration test to verify the entire workflow.
   - **Step 8.3**: Implement final error handling and logging.

## 9. **Final Testing and Validation**
   - **Step 9.1**: Run all RSpec tests.
   - **Step 9.2**: Validate the script against a real Buildkite pipeline.
   - **Step 9.3**: Address any issues found during testing.

## 10. **Documentation and Finalization**
   - **Step 10.1**: Update the README with usage instructions.
   - **Step 10.2**: Ensure all code is well-documented.
   - **Step 10.3**: Finalize the project and prepare for deployment.

---

## Iterative Chunks and Prompts for Code Generation

### **Chunk 1: Set Up the Project Environment**
```text
Set up a `Gemfile` for managing dependencies and install the necessary gems (`httparty`, `yaml`, `rspec`). Create a basic project structure with `lib/main.rb` and `spec/main_spec.rb`. Add a `.gitignore` file to exclude unnecessary files. Write a simple README.md to describe the project.
```

### **Chunk 2: Implement Authentication**
```text
Write a method to read the Buildkite API token from `~/.buildkite/config.yml`. Use the `yaml` library to parse the YAML file. Write an RSpec test to mock the config file and verify the token is read correctly. Implement error handling for cases where the config file is missing or malformed.
```

### **Chunk 3: Fetch Job Details from Buildkite API**
```text
Create a method to fetch job details using the Buildkite API with `HTTParty`. Write an RSpec test to mock the API response and verify the method works correctly. Implement error handling for API errors such as rate limits or authentication issues.
```

### **Chunk 4: Filter for the "RSpec" Job**
```text
Create a method to filter the job list for the "RSpec" job. Write an RSpec test to mock a list of jobs and verify the filtering logic. Implement graceful error handling if the "RSpec" job is not found, and display a list of available jobs.
```

### **Chunk 5: Fetch Logs for the "RSpec" Job**
```text
Create a method to fetch logs for the "RSpec" job using the Buildkite API. Write an RSpec test to mock the log response and verify the method works correctly. Implement error handling for API errors when fetching logs.
```

### **Chunk 6: Parse Logs to Extract Test Failures**
```text
Create a LogParserService class in lib/services/log_parser_service.rb to handle RSpec test failure extraction. The service should include methods for parsing raw log content, identifying test failure blocks, and extracting failure details (file, line, message). Write comprehensive RSpec tests in spec/services/log_parser_service_spec.rb to verify parsing of different RSpec failure formats, handling of multi-line error messages, ANSI color codes, and edge cases. Implement robust error handling for malformed logs, missing information, and invalid data. The service should return structured data that can be easily converted to JSON in the next step.
```

### **Chunk 7: Format and Output Test Failures as JSON**
```text
Create a method to format the extracted test failures into the specified JSON structure using the `json` gem. Write an RSpec test to verify the JSON output matches the expected format. Implement error handling for cases where no failures are found.
```

### **Chunk 8: Integrate All Components**
```text
Create a main script that ties all the components together. Write an integration test to verify the entire workflow. Implement final error handling and logging.
```

### **Chunk 9: Final Testing and Validation**
```text
Run all RSpec tests. Validate the script against a real Buildkite pipeline. Address any issues found during testing.
```

### **Chunk 10: Documentation and Finalization**
```text
Update the README with usage instructions. Ensure all code is well-documented. Finalize the project and prepare for deployment.
```

---

## Final Notes
Each prompt builds on the previous one, ensuring that the project progresses incrementally. Testing is prioritized at every step to ensure robustness. The final integration step ensures that all components work together seamlessly.