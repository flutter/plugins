// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import SafariServices

class URLLaunchSession: NSObject, SFSafariViewControllerDelegate {
    var url: URL
    var safari: SFSafariViewController
    var didFinish: (() -> Void)?
    
    init(url: URL) {
        self.url = url
        self.safari = SFSafariViewController(url: url)
        super.init()
        
        self.safari.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
        self.didFinish?()
    }
    
    func close() {
        self.safariViewControllerDidFinish(self.safari)
    }
}
