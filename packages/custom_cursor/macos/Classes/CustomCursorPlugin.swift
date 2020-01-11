import Cocoa
import FlutterMacOS

public class CustomCursorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "custom_cursor", binaryMessenger: registrar.messenger)
    let instance = CustomCursorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  var mouseStackCount = 1;

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "mouseStackCount":
        let count = mouseStackCount
        result(count)
    case "resetCursor":
        mouseStackCount = 1
        NSCursor.arrow.set()
        result(true)
    case "removeCursorFromStack":
        if (mouseStackCount == 1) {
            NSCursor.arrow.set()
        } else {
            NSCursor.current.pop()
            mouseStackCount -= 1
        }
        result(true)
    case "hideCursor":
        for _ in 1...mouseStackCount {
            NSCursor.hide()
        }
        result(true)
    case "showCursor":
        for _ in 1...mouseStackCount {
            NSCursor.unhide()
        }
        result(true)
    case "setCursor":
        let args = call.arguments as? [String: Any]
        let update: Bool = (args?["update"] as? Bool)!
        let type: String = (args?["type"] as? String)!
        var cursor: NSCursor
        switch type {
        case "arrow": cursor = NSCursor.arrow
        case "beamVertical": cursor = NSCursor.iBeam
        case "beamHorizontial": cursor = NSCursor.iBeamCursorForVerticalLayout
        case "crossHair": cursor = NSCursor.crosshair
        case "closedHand": cursor = NSCursor.closedHand
        case "openHand": cursor = NSCursor.openHand
        case "pointingHand": cursor = NSCursor.pointingHand
        case "resizeLeft": cursor = NSCursor.resizeLeft
        case "resizeRight": cursor = NSCursor.resizeRight
        case "resizeLeftRight": cursor = NSCursor.resizeLeftRight
        case "resizeUp": cursor = NSCursor.resizeUp
        case "resizeDown": cursor = NSCursor.resizeDown
        case "resizeUpDown": cursor = NSCursor.resizeUpDown
        case "disappearingItem": cursor = NSCursor.disappearingItem
        case "notAllowed": cursor = NSCursor.operationNotAllowed
        case "dragLink": cursor = NSCursor.dragLink
        case "dragCopy": cursor = NSCursor.dragCopy
        case "contextMenu": cursor = NSCursor.contextualMenu
        default:
            cursor = NSCursor.arrow
        }
        if (update) {
            cursor.push()
            mouseStackCount += 1
        } else {
            cursor.set()
        }
        result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
