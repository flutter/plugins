import Foundation


@objc public enum ContentBlockerOperationResult : NSInteger {
    case success = 0
    case error_can_not_read_file = 1
    case error_can_not_compile_rules = 2
    case error_content_blocking_not_available = 3
}

enum ContentBlockingKeys : String {
    case type = "type"
    case file_path = "file_path"
    case hosts = "hosts"
}

enum ContentBlockingRuleTypes : String {
    case json = "json"
    case dat = "dat"
    case hosts = "hosts"
}

protocol ContentBlockerApi {
    func setupContentBlocking(rules : [String : [String : Any]], webview : FLTWKWebView, completion: @escaping () -> Void)
}


@objc public class ContentBlocker : NSObject, ContentBlockerApi  {

    @objc public static let shared = ContentBlocker();

    let instance : ContentBlockerApi

    public override init() {
        if #available(iOS 11, *) {
            instance =  ContentBlockerIos11()
        } else {
            instance = ContentBlockerNotAvailable()
        }
    }

    @objc public func setupContentBlocking(rules: [String : [String : Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        instance.setupContentBlocking(rules: rules, webview: webview, completion: completion)
    }
}


class ContentBlockerNotAvailable : ContentBlockerApi {
    func setupContentBlocking(rules: [String : [String : Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        NSLog("Content Blocking is not available for iOS prior 11");
        completion()
    }
}


@available(iOS 11.0, *)
class ContentBlockerIos11 : ContentBlockerApi {
    private var compiledLists = [String : WKContentRuleList]()

    func setupContentBlocking(rules : [String : [String : Any]], webview : FLTWKWebView, completion: @escaping () -> Void) {
        var loadingResults = [String : Bool]();
        let group = DispatchGroup()

        for rule in rules {
            group.enter()

            switch rule.value[ContentBlockingKeys.type.rawValue] as! String {
            case ContentBlockingRuleTypes.dat.rawValue:
                NSLog("dat types are not supported in iOS")
                group.leave()
                continue
            case ContentBlockingRuleTypes.json.rawValue:
                loadContentRuleJsonFile(path: rule.value[ContentBlockingKeys.file_path.rawValue] as! String, key: rule.key) { result in
                    loadingResults[rule.key] = result == ContentBlockerOperationResult.success
                    group.leave()
                }
            case ContentBlockingRuleTypes.hosts.rawValue:
                loadHosts(hosts: rule.value[ContentBlockingKeys.hosts.rawValue] as! [String], key: rule.key) { result in
                    loadingResults[rule.key] = result == ContentBlockerOperationResult.success
                    group.leave()
                }
            default:
                NSLog("Unsupported type in %s", ContentBlockingKeys.type.rawValue)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            for res in loadingResults {
                self.addContentBlocker(key: res.key, webview: webview)
            }
            NSLog("Loaded %d content rule sets", loadingResults.count)
            completion()
        }
    }

    fileprivate func loadContentRuleJsonFile(path : String, key : String, completion: @escaping (ContentBlockerOperationResult) -> Void) {
        if compiledLists[key] != nil {
            completion(ContentBlockerOperationResult.success)
            return;
        }


        let jsonString: String
        do {
            jsonString = try String(contentsOfFile: path, encoding: .utf8)
        } catch {
            NSLog("Couldn't read file in path: %s %s", path, error.localizedDescription)
            completion(ContentBlockerOperationResult.error_can_not_read_file)
            return
        }


        compileJson(key: key, jsonString : jsonString, completion: completion)
    }


    fileprivate func loadHosts(hosts : [String], key : String, completion: @escaping (ContentBlockerOperationResult) -> Void) {
        if compiledLists[key] != nil {
            completion(ContentBlockerOperationResult.success)
            return;
        }

        let jsonString = convertListOfHostsToContenRuleJson(hosts: hosts);

        compileJson(key: key, jsonString : jsonString, completion: completion)
    }

    fileprivate func compileJson(key: String, jsonString: String, completion:  @escaping (ContentBlockerOperationResult) -> Void) {
        WKContentRuleListStore.default()
            .compileContentRuleList(forIdentifier: key, encodedContentRuleList: jsonString,
                                    completionHandler: { list, error in

                                        if error != nil {
                                            NSLog("Couldn't compile the content rules %s", error!.localizedDescription)
                                            completion(ContentBlockerOperationResult.error_can_not_compile_rules)
                                            return
                                        }

                                        self.compiledLists[key] = list
                                        completion(ContentBlockerOperationResult.success)
                                    }
            )
    }

    fileprivate func addContentBlocker(key : String, webview : FLTWKWebView) {
        if let list = compiledLists[key] {
            webview.configuration.userContentController.add(list)
        }
    }

    fileprivate func removeContentBlocker(key : String, webview : FLTWKWebView) {
        if let list = compiledLists[key] {
            webview.configuration.userContentController.remove(list)
        }
    }

    fileprivate func convertListOfHostsToContenRuleJson(hosts :  [String]) -> String {
        let formattedHosts = hosts.map { (host) -> String in
            "\"\(host)\""
        }.joined(separator: ",")
        return String(format: "[{\"trigger\":{\"url-filter\":\".*\",\"if-domain\":[%@]},\"action\":{\"type\":\"block\"}}]", formattedHosts)
    }
}
