import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/calendar/domain/repositories/calendar_repository.dart';
import '../features/home/domain/usecases/extract_note_usecase.dart';
import '../features/home/presentation/screens/main_navigation_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/wallet/presentation/bloc/wallet_bloc.dart';
import 'di.dart';
import 'theme/notixa_theme.dart';

class _SafeMaterialLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const _SafeMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return DefaultMaterialLocalizations.load(locale);
  }

  @override
  bool shouldReload(_SafeMaterialLocalizationsDelegate old) => false;
}

class _SafeWidgetsLocalizationsDelegate extends LocalizationsDelegate<WidgetsLocalizations> {
  const _SafeWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<WidgetsLocalizations> load(Locale locale) {
    return DefaultWidgetsLocalizations.load(locale);
  }

  @override
  bool shouldReload(_SafeWidgetsLocalizationsDelegate old) => false;
}

class _SafeCupertinoLocalizationsDelegate extends LocalizationsDelegate<CupertinoLocalizations> {
  const _SafeCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return DefaultCupertinoLocalizations.load(locale);
  }

  @override
  bool shouldReload(_SafeCupertinoLocalizationsDelegate old) => false;
}

class NotixaApp extends StatefulWidget {
  const NotixaApp({super.key});

  @override
  State<NotixaApp> createState() => _NotixaAppState();
}

class _NotixaAppState extends State<NotixaApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');
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
          title: 'Nexa',
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
            _SafeMaterialLocalizationsDelegate(),
            _SafeWidgetsLocalizationsDelegate(),
            _SafeCupertinoLocalizationsDelegate(),
          ],
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            return Container(
              color: const Color(0xFFF8F9FE),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: screenWidth > 500 ? 500 : double.infinity,
                height: double.infinity,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
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
