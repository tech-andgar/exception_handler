# Changelog

## [2.0.0] - 2024-03-10

### Breaking Changes

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
      await DioExceptionHandler.callApi<Response, UserModel>( // use direct call DioExceptionHandler.callApi
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
