import '../../../data/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
// Note: You no longer need services.dart for PlatformException. local_auth 3.0 uses LocalAuthException.

class BiometricController extends GetxController implements GetxService {
  final LocalAuthentication _auth = LocalAuthentication();
  var isEnabled = false;
  var isAvailable = false;
  static const _storageKey = 'biometric_enabled';

  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  Future<void> _initializeController() async {
    await Future.wait([
      _checkBiometricAvailability(),
      isBiometricEnabled(), // Fetch saved state on startup
    ]);
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      final enrolled = await _auth.getAvailableBiometrics();

      isAvailable = canCheck && supported && enrolled.isNotEmpty;
      print('Biometric available: $isAvailable');
      update(); // Important: Update GetX UI after async check completes
    } catch (e) {
      isAvailable = false;
      print('Error checking biometrics: $e');
      update();
    }
  }

  /// Enable biometric
  Future<void> enableBiometric() async {
    await StorageService.save(_storageKey, 'true');
    isEnabled = true;
    update();
    print('Biometric enabled locally');
  }

  /// Disable biometric
  Future<void> disableBiometric() async {
    await StorageService.save(_storageKey, 'false');
    isEnabled = false;
    update();
    print('Biometric disabled locally');
  }

  /// Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final storedValue = await StorageService.read(_storageKey);
    final enabled = storedValue == 'true';
    isEnabled = enabled;
    update();
    return enabled;
  }

  Future<bool> authenticate() async {
    if (!isAvailable) return false;
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Authenticate to login',
        persistAcrossBackgrounding: true, // Replaces stickyAuth
      );
      return result;
    } on LocalAuthException catch (e) {
      // Handles local_auth specific errors (e.g., user locked out)
      print('Authentication LocalAuthException: ${e.code} - ${e.details}');

      if (e.code == LocalAuthExceptionCode.biometricLockout) {
        print('User is temporarily locked out due to too many attempts.');
      }
      return false;
    } catch (e) {
      print('Authentication error: $e');
      return false;
    }
  }
}
