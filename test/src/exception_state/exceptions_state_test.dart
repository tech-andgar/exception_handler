import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_exception/http_exception.dart';
import 'package:http_status/http_status.dart';

void main() {
  group('Exceptions State', () {
    group('DataClientExceptionState', () {
      const testException = 'Test exception';
      final dataClientException = DataClientExceptionState<String>(
        testException,
        StackTrace.current,
      );
      test('should assign the client exception correctly', () {
        expect(dataClientException.message, testException);
        expect(dataClientException.message, isA<String>());
        expect(
          dataClientException.message.toString(),
          'Test exception',
        );
      });
      test('should correct toString', () {
        expect(
          dataClientException.toString(),
          'DataClientExceptionState<String>(clientException: "Test exception")',
        );
      });
    });
    group('DataParseExceptionState', () {
      const exception = 'Parse error';
      final DataParseExceptionState<String> dataParseException =
          DataParseExceptionState<String>(exception, StackTrace.current);
      test('should assign the parse exception correctly', () {
        expect(dataParseException.message, equals(exception));
      });
      test('should correct toString', () {
        expect(
          dataParseException.toString(),
          'DataParseExceptionState<String>(parseException: "Parse error")',
        );
      });
    });
    group('DataHttpExceptionState', () {
      final DataHttpExceptionState<String> dataHttpException =
          DataHttpExceptionState<String>(
        exception: null,
        httpException: HttpStatus.fromCode(401).exception(),
        stackTrace: StackTrace.current,
      );
      test('should assign the http exception correctly', () {
        expect(
          dataHttpException.httpException,
          equals(const UnauthorizedHttpException()),
        );
      });
      test('should correct toString', () {
        expect(
          dataHttpException.toString(),
          'DataHttpExceptionState<String>(httpException: HttpException [401 Unauthorized])',
        );
      });
    });
    group('DataNetworkExceptionState', () {
      final DataNetworkExceptionState<String> dataNetworkException =
          DataNetworkExceptionState<String>(
        'NetworkException.noInternetConnection',
        StackTrace.current,
      );
      test('should assign the network exception correctly', () {
        expect(
          dataNetworkException.message,
          equals('NetworkException.noInternetConnection'),
        );
      });

      test('should correct toString', () {
        expect(
          dataNetworkException.toString(),
          'DataNetworkExceptionState<String>(networkException: "NetworkException.noInternetConnection")',
        );
      });
    });
    group('DataCacheExceptionState', () {
      final DataCacheExceptionState<String> dataCacheException =
          DataCacheExceptionState<String>(
        'CacheException.unknown',
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataCacheException.message,
          equals('CacheException.unknown'),
        );
      });

      test('should correct toString', () {
        expect(
          dataCacheException.toString(),
          'DataCacheExceptionState<String>(cacheException: "CacheException.unknown")',
        );
      });
    });
    group('DataInvalidInputExceptionState', () {
      final DataInvalidInputExceptionState<String> dataInvalidInputException =
          DataInvalidInputExceptionState<String>(
        'InvalidInputException.unknown',
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataInvalidInputException.message,
          equals('InvalidInputException.unknown'),
        );
      });

      test('should correct toString', () {
        expect(
          dataInvalidInputException.toString(),
          'DataInvalidInputExceptionState<String>(invalidInputException: "InvalidInputException.unknown")',
        );
      });
    });
  });
}
