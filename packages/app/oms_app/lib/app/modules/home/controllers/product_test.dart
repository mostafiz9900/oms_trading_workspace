import 'dart:io';

import 'package:oms_app/app/app_pkg.dart';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/response/user.model.dart';

final userProvider = AsyncNotifierProvider.autoDispose.family<UserNotifier, dynamic, String>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<dynamic> {
  UserNotifier(this.id);
  final String id;

  @override
  Future<dynamic> build() async {
    printLog('id :: $id');
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://jsonplaceholder.typicode.com/posts/$id',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to load user: ${response.statusCode}', statusCode: response.statusCode);
      }

      printLog('response : user: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      printLog('Dio error for user $id: ${e.message}');
      // Re-throw with user-friendly message
      throw UserError('Failed to load user. Please check your connection.', originalError: e);
    } on SocketException catch (e) {
      throw UserError('No internet connection');
    } on FormatException catch (e) {
      throw UserError('Invalid data format received');
    } catch (e, stackTrace) {
      printLog('Unknown error for user $id: $e\n$stackTrace');
      throw UserError('An unexpected error occurred');
    }
  }
}

// Custom error class
class UserError implements Exception {
  final String message;
  final Object? originalError;

  UserError(this.message, {this.originalError});

  @override
  String toString() => 'UserError: $message';
}

class HttpException implements Exception {
  final String message;
  final int? statusCode;

  HttpException(this.message, {this.statusCode});

  @override
  String toString() => 'HttpException: $message${statusCode != null ? ' ($statusCode)' : ''}';
}
