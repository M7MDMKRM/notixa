/// Domain failure representation
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'يرجى التحقق من اتصالك بالإنترنت']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'فشل في حفظ أو استرجاع البيانات المحلية']);
}

/// Generic Result type for functional error handling without throwing uncaught exceptions
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        Error() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final f) => f,
      };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
