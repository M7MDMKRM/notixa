import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../features/calendar/domain/repositories/calendar_repository.dart';
import '../features/home/domain/usecases/extract_note_usecase.dart';
import '../features/home/presentation/screens/main_navigation_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';
import 'di.dart';
import 'theme/notixa_theme.dart';

class NotixaApp extends StatefulWidget {
  const NotixaApp({super.key});

  @override
  State<NotixaApp> createState() => _NotixaAppState();
}

class _NotixaAppState extends State<NotixaApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('ar');
  bool _isOnboarded = true;
  bool _isLoggedIn = true;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CalendarRepository>.value(value: sl<CalendarRepository>()),
        RepositoryProvider<ExtractNoteUsecase>.value(value: sl<ExtractNoteUsecase>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<WalletBloc>(create: (_) => sl<WalletBloc>()),
        ],
        child: MaterialApp(
          title: 'Notixa',
          debugShowCheckedModeBanner: false,
          theme: NotixaTheme.lightTheme,
          darkTheme: NotixaTheme.darkTheme,
          themeMode: _themeMode,
          locale: _locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: !_isOnboarded
              ? OnboardingScreen(onFinish: () => setState(() => _isOnboarded = true))
              : (!_isLoggedIn
                  ? LoginScreen(onLoginSuccess: () => setState(() => _isLoggedIn = true))
                  : MainNavigationScreen(
                      onThemeChanged: (mode) => setState(() => _themeMode = mode),
                      onLocaleChanged: (loc) => setState(() => _locale = loc),
                    )),
        ),
      ),
    );
  }
}
