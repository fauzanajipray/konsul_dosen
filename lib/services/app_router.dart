import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:konsul_dosen/features/home/presentations/home_page.dart';
import 'package:konsul_dosen/widgets/bottom_navigation_page.dart';

class AppRouter {
  static late final GoRouter _router;

  static final GlobalKey<NavigatorState> parentNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tab1 = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tab2 = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tab3 = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tab4 = GlobalKey<NavigatorState>();
  AppRouter() {
    final routes = [
      StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            navigatorKey: tab1,
            routes: [
              GoRoute(
                path: Destination.homePath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const HomePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: tab2,
            routes: [
              GoRoute(
                path: Destination.homePath,
                pageBuilder: (context, GoRouterState state) {
                  return getPage(
                    child: const HomePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: tab3,
            routes: [
              GoRoute(
                path: Destination.homePath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const HomePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: tab4,
            routes: [
              GoRoute(
                path: Destination.homePath,
                pageBuilder: (context, state) {
                  return getPage(
                    child: const HomePage(),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return getPage(
            child: BottomNavigationPage(
              child: navigationShell,
            ),
            state: state,
          );
        },
      ),
    ];

    _router = GoRouter(
      navigatorKey: parentNavigatorKey,
      initialLocation: Destination.homePath,
      // refreshListenable: GoRouterRefreshStream(_authCubit.stream),
      routes: routes,
      // redirect: (context, state) {},
    );
  }

  static Page getPage({
    required Widget child,
    required GoRouterState state,
  }) {
    return MaterialPage(
      key: state.pageKey,
      child: child,
    );
  }

  GoRouter get router => _router;
}

class Destination {
  static const String signInPath = '/signIn';

  static const String homePath = '/home';
  static const String menu2Path = '/menu2Path';
  static const String menu3Path = '/menu3Path';
  static const String menu4Path = '/menu4Path';
}

class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream].
  ///
  /// Every time the [stream] receives an event the [GoRouter] will refresh its
  /// current route.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
