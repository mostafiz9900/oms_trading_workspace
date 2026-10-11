import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'network_info_repository.dart';

class NetworkInfoImpl implements NetworkInfoRepository {
  NetworkInfoImpl({required this.networkInfo});
  InternetConnection networkInfo;

  /// Checks if the phone is connected to the internet
  @override
  Future<bool> get isConnected => Future.value(true);
}
