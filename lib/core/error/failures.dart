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
