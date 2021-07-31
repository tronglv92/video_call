import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vide_call_v2/models/call_remote_message.dart';
import 'package:vide_call_v2/src/pages/call/call_page.dart';
import 'package:vide_call_v2/src/pages/contact_page.dart';
import 'package:vide_call_v2/src/pages/incoming_video_page.dart';

class AppRoute {
  factory AppRoute() => _instance;

  AppRoute._private();

  ///#region ROUTE NAMES
  /// -----------------
  static const String routeRoot = '/';
  static const String routeCall = '/call';
  static const String routeIncomingVideoCall = '/incoming_video_call';

  ///#endregion
  static final AppRoute _instance = AppRoute._private();

  static AppRoute get I => _instance;

  /// Create local provider
  // MaterialPageRoute<dynamic>(
  //             settings: settings,
  //             builder: (_) => AppRoute.createProvider(
  //                 (_) => HomeProvider(),
  //                 HomePage(
  //                   status: settings.arguments as bool,
  //                 )))
  static Widget createProvider<P extends ChangeNotifier>(
    P Function(BuildContext context) provider,
    Widget child,
  ) {
    return ChangeNotifierProvider<P>(
      create: provider,
      builder: (_, __) {
        return child;
      },
    );
  }

  /// Create multi local provider
  // MaterialPageRoute<dynamic>(
  //             settings: settings,
  //             builder: (_) => AppRoute.createProviders(
  //                 <SingleChildWidget>[
  //                     ChangeNotifierProvider<HomeProvider>(
  //                         create: (BuildContext context) => HomeProvider()),
  //                 ],
  //                 HomePage(
  //                   status: settings.arguments as bool,
  //                 )))
  static Widget createProviders(
    List<SingleChildWidget> providers,
    Widget child,
  ) {
    return MultiProvider(
      providers: providers ?? <SingleChildWidget>[],
      child: child,
    );
  }

  /// App route observer
  final RouteObserver<Route<dynamic>> routeObserver =
      RouteObserver<Route<dynamic>>();

  /// App global navigator key
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get app context
  BuildContext get appContext => navigatorKey.currentContext;

  /// Generate route for app here
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeRoot:
        return MaterialPageRoute<dynamic>(
            settings: settings, builder: (_) => ContactPage());

      case routeCall:
        return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (_) {
              bool startCall = settings.arguments;
              // Map<String, dynamic> arguments = settings.arguments;
              // String chanelName = arguments['channelName'];
              // RtcEngine engine = arguments['engine'];
              // List<String> infoStrings = arguments['infoStrings'];
              // List<int> users = arguments['users'];
              return CallPage(
                isCall: startCall,
              );
            });

      case routeIncomingVideoCall:
        return MaterialPageRoute<dynamic>(
            settings: settings,
            builder: (_) {
              CallRemoteMessage callRemoteMessage = settings.arguments;
              return InComingVideoPage(callRemoteMessage: callRemoteMessage);
            });

      default:
        return null;
    }
  }
}
