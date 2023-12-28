# exception_handler

This Dart package provides a robust framework for handling API calls, managing network connectivity, and processing exceptions in Flutter applications. It simplifies the process of making network requests, parsing responses, and handling various exceptions, making it an essential tool for Flutter developers.

## Features

- **API Handling:** Simplify your API calls with a structured approach, ensuring clean and maintainable code.
- **Exception Management:** Comprehensive exception handling, including network issues and HTTP errors, to improve the robustness of your applications.
<!-- - **Connectivity Plus Integration:** Utilize the Connectivity Plus package for reliable network status checking. -->
<!-- - **Custom Equatable Implementations:** Enhance the comparability of your objects with custom Equatable classes. -->

## Getting Started

To start using this package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  exception_handler: ^latest_version
```

Then, import it in your Dart files where you want to use it:

```dart
import 'package:exception_handler/exception_handler.dart';
```

## Usage

This package simplifies the process of making API calls and handling exceptions in Flutter apps.
Below are some examples to demonstrate how to use various features of the package.

### Basic API Call

Here's a simple example of making an API call and handling the response:

```dart
import 'package:exception_handler/exception_handler.dart';

// Example of making an API call
Future<void> fetchUserData() async {
    ApiHandler<UserModel> apiHandler = ApiHandler(
        call: () => dio.get('https://example.com/api/user'),
        parserModel: (data) => UserModel.fromJson(data),
    );

    TaskResult<UserModel> result = await DioExceptionHandler().callApi(apiHandler);

    result.when(
        success: (UserModel data) => print('UserModel data: $data'),
        failure: (exception) => print('Error: ${exception.toString()}'),
    );
}
```

Replace `UserModel` with the appropriate data model for your application.

### Advanced API Call with Custom Parser

Using a custom parser for complex API responses:

```dart
import 'package:exception_handler/exception_handler.dart';

Future<void> fetchComplexData() async {
    ApiHandler<ComplexData> apiHandler = ApiHandler(
        call: () => dio.get('https://example.com/api/complex'),
        parserModel: customParser,
    );

    TaskResult<ComplexData> result = await DioExceptionHandler().callApi(apiHandler);

    result.when(
        success: (ComplexData data) => print('Complex Data: $data'),
        failure: (exception) => print('Error: ${exception.toString()}'),
    );
}

ComplexData customParser(dynamic responseData) {
    // Custom parsing logic
    return ComplexData.fromResponse(responseData);
}
```

### Basic Exception Handling

Handling basic exceptions with logging information:

```dart
void handleApiCall() async {
    TaskResult<UserModel> result = await DioExceptionHandler().callApi(apiHandler);

    result.when(
        success: (UserModel data) => print('User data retrieved successfully: $data'),
        failure: (exception) {
            print('Exception occurred: ${exception.toString()}');
            // Additional logging or error handling
        },
    );
}
```

### Advanced Exception Handling with Specific Cases

Implementing detailed handling for each type of exception:

```dart
void advancedExceptionHandling() async {
    TaskResult<UserModel> result = await DioExceptionHandler().callApi(apiHandler);

    result.when(
        success: (UserModel data) => print('Fetched data: $data'),
        failure: (exception) {
            if (exception is DataNetworkException) {
                // Handle network-related exceptions
                handleNetworkException(exception);
            } else if (exception is DataHttpException) {
                // Handle HTTP-related exceptions
                handleHttpException(exception);
            } else if (exception is DataParseException) {
                // Handle parsing-related exceptions
                handleParseException(exception);
            } else if (exception is DataClientException) {
                // Handle client-side exceptions
                handleClientException(exception);
            } else {
                // Handle any other types of exceptions
                handleUnknownException(exception);
            }
        },
    );
}

void handleNetworkException(DataNetworkException exception) {
    print('Network Exception: ${exception.networkException}');
    // Additional logic for handling network exceptions
}

void handleHttpException(DataHttpException exception) {
    print('HTTP Exception: ${exception.httpException}');
    // Additional logic for handling HTTP exceptions
}

void handleParseException(DataParseException exception) {
    print('Parse Exception: ${exception.parseException}');
    // Additional logic for handling parsing exceptions
}

void handleClientException(DataClientException exception) {
    print('Client Exception: ${exception.clientException}');
    // Additional logic for handling client-side exceptions
}

void handleUnknownException(ExceptionState exception) {
    print('Unknown Exception: ${exception.toString()}');
    // Additional logic for handling unknown exceptions
}
```

In these methods, you can add specific actions that should be taken when each type of exception occurs.
For example, you might show different error messages to the user, log the error for further analysis, or try alternative approaches if possible.

These examples provide a structured approach to handle different kinds of exceptions that might occur during API interactions in a Flutter app, ensuring that each case is dealt with appropriately.

<!-- For more detailed and complex usage examples, please refer to the `/example` folder in this package. -->

### Contribution and Support

For contributing to the package, refer to the `CONTRIBUTING.md` file in the package repository. If you encounter any issues or require support, please file an issue on the repository's issue tracker.

## Additional Information

For more information on how to use this package, contribute to its development, or file issues, please visit [exception_handler](https://github.com/andgar2010/exception_handler). The package authors are committed to maintaining and improving this tool, and your feedback and contributions are greatly welcomed.
