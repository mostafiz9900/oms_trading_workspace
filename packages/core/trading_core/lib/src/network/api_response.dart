/// Application-level success or error result shared across OMS features.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  ApiResponse.success(this.data) : success = true, errorMessage = null;

  ApiResponse.error(this.errorMessage) : success = false, data = null;
}
