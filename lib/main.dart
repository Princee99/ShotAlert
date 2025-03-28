import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:shot_alert/wrapper.dart';
import 'package:shot_alert/services/logger_service.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Logger.logSystem("Application started");

  try {
    Logger.logSystem("Initializing Firebase");
    await Firebase.initializeApp();
    Logger.logSystem("Firebase initialized successfully");
  } catch (e) {
    Logger.error(Logger.SYSTEM, "Firebase initialization failed", e);
  }

  await Future.delayed(Duration(milliseconds: 500));
  Logger.logSystem("Starting app", {
    "platform": defaultTargetPlatform.toString(),
    "debugMode": kDebugMode.toString(),
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Logger.debug(Logger.SYSTEM, "Building MyApp");

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ShotAlert',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Wrapper(),
      navigatorObservers: [
        MyNavigatorObserver(),
      ],
    );
  }
}

class MyNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Logger.logNavigation(previousRoute?.settings.name ?? 'unknown',
        route.settings.name ?? 'unknown', {"type": "push"});
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    Logger.logNavigation(route.settings.name ?? 'unknown',
        previousRoute?.settings.name ?? 'unknown', {"type": "pop"});
    super.didPop(route, previousRoute);
  }
}
