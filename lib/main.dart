import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_cubit.dart';
import 'package:konsul_dosen/features/auth/cubit/auth_state.dart';
import 'package:konsul_dosen/features/auth/presentations/sign_in_page.dart';
import 'package:konsul_dosen/firebase_options.dart';
import 'package:konsul_dosen/services/app_router.dart';
import 'package:konsul_dosen/widgets/loading_progress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  final storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getApplicationDocumentsDirectory());
  HydratedBloc.storage = storage;
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const App());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthCubit _authCubit = AuthCubit();
  late final _router = AppRouter(_authCubit).router;

  @override
  void initState() {
    super.initState();
  }

  // void initAsyncData() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     _authCubit.checkToken();
  //   });
  //   if (mounted) {
  //     setState(() {});
  //   }
  // }

  // Future<void> initPlatformState() async {
  //   if (!mounted) return;
  //   OneSignal.Notifications.addClickListener((result) {
  //     Map<String, dynamic>? additionalData = result.notification.additionalData;
  //     logger.e(additionalData);
  //     if (additionalData != null) {
  //       String url = (additionalData['route'] as String?) ?? '';
  //       logger.e(url);
  //       if (url != '') {
  //         _router.go(url);
  //         return;
  //       }
  //     }
  //     _router.go(Destination.home);
  //   });
  //   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  //   OneSignal.initialize(AppConstant.oneSignalAppKey);
  //   OneSignal.Notifications.requestPermission(true);
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _authCubit),
        ],
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previousState, state) {
            return (previousState.status == AuthStatus.initial ||
                    previousState.status == AuthStatus.loading) &&
                (state.status != AuthStatus.initial &&
                    state.status != AuthStatus.loading);
          },
          listener: (BuildContext context, AuthState state) {
            FlutterNativeSplash.remove();
          },
          child: buildMaterialApp(_router),
        ));
  }

  Widget buildMaterialApp(GoRouter router) {
    return MaterialApp.router(
      title: 'Pumo Partner',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return BlocBuilder<AuthCubit, AuthState>(
          buildWhen: (previous, current) {
            return previous.status != current.status;
          },
          builder: (BuildContext context, AuthState state) {
            FlutterNativeSplash.remove();
            if (state.status == AuthStatus.initial ||
                state.status == AuthStatus.loading) {
              return const Scaffold(
                body: LoadingProgress(),
              );
            }
            // else if (state.status == AuthStatus.failure ||
            //     state.status == AuthStatus.reloading) {
            //   return LoginErrorScreen(
            //       DioExceptions.fromDioError(state.error!, context).toString());
            // }
            // dioClient.init();
            return ResponsiveBreakpoints.builder(
              child: child!,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
              ],
            );
          },
        );
      },
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0FAEAE),
          primary: const Color(0xFF0FAEAE),
          secondary: const Color.fromARGB(255, 57, 81, 98),
          onSurfaceVariant: Colors.grey,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: const Color.fromARGB(255, 57, 81, 98),
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Colors.white,
        ),
        dialogTheme: DialogTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(16),
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(surfaceTintColor: Colors.white),
        useMaterial3: true,
        cardTheme: const CardTheme(
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
      ),
    );
  }
}
