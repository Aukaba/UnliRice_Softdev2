import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // try to read key from .env at runtime (file is not checked into VCS)
    if let path = Bundle.main.path(forResource: ".env", ofType: nil),
       let content = try? String(contentsOfFile: path) {
      for line in content.split(separator: "\n") {
        let parts = line.split(separator: "=", maxSplits: 1)
        if parts.count == 2 {
          let key = parts[0].trimmingCharacters(in: .whitespaces)
          let value = parts[1].trimmingCharacters(in: .whitespaces)
          if key == "GOOGLE_MAPS_API_KEY" {
            GMSServices.provideAPIKey(value)
            break
          }
        }
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
