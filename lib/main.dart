import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:sapiens_rank/common/theme/theme.dart';
import 'package:sapiens_rank/l10n/app_localizations.dart';
import 'package:sapiens_rank/routing/router.dart';
import 'package:sapiens_rank/screens/update/update_cubit.dart';
import 'package:sapiens_rank/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage _) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
    FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
  } catch (e) {
    Logger('main').warning('Firebase init failed — push disabled: $e');
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => UpdateCubit()..fetch())],
      child: ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: const _MaterialAppRouter(),
      ),
    );
  }
}

class _MaterialAppRouter extends StatelessWidget {
  const _MaterialAppRouter();

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: DkTheme.light(),
      darkTheme: DkTheme.dark(),
      themeMode: authService.themeMode,
      locale: authService.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
