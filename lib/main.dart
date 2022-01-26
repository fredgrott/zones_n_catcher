import 'dart:async';

import 'package:catcher/catcher.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/infrastructure/catcher.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

Future<void> main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Catches Flutter Framework errors. For example, set anY UI theme
  // padding to infinity and re-run the app and you will see the
  // nice error screen.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (kDebugMode) {
      // In development mode simply print to console.
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In production mode report to the application zone to report to
      // app exceptions provider. We do not need this in Profile mode.
      // ignore: no-empty-block
      if (kReleaseMode) {
        // FlutterError class has something not changed as far as null safety
        // so I just assume we do not have a stack trace but still want the
        // detail of the exception.
        // ignore: cast_nullable_to_non_nullable
        Zone.current.handleUncaughtError(
          // ignore: cast_nullable_to_non_nullable
          details.exception, details.stack as StackTrace,
        );
      }
    }
  };

  // Each Dart and Flutter App starts with one parent Zone root due to main function.
  // the runZonedGuarded set's up a zone to run the app in below the root main function 
  // zone that will send the error output when the app stops to the parent zone.
  runZonedGuarded<Future<void>>(() async {
    Catcher(
      
      // no need to supply nav key as MyApp parameter as in stateless
      // we do not have a widget thing to grab we cannot access static
      // instances so we just grab the right var from
      // app catch exceptions file. That means that if
      // problably should be some service injected dependency
      rootWidget: MyApp(settingsController: settingsController,),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions,
      navigatorKey: myNavigatorKey,

      );
    },
      // ignore: no-empty-block
      (
        Object error,
        StackTrace stack,
      ) {

        // if we have a backend then we do this
        // myBackend.sendError(error, stack);


      },
      // ZoNeSpecification allows us to intercept 
      // print(console) calls and redefine them for 
      // the debugMode dump to console
      zoneSpecification: ZoneSpecification(
      // Intercept all print calls
      print: (
        self,
        parent,
        zone,
        line,
      ) async {
        // Include a timestamp and the name of the App
        final messageToLog = "[${DateTime.now()}] $myAppTitle $line $zone";

        // Also print the message in the "Debug Console"
        // but it's ony an info message and contains no
        // privacy prohibited stuff
        parent.print(
          zone,
          messageToLog,
        );
      },
    ),

  );

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(settingsController: settingsController));
}
