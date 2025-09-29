import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/home/home_screen.dart';
import '../models/charging_station_model.dart';
import '../controller/station_controller.dart';
import '../views/station_detail_screen/station_detail_screen.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String stationDetail = '/station-detail';

  // Define all app routes
  static List<GetPage> routes = [
    // Splash Screen
    GetPage(
      name: splash,
      page: () => const SplashView(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    // Login Screen
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),

    // Home Screen
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
      binding: BindingsBuilder(() {
        // Initialize StationController if not already initialized
        if (!Get.isRegistered<StationController>()) {
          Get.put(StationController());
        }
      }),
    ),

    // Station Detail Screen
    GetPage(
      name: stationDetail,
      page: () {
        final station = Get.arguments as ChargingStation;
        return StationDetailScreen(station: station);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];

  // Navigation helpers
  static void toSplash() => Get.offAllNamed(splash);

  static void toLogin() => Get.offAllNamed(login);

  static void toHome() => Get.offAllNamed(home);

  static void toStationDetail(ChargingStation station) {
    Get.toNamed(stationDetail, arguments: station);
  }
}