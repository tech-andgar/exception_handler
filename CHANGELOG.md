# Changelog

## [3.0.1] - 2024-03-26

### Fixed - 3.0.1

* reverted to using 'isolates.dart' from utils exports to framework for web compatibility.

## [3.0.0] - 2024-03-26

### Changed - 3.0.0

* **Dependency**: Updated the `dio` package version from `5.4.1` to `5.4.2`.
* **Dependency**: Updated the `connectivity_plus` plugin from version `^5.0.2` to `^6.0.1`.

### Breaking Changes - 3.0.0

* **SDK and Flutter versions**:
  Increased the minimum Dart version from `>=3.0.0 <4.0.0` to `>=3.3.0 <4.0.0` and the Flutter version from `>=3.0.0` to `>=3.19.0` in the `pubspec.yaml` file. This change may affect developers working on older versions of the SDK or Flutter.

### Added - 3.0.0

* **Code Quality**: Enhanced linter rules for improved code quality, enabling previously commented-out linting rules, adding new ones, and notably, the addition of metrics with specific complexity parameters to drive better code practices.

## [2.0.2] - 2024-03-11

Overall, these changes primarily revolve around improving exception handling and string formatting versatility.

### Changed - 2.0.2

* Exception message handling has been improved for better readability wherein the handler now uses the string representation of exceptions.
* String formatting logic in the CustomEquatable class has been improved to handle null and empty values more gracefully.
* More descriptive messages in place of direct position to parameters of extends ExceptionState calls have been introduced. `class DataXXXXXExceptionState<TModel> extends ExceptionState`

    v1.x.x

    ```dart
    FailureState(
      DataNetworkExceptionState(
        NetworkException.noInternetConnection,
        StackTrace.current,
      ),
    ),
    ```

    v2.x.x

    ```dart
    FailureState(
      DataNetworkExceptionState(
        message: 'NetworkException.noInternetConnection',
        stackTrace: StackTrace.current,
    ),
  ),
  ```

### Added - 2.0.2

* More specific details about the exceptions including DioException information in the test cases for exception handling.
* `message` to namedProps in DataHttpExceptionState for more detailed logging.

### Fixed - 2.0.2

* An issue with trailing commas in the output string of the CustomEquatable class.

## [2.0.1] - 2024-03-10

### Changed - 2.0.1

* revert: renamed method direct DioExceptionHandler.callApi to DioExceptionHandler.callApi_ for compatibility v1 because method original use DioExceptionHandler().callApi()

## [2.0.0] - 2024-03-10

### Breaking Changes - 2.0.0

Refactor of Exception Handling: The conversion of DioExceptionHandler into a mixin and the static method adjustments represent a breaking change for any existing codebases that instantiate DioExceptionHandler or rely on its previous class structure. Projects will need to update their exception handling implementations to adapt to this refactor. This change aims to streamline the process and enhance overall usability, but will require attention during migration to the new version.

  Example

  1.x.x:

  ```dart
    final ResultState<UserModel> result =
      await DioExceptionHandler().callApi<Response, UserModel>(  // use instance of class DioExceptionHandler().callApi
        ApiHandler(
          apiCall: () =>
              dio.get('https://jsonplaceholder.typicode.com/users/$id'),
          parserModel: (Object? data) =>
              UserModel.fromJson(data as Map<String, dynamic>),
        ),
      );
  ```

  to

  ```dart
    final ResultState<UserModel> result =
      await DioExceptionHandler.callApi_<Response, UserModel>( // use direct call DioExceptionHandler.callApi
        ApiHandler(
          apiCall: () =>
              dio.get('https://jsonplaceholder.typicode.com/users/$id'),
          parserModel: (Object? data) =>
              UserModel.fromJson(data as Map<String, dynamic>),
        ),
      );
  ```

### Added - 2.0.0

* Dio Extensions: Extensions for Dio HTTP response handling and custom parsing.

  ```dart
    final ResultState<UserModel> result =
      await DioExceptionHandler.callApi<Response, UserModel>(
        ApiHandler(
          apiCall: () =>
              dio.get('https://jsonplaceholder.typicode.com/users/$id'),
          parserModel: (Object? data) =>
              UserModel.fromJson(data as Map<String, dynamic>),
        ),
      );
  ```

  simplified extensions of dio to `dio.get().fromJson()`

  ```dart
      final ResultState<UserModel> result = await dio
          .get('https://jsonplaceholder.typicode.com/users/$id')
          .fromJson(UserModel.fromJson);
  ```

* Exception Handling: New comprehensive Dio exception handlers and simplified exception state management exception_handler.
* Isolates for Async: Utility for asynchronous computations using isolates to enhance performance.
* Updated Dependencies: New and updated package versions for improved functionality.
* Linting Rules: Expanded Dart code analysis rules for stricter linting.

### Changed - 2.0.0

* CI/CD Workflow: Enhanced with better triggers, actions, and coverage requirements.
* Code Structure: Improved handling and parsing of HTTP responses and exceptions with updated classes and typedefs.
* Naming Conventions: Updated for better readability and maintainability.
* Exception Handling Refactor: Converted DioExceptionHandler to a mixin and made its methods static, simplifying exception handling in API calls and enhancing usability without the need to instantiate DioExceptionHandler. Updated the callApi method in ClientExceptionHandler to be static, with corresponding adjustments in test cases.

### Removed - 2.0.0

* Obsolete Code: Removal of outdated exception handling approach for a cleaner codebase.

## 1.1.4

* feat: add support web

## 1.1.3

* doc: updated Readme

## 1.1.2

* refactor: updated class name for consistency and cohesion in the sealed class and subclass names

## 1.1.1

* refactor: updated class name for consistency and cohesion in the sealed class and subclass names

## 1.1.0

* feat: replace "when()/abstract" by "switch/sealed class"

## 1.0.11

* refactor: updated name property of ApiHandler

## 1.0.10

* fix: updated typo

## 1.0.9

* fix: updated type I/O of function callApi

## 1.0.8

* chore: upload demo screenshot

## 1.0.7

* chore: change minimum version to Dart 3.0.0

## 1.0.6

* test: updated test

## 1.0.5

* fix: bug log duplication and add example

## 1.0.4

* chore: add check coverage on pipeline

## 1.0.3

* doc: updated Readme

## 1.0.2

* doc: updated Readme

## 1.0.1

* doc: updated Readme

## 1.0.0

* Initial release exception_handler
