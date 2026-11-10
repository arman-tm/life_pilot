/// Base failure class for domain-level error handling.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// General unexpected failures.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred.']);
}

/// Network-related failures (for future use).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please try again.']);
}
