import Foundation

@objc public enum ContentBlockerOperationResult: NSInteger {
    case success = 0
    case errorCanNotReadFile = 1
    case errorCanNotCompileRules = 2
    case errorContentBlockingNotAvailable = 3
}

enum ContentBlockingKeys: String {
    case type = "type"
    case filePath = "file_path"
    case hosts = "hosts"
}

enum ContentBlockingRuleType: String {
    case json
    case dat
    case hosts
}

private let ACTIVE = 1
private let INACTIVE = 0
private let DEFAULT_WHITELISTING_KEY = "*"

protocol ContentBlockerApi {
    func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void)

    func updateWhiteListing(rules: [String: [String: Any]])

    func onUrlChanged(webview: FLTWKWebView)
}

@objc public class ContentBlocker: NSObject, ContentBlockerApi {

    @objc public static let shared = ContentBlocker()

    let instance: ContentBlockerApi

    public override init() {
        if #available(iOS 11, *) {
            instance = WKContentRuleBlocker()
        } else {
            instance = ContentBlockerNotAvailable()
        }
    }

    @objc public func updateWhiteListing(rules: [String: [String: Any]]) {
        instance.updateWhiteListing(rules: rules)
    }

    @objc public func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        instance.setupContentBlocking(rules: rules, webview: webview, completion: completion)
    }

    @objc public func onUrlChanged(webview: FLTWKWebView) {
        instance.onUrlChanged(webview: webview)
    }
}

class ContentBlockerNotAvailable: ContentBlockerApi {
    func updateWhiteListing(rules: [String: [String: Any]]) {
        print("Content Blocking is not available for iOS prior 11")
    }

    func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        print("Content Blocking is not available for iOS prior 11")
        completion()
    }

    func onUrlChanged(webview: FLTWKWebView) {
        print("Content Blocking is not available for iOS prior 11")
    }
}

@available(iOS 11.0, *)
class WKContentRuleBlocker: ContentBlockerApi {
    private var compiledLists = [String: WKContentRuleList]()
    private var whiteListing = [String: [String: Int]]()

    func updateWhiteListing(rules: [String: [String: Any]]) {
        var tempDict = [String: [String: Int]]()
        rules.forEach { (key: String, value: [String: Any]) in
            tempDict[key] = value.reduce([String: Int]()) { (dict, entry) -> [String: Int] in
                var dict = dict
                let value = entry.value as? Int ?? -1
                if value == -1 {
                    logOrFatal(message: "Could not convert whitelist map value: \(value). Should be an Int.")
                }
                dict[entry.key] = value
                return dict
            }
        }
        whiteListing = tempDict
    }

    @objc public func onUrlChanged(webview: FLTWKWebView) {
        for list in compiledLists.keys {
            configureWebview(key: list, webview: webview)
        }
    }


    func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        var loadingResults = [String: Bool]()
        let group = DispatchGroup()

        for rule in rules {
            group.enter()

            guard let type = rule.value[ContentBlockingKeys.type.rawValue] as? String else {
                logOrFatal(message: "Rule \(rule) did not contain type filed!")
                continue
            }

            switch type {
            case ContentBlockingRuleType.dat.rawValue:
                print("dat types are not supported in iOS")
                group.leave()
            case ContentBlockingRuleType.json.rawValue:
                if let path = rule.value[ContentBlockingKeys.filePath.rawValue] as? String {
                    loadContentRuleJsonFile(path: path, key: rule.key) { result in
                        loadingResults[rule.key] = result == .success
                        group.leave()
                    }
                } else {
                    logOrFatal(message: "Rules specify dat type but no file_path value!")
                }

            case ContentBlockingRuleType.hosts.rawValue:
                if let hostList = rule.value[ContentBlockingKeys.hosts.rawValue] as? [String] {
                    loadHosts(hosts: hostList, key: rule.key) { result in
                        loadingResults[rule.key] = result == .success
                        group.leave()
                    }
                } else {
                    logOrFatal(message: "Rules specify hosts type but no list of hosts as hosts value!")
                }

            default:
                print("Unsupported type in \(ContentBlockingKeys.type.rawValue)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            for res in loadingResults {
                self.configureWebview(key: res.key, webview: webview)
            }
            completion()
        }
    }

    fileprivate func loadContentRuleJsonFile(path: String, key: String, completion: @escaping (ContentBlockerOperationResult) -> Void) {
        guard compiledLists[key] == nil else {
            completion(.success)
            return
        }

        do {
            let jsonString = try String(contentsOfFile: path, encoding: .utf8)
            compileJson(key: key, jsonString: jsonString, completion: completion)
        } catch {
            print("Couldn't read file in path: \(path) \(error.localizedDescription)")
            completion(.errorCanNotReadFile)
        }
    }

    fileprivate func loadHosts(hosts: [String], key: String, completion: @escaping (ContentBlockerOperationResult) -> Void) {
        guard compiledLists[key] == nil else {
            completion(.success)
            return
        }

        let jsonString = convertListOfHostsToContenRuleJson(hosts: hosts)

        compileJson(key: key, jsonString: jsonString, completion: completion)
    }

    fileprivate func compileJson(key: String, jsonString: String, completion: @escaping (ContentBlockerOperationResult) -> Void) {
        WKContentRuleListStore.default()
            .compileContentRuleList(forIdentifier: key, encodedContentRuleList: jsonString,
                                    completionHandler: { list, error in

                                        if let error = error {
                                            print("Couldn't compile the content rules \(key) : \(error.localizedDescription)")
                                            completion(.errorCanNotCompileRules)
                                            return
                                        }

                                        self.compiledLists[key] = list
                                        completion(.success)
                                    }
            )
    }

    fileprivate func configureWebview(key: String, webview: FLTWKWebView) {
        var shouldAdd = shouldAddByDefault(key: key)
        if let host = webview.url?.host, whiteListing[host]?[key] == ACTIVE {
            print("Host \(host) has active \(key) feature.")
            shouldAdd = false
        }

        if shouldAdd {
            addContentBlocker(key: key, webview: webview)
            print("Loaded \(key) content rule set")
        } else {
            removeContentBlocker(key: key, webview: webview)
            print("Removed \(key) content rule set")
        }
    }

    fileprivate func shouldAddByDefault(key: String) -> Bool {
        guard let entry = whiteListing[DEFAULT_WHITELISTING_KEY] else { return true }
        return entry[key] != ACTIVE
    }

    fileprivate func addContentBlocker(key: String, webview: FLTWKWebView) {
        if let list = compiledLists[key] {
            webview.configuration.userContentController.add(list)
        }
    }

    fileprivate func removeContentBlocker(key: String, webview: FLTWKWebView) {
        if let list = compiledLists[key] {
            webview.configuration.userContentController.remove(list)
        }
    }

    fileprivate func convertListOfHostsToContenRuleJson(hosts: [String]) -> String {
        let formattedHosts = hosts.map {
            "\"\($0)\""
        }.joined(separator: ",")
        return String(format: "[{\"trigger\":{\"url-filter\":\".*\",\"if-domain\":[%@]},\"action\":{\"type\":\"block\"}}]", formattedHosts)
    }
}

fileprivate func logOrFatal(message: String) {
    #if DEBUG
        fatalError(message)
    #else
        print(message)
    #endif
}
