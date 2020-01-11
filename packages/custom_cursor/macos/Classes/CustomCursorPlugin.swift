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
        case "beam-vertical": cursor = NSCursor.iBeam
        case "beam-horizontial": cursor = NSCursor.iBeamCursorForVerticalLayout
        case "cross-hair": cursor = NSCursor.crosshair
        case "closed-hand": cursor = NSCursor.closedHand
        case "open-hand": cursor = NSCursor.openHand
        case "pointing-hand": cursor = NSCursor.pointingHand
        case "resize-left": cursor = NSCursor.resizeLeft
        case "resize-right": cursor = NSCursor.resizeRight
        case "resize-left-right": cursor = NSCursor.resizeLeftRight
        case "resize-up": cursor = NSCursor.resizeUp
        case "resize-down": cursor = NSCursor.resizeDown
        case "resize-up-down": cursor = NSCursor.resizeUpDown
        case "disappearing-item": cursor = NSCursor.disappearingItem
        case "not-allowed": cursor = NSCursor.operationNotAllowed
        case "drag-link": cursor = NSCursor.dragLink
        case "drag-copy": cursor = NSCursor.dragCopy
        case "context-menu": cursor = NSCursor.contextualMenu
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
