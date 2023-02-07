// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import SafariServices

class URLLaunchSession: NSObject, SFSafariViewControllerDelegate {
  var flutterResult: FlutterResult?
  var url: URL
  var safari: SFSafariViewController
  var didFinish: (() -> Void)?

  init(url: URL, result: FlutterResult?) {
    self.url = url
    self.flutterResult = result
    self.safari = SFSafariViewController(url: url)

    super.init()
    self.safari.delegate = self
  }

  func safariViewController(
    _ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool
  ) {
    if didLoadSuccessfully {
      self.flutterResult?(true)
    } else {
      self.flutterResult?(
        FlutterError(
          code: "Error", message: "Error while launching \(self.url.absoluteString)", details: nil))
    }
  }

  func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
    controller.dismiss(animated: true, completion: nil)
    self.didFinish?()
  }

  func close() {
    self.safariViewControllerDidFinish(self.safari)
  }
}
