import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../routes/app_routes.dart';
import '../services/auth_services.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();

  final Rx<User?> _user = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  User? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  @override
  void onInit() {
    super.onInit();
    // Listen to auth state changes
    _user.bindStream(_authService.authStateChanges);
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential != null) {
        Get.snackbar(
          'Success',
          'Welcome ${userCredential.user?.displayName ?? 'User'}!',
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Sign in failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      isLoading.value = true;
      await _authService.signOut();
      Get.snackbar(
        'Success',
        'Signed out successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Sign out failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get user display name
  String get displayName => _authService.getUserDisplayName() ?? 'User';

  // Get user email
  String get email => _authService.getUserEmail() ?? '';

  // Get user photo URL
  String? get photoUrl => _authService.getUserPhotoUrl();
}