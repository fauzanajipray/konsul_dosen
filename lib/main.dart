import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:konsul_dosen/features/auth/presentations/sign_in_page.dart';
import 'package:konsul_dosen/features/home/presentations/home_page.dart';
import 'package:konsul_dosen/firebase_options.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  final storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorage.webStorageDirectory
          : await getApplicationDocumentsDirectory());
  HydratedBloc.storage = storage;
  // FlutterNativeSplash.preserve(); // No need to pass widgetsBinding if you're not using it elsewhere
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Scaffold(
        // appBar: AppBar(),
        body: SignInPage(),
      ),
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
