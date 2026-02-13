import Flutter
import UIKit

// Punto de entrada nativo en iOS: inicializa Flutter y plugins.
@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Delega el bootstrap principal al comportamiento estandar de Flutter.
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    // Registra plugins para el engine implicito.
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
