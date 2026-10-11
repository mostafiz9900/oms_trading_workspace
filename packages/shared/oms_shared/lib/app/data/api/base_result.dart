sealed class Result<S> {
  const Result();
}

final class Success<S> extends Result<S> {
  const Success(this.value);
  final S value;
}

final class Failure<S> extends Result<S> {
  const Failure(this.errorMessage);
  final String errorMessage;
}

class LoadingResult implements Result {}

// Function to handle exhaustive pattern matching
String getResultMessage(Result result) {
  if (result is Success) {
    return "Success: ${result.value}";
  } else if (result is Failure) {
    return "Error: ${result.errorMessage}";
  } else if (result is LoadingResult) {
    return "Loading...";
  } else {
    throw ArgumentError("Unknown result type: $result");
  }
}
