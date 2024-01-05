import 'package:exception_handler/exception_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Exceptions State', () {
    group('DataClientExceptionState', () {
      final testException = Exception('Test exception');
      final dataClientException = DataClientExceptionState<String>(
        testException,
        StackTrace.current,
      );
      test('should assign the client exception correctly', () {
        expect(dataClientException.clientException, testException);
        expect(dataClientException.clientException, isA<Exception>());
        expect(
          dataClientException.clientException.toString(),
          'Exception: Test exception',
        );
      });
      test('should correct toString', () {
        expect(
          dataClientException.toString(),
          'DataClientExceptionState<String>(clientException: Exception: Test exception)',
        );
      });
    });
    group('DataParseExceptionState', () {
      final Exception exception = Exception('Parse error');
      final DataParseExceptionState<String> dataParseException =
          DataParseExceptionState<String>(exception, StackTrace.current);
      test('should assign the parse exception correctly', () {
        expect(dataParseException.parseException, equals(exception));
      });
      test('should correct toString', () {
        expect(
          dataParseException.toString(),
          'DataParseExceptionState<String>(parseException: Exception: Parse error)',
        );
      });
    });
    group('DataHttpExceptionState', () {
      final DataHttpExceptionState<String> dataHttpException =
          DataHttpExceptionState<String>(
        exception: null,
        httpException: HttpException.unauthorized,
        stackTrace: StackTrace.current,
        statusCode: 401,
      );
      test('should assign the http exception correctly', () {
        expect(
          dataHttpException.httpException,
          equals(HttpException.unauthorized),
        );
      });
      test('should correct toString', () {
        expect(
          dataHttpException.toString(),
          'DataHttpExceptionState<String>(httpException: HttpException.unauthorized, statusCode: 401)',
        );
      });
    });
    group('DataNetworkExceptionState', () {
      final DataNetworkExceptionState<String> dataNetworkException =
          DataNetworkExceptionState<String>(
        NetworkException.noInternetConnection,
        StackTrace.current,
      );
      test('should assign the network exception correctly', () {
        expect(
          dataNetworkException.networkException,
          equals(NetworkException.noInternetConnection),
        );
      });

      test('should correct toString', () {
        expect(
          dataNetworkException.toString(),
          'DataNetworkExceptionState<String>(networkException: NetworkException.noInternetConnection)',
        );
      });
    });
    group('DataCacheExceptionState', () {
      final DataCacheExceptionState<String> dataCacheException =
          DataCacheExceptionState<String>(
        CacheException.unknown,
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataCacheException.cacheException,
          equals(CacheException.unknown),
        );
      });

      test('should correct toString', () {
        expect(
          dataCacheException.toString(),
          'DataCacheExceptionState<String>(cacheException: CacheException.unknown)',
        );
      });
    });
    group('DataInvalidInputExceptionState', () {
      final DataInvalidInputExceptionState<String> dataInvalidInputException =
          DataInvalidInputExceptionState<String>(
        InvalidInputException.unknown,
        StackTrace.current,
      );
      test('should assign the cache exception correctly', () {
        expect(
          dataInvalidInputException.invalidInputException,
          equals(InvalidInputException.unknown),
        );
      });

      test('should correct toString', () {
        expect(
          dataInvalidInputException.toString(),
          'DataInvalidInputExceptionState<String>(invalidInputException: InvalidInputException.unknown)',
        );
      });
    });
  });
}
