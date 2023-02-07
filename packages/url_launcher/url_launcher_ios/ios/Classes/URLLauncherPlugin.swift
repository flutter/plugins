// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Flutter
import UIKit

public final class URLLauncherPlugin: NSObject, FlutterPlugin {
    var currentSession: URLLaunchSession?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "plugins.flutter.io/url_launcher_ios", binaryMessenger: registrar.messenger())
        let instance = URLLauncherPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "canLaunch":
            let args = call.arguments as! [String: Any]
            let url = args["url"] as! String
            result(canLaunchURL(url))
        case "launch":
            let args = call.arguments as! [String: Any]
            let url = args["url"] as! String
            let useSafariVC = args["useSafariVC"] as? Bool ?? false
            if useSafariVC {
                launchURLInVC(url, result: result)
            } else {
                launchURL(url, call: call, result: result)
            }
        case "closeWebView":
            closeWebView(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func canLaunchURL(_ url: String) -> Bool {
        guard let url = URL(string: url) else {
            return false
        }
        
        return UIApplication.shared.canOpenURL(url)
    }
    
    private func launchURL(_ url: String, call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String: Any]
        let universalLinksOnly = (args["universalLinksOnly"] as? Bool) ?? false
        let options = [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: universalLinksOnly]
        UIApplication.shared.open(URL(string: url)!, options: options) { success in
            result(success)
        }
    }
    
    private func launchURLInVC(_ url: String, result: @escaping FlutterResult) {
        currentSession = URLLaunchSession(url: URL(string: url)!)
        currentSession?.didFinish = {
            self.currentSession = nil
        }
        self.topViewController.present(currentSession!.safari, animated: true) {
            result(true)
        }
    }
    
    private func closeWebView(result: @escaping FlutterResult) {
        currentSession?.close()
        result(nil)
    }
    
    private func launchURLInVC(urlString: String, result: @escaping FlutterResult) {
        let url = URL(string: urlString)!
        self.currentSession = URLLaunchSession(url: url)
        weak var weakSelf = self
        self.currentSession!.didFinish = {
            weakSelf?.currentSession = nil
        }
        self.topViewController.present(self.currentSession!.safari, animated: true, completion: nil)
    }
    
    var topViewController: UIViewController {
        // TODO: Provide a non-deprecated codepath. See https://github.com/flutter/flutter/issues/104117
        return topViewControllerFromViewController(UIApplication.shared.keyWindow!.rootViewController!)
    }
    
    /// This method recursively iterates through the view hierarchy
    /// to return the top most view controller.
    ///
    /// It supports the following scenarios:
    ///
    /// - The view controller is presenting another view.
    /// - The view controller is a UINavigationController.
    /// - The view controller is a UITabBarController.
    ///
    ///  @return The top most view controller.
    private func topViewControllerFromViewController(_ viewController: UIViewController)
    -> UIViewController
    {
        if let navigationController = viewController as? UINavigationController {
            return topViewControllerFromViewController(navigationController.viewControllers.last!)
        }
        if let tabController = viewController as? UITabBarController {
            return topViewControllerFromViewController(tabController.selectedViewController!)
        }
        if let presentedViewController = viewController.presentedViewController {
            return topViewControllerFromViewController(presentedViewController)
        }
        return viewController
    }
}
