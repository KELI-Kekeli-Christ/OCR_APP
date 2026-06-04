import 'package:go_router/go_router.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/document_viewer/presentation/document_viewer_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/live_scan/presentation/live_scan_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/result/presentation/result_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../domain/entities/scan_result.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const camera = '/camera';
  static const liveScan = '/live-scan';
  static const result = '/result';
  static const document = '/document';
  static const aiChat = '/ai-chat';
  static const history = '/history';
  static const settings = '/settings';
}

GoRouter createAppRouter({required bool onboardingDone}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.camera,
        builder: (_, state) => CameraScreen(
          modeName: state.uri.queryParameters['mode'],
        ),
      ),
      GoRoute(
        path: AppRoutes.liveScan,
        builder: (_, __) => const LiveScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (_, state) {
          final extra = state.extra;
          return ResultScreen(
            scan: extra is ScanResult ? extra : null,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.document,
        builder: (_, state) => DocumentViewerScreen(
          scan: state.extra as ScanResult?,
        ),
      ),
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (_, state) => AiChatScreen(
          scan: state.extra as ScanResult?,
        ),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
    ],
  );
}
