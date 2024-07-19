import 'network_error.dart';

abstract class NetworkErrorMapper {
  NetworkError call<T>(
    Object error,
  );
}
