import Flutter
import UIKit

/// Gives Dart the app's icon as PNG bytes.
public class ButterToastPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "butter_toast", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(ButterToastPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "appIcon":
      guard let image = Self.appIcon(), let data = image.pngData() else {
        result(nil)
        return
      }
      result(FlutterStandardTypedData(bytes: data))
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// The icon named in Info.plist, largest size first.
  private static func appIcon() -> UIImage? {
    if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
      let primary = icons["CFBundlePrimaryIcon"] as? [String: Any]
    {
      if let files = primary["CFBundleIconFiles"] as? [String] {
        for name in files.reversed() {
          if let image = UIImage(named: name) { return image }
        }
      }
      if let name = primary["CFBundleIconName"] as? String,
        let image = UIImage(named: name)
      {
        return image
      }
    }
    return UIImage(named: "AppIcon")
  }
}
