import UIKit
import Flutter

public extension UIImage {
  static func flutterImage(withName name: String) -> UIImage? {
    let filename = name.components(separatedBy: "/").last
    let path = name.components(separatedBy: "/").dropLast().joined(separator: "/")
    for screenScale in stride(from: UIScreen.main.scale, to: 1, by: -1) {
      let key = FlutterDartProject.lookupKey(forAsset: "\(path)/\(screenScale)0x/\(filename!)")
      if let image = UIImage(named: key, in: Bundle.main, compatibleWith: nil) {
        return image
      }
    }
    let key = FlutterDartProject.lookupKey(forAsset: name)
    return UIImage(named: key, in: Bundle.main, compatibleWith: nil)
  }
}
