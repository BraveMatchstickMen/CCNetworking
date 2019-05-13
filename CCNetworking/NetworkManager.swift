//
//  NetworkManager.swift
//  CCNetworking
//
//  Created by chai.chai on 2019/4/23.
//  Copyright © 2019 chai.chai. All rights reserved.
//

import Foundation

class NetworkManager {

    let method: String!
    let params: Dictionary<String, AnyObject>
    let callback: (Data?, URLResponse?, Error?) -> Void

    let session = URLSession(configuration: .default)
    let url: String!
    var request: NSMutableURLRequest!
    var task: URLSessionTask!

    init(url: String, method: String, params: [String: AnyObject], callback: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.url = url
        self.method = method
        self.params = params
        self.callback = callback
    }

    func buildRequest() {
        if method == "GET" && params.count > 0 {
            let urlPath = url + "?" + buildParams(params)
            guard let Url = URL(string: urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
                preconditionFailure()
            }
            request = NSMutableURLRequest(url: Url)
        }

        request.httpMethod = method

        if params.count > 0 {
            request.addValue("application/x-www-urlencoded", forHTTPHeaderField: "Content-Type")
        }
    }

    func buildBody() {
        if params.count > 0 && method != "GET" {
            request.httpBody = buildParams(params).data(using: .utf8)
        }
    }

    func fireTask() {
        task = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) in
            self.callback(data, response, error)
        })

        task.resume()
    }

    func fire() {
        buildRequest()
        buildBody()
        fireTask()
    }
}

extension NetworkManager {
    
    func buildParams(_ parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value: AnyObject! = parameters[key]
            components += self.queryComponents(key, value)
        }

        return components.map { "\($0) = \($1)" }.joined(separator: "&")
    }

    func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.append((escape(key), escape("\(value)")))
        }

        return components
    }

    func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
