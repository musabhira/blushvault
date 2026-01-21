import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/nav/nav.dart';
import 'index.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug log to confirm JS started
  print('DEBUG: App starting...');

  try {
    GoRouter.optionURLReflectsImperativeAPIs = true;
    usePathUrlStrategy();

    print('DEBUG: Initializing Supabase...');
    // Add timeout to Supabase init to prevent hanging
    await SupaFlow.initialize().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        print('DEBUG: Supabase initialization timed out! Continuing anyway...');
        return null;
      },
    );
    print('DEBUG: Supabase initialized (or timed out).');

    print('DEBUG: Initializing Theme...');
    await FlutterFlowTheme.initialize().timeout(
      const Duration(seconds: 2),
      onTimeout: () {
        print('DEBUG: Theme initialization timed out! Continuing anyway...');
        return null;
      },
    );
    print('DEBUG: Theme initialized.');
  } catch (e, stack) {
    print('CRITICAL: Error during initialization: $e\n$stack');
  }

  print('DEBUG: Calling runApp...');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();
  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Blushvault',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
            TargetPlatform.windows: CustomPageTransitionsBuilder(),
            TargetPlatform.macOS: CustomPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: false,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CustomPageTransitionsBuilder(),
            TargetPlatform.iOS: CustomPageTransitionsBuilder(),
            TargetPlatform.windows: CustomPageTransitionsBuilder(),
            TargetPlatform.macOS: CustomPageTransitionsBuilder(),
            TargetPlatform.linux: CustomPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  const CustomPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.2, 0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );
  }
}
