import FlutterMacOS

public class E2EPlugin: NSObject, FlutterPlugin {

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "plugins.flutter.io/e2e",
      binaryMessenger: registrar.messenger)

    let instance = E2EPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "allTestsFinished":
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
