import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    var mapsApiKey = ""
    let envAssetKey = FlutterDartProject.lookupKey(forAsset: ".env")
    if let envPath = Bundle.main.path(forResource: envAssetKey, ofType: nil),
       let envString = try? String(contentsOfFile: envPath) {
        for line in envString.split(separator: "\n") {
            let parts = line.split(separator: "=", maxSplits: 1)
            if parts.count == 2 && parts[0].trimmingCharacters(in: .whitespaces) == "MAPS_API_KEY" {
                mapsApiKey = String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
    GMSServices.provideAPIKey(mapsApiKey)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
