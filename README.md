# exception_handler

| Local                             | Repo Git                                                                                                            | Coveralls                                                                                                                                                                        |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![Coverage](./coverage_badge.svg) | ![Coverage](https://raw.githubusercontent.com/andgar2010/exception_handler/master/coverage_badge.svg?sanitize=true) | [![Coverage Status](https://coveralls.io/repos/github/andgar2010/exception_handler/badge.svg?branch=main)](https://coveralls.io/github/andgar2010/exception_handler?branch=main) |

This Dart package provides a robust framework for handling API calls and processing exceptions in Flutter applications.
It simplifies the process of making network requests, parsing responses, and handling various exceptions, making it an essential tool for Flutter developers.

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

```dartimport 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';
```

## Usage

This package simplifies the process of making API calls and handling exceptions in Flutter apps.
Below are some examples to demonstrate how to use various features of the package.

## Fetching and Enhanced Parsing of JSON Data with Dio and a Custom Extension

In our latest update, version 2.0.0, we have streamlined the process of fetching data from a REST API and converting it into a Dart object. This improvement utilizes Dio, a powerful HTTP client for Dart, enabling us to simplify our codebase while maintaining both efficiency and readability.

Harness the power of Dio for handling HTTP requests in your Dart or Flutter applications, now further simplified with a custom `.fromJson()` extension method. This enhancement allows you to directly fetch data from your endpoints and convert them into Dart objects through one fluid operation, reducing boilerplate code and improving readability.

### Defining a Model

To begin, create your data model with a factory constructor designed for JSON deserialization. Below is an example of a `UserModel`:

```dart
class UserModel {
  final int id;
  final String name;
  final String email;

  UserModel({required this.id, required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}
```

With the custom extension in place, fetching data and parsing it into a Dart object becomes straightforward. Here's how to implement it in your application:

```dart
Future<void> main() async {
  Dio dio = Dio(); // Instantiate Dio
  final int userId = 1; // Example user ID

  final ResultState<UserModel> resultState = await dio
      .get('https://jsonplaceholder.typicode.com/users/$userId')
      .fromJson(UserModel.fromJson);

  print(resultState.data); // Utilize the fetched and parsed userModel data
  final Widget uiWidget = switch (resultState) {
    SuccessState<UserModel> success =>
      UiUserWidget(success.data), // Using a hypothetical UiUserWidget for displaying user data
    FailureState<UserModel> failure =>
      UiExceptionWidget(failure.exception), // Using a hypothetical UiExceptionWidget for handling errors
  };
```

### Basic API Call

Here's a simple example of making an API call and handling the response:

```dart
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';

// Example of making an API call
Future<void> fetchUserData() async {
    final ApiHandler<Response, UserModel> apiHandler = ApiHandler(
        apiCall: () => dio.get('https://example.com/api/user'),
        parserModel: (data) => UserModel.fromJson(data),
    );

    // ResultState<UserModel> result = await DioExceptionHandler().callApi(apiHandler); // v1.x.x
    ResultState<UserModel> result = await DioExceptionHandler.callApi_(apiHandler);

    switch (result) {
      case SuccessState<UserModel>(:UserModel data):
        print('UserModel data: $data');
      case FailureState<UserModel>(:ExceptionState exception):
        print('Error: ${exception.toString()}');
    }
}
```

Replace `UserModel` with the appropriate data model for your application.

### Advanced API Call with Custom Parser

Using a custom parser for complex API responses:

```dart
import 'package:dio/dio.dart';
import 'package:exception_handler/exception_handler.dart';

Future<void> fetchComplexData() async {
    final ApiHandler<Response, ComplexData> apiHandler = ApiHandler(
        apiCall: () => dio.get('https://example.com/api/complex'),
        parserModel: customParser,
    );

    // ResultState<ComplexData> result = await DioExceptionHandler().callApi(apiHandler); // v1.x.x
    ResultState<ComplexData> result = await DioExceptionHandler.callApi_(apiHandler);

    switch (result) {
      case SuccessState<ComplexData>(:ComplexData data):
        print('Complex Data: $data');
      case FailureState<ComplexData>(:ExceptionState exception):
        print('Error: ${exception.toString()}');
    }
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
    // ResultState<UserModel> result = await DioExceptionHandler().callApi(apiHandler); // v1.x.x
    ResultState<UserModel> result = await DioExceptionHandler.callApi_(apiHandler);

    switch (result) {
      case SuccessState<UserModel>(:UserModel data):
        print('User data retrieved successfully: $data');
      case FailureState<UserModel>(:ExceptionState exception):
        print('Exception occurred: ${exception.toString()}');
        // Additional logging or error handling
    }
}
```

### Advanced Exception Handling with Specific Cases

Implementing detailed handling for each type of exception:

```dart
void advancedExceptionHandling() async {
    // ResultState<UserModel> result = await DioExceptionHandler().callApi(apiHandler); // v1.x.x
    ResultState<UserModel> result = await DioExceptionHandler.callApi_(apiHandler);

    switch (result) {
      case SuccessState<UserModel>(:UserModel data):
        print('Fetched data: $data');

      case FailureState<UserModel>(:ExceptionState exception):
        _handleExceptions(exception);
    }

}

void _handleExceptions(ExceptionState exception) {
  switch (exception) {
    case DataClientExceptionState():
      // Handle client-side exceptions
      handleClientException(exception);
    case DataParseExceptionState():
      // Handle parsing-related exceptions
      handleParseException(exception);
    case DataHttpExceptionState():
      // Handle HTTP-related exceptions
      handleHttpException(exception);
    case DataNetworkExceptionState():
      // Handle network-related exceptions
      handleNetworkException(exception);
    case _:
      // Handle any other types of exceptions
      handleUnknownException(exception);
  }
}

void handleNetworkException(DataNetworkExceptionState exception) {
    print('Network Exception: ${exception.networkException}');
    // Additional logic for handling network exceptions
}

void handleHttpException(DataHttpExceptionState exception) {
    print('HTTP Exception: ${exception.httpException}');
    // Additional logic for handling HTTP exceptions
}

void handleParseException(DataParseExceptionState exception) {
    print('Parse Exception: ${exception.parseException}');
    // Additional logic for handling parsing exceptions
}

void handleClientException(DataClientExceptionState exception) {
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
