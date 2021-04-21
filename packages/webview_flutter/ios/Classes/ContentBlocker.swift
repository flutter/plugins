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

protocol ContentBlockerApi {
    func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void)
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

    @objc public func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        instance.setupContentBlocking(rules: rules, webview: webview, completion: completion)
    }
}

class ContentBlockerNotAvailable: ContentBlockerApi {
    func setupContentBlocking(rules: [String: [String: Any]], webview: FLTWKWebView, completion: @escaping () -> Void) {
        print("Content Blocking is not available for iOS prior 11")
        completion()
    }
}

@available(iOS 11.0, *)
class WKContentRuleBlocker: ContentBlockerApi {
    private var compiledLists = [String: WKContentRuleList]()

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
                self.addContentBlocker(key: res.key, webview: webview)
            }
            print("Loaded \(loadingResults.count) content rule sets")
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
                                            print("Couldn't compile the content rules \(error.localizedDescription)")
                                            completion(.errorCanNotCompileRules)
                                            return
                                        }

                                        self.compiledLists[key] = list
                                        completion(.success)
                                    }
            )
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
