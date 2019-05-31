//
//  Network.swift
//  CCNetworking
//
//  Created by chai.chai on 2019/4/22.
//  Copyright © 2019 chai.chai. All rights reserved.
//

import Foundation

public typealias HTTPRequestCompletion = (Data?, URLResponse?, Error?) -> Void

public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case trace = "TRACE"
    case connect = "CONNECT"
}

public enum ContentType: String {
    case none = ""
    case json = "application/json"
    case formURLEncoded = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data; boundary="
}

public class Network {
    public static func request(url: String,
                               method: HTTPMethod,
                               params: [String: AnyObject],
                               contentType: ContentType = .formURLEncoded,
                               completion: @escaping HTTPRequestCompletion) {

        let session = URLSession(configuration: .default)

        var urlPath = url
        if method == .get {
            urlPath += "?" + Network().buildParams(params)
        }

        guard let url = URL(string: urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            preconditionFailure()
        }

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue

        if method == .post {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            request.httpBody = Network().buildParams(params).data(using: .utf8)
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            completion(data, response, error)
        }

        task.resume()
    }
}

private extension Network {
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
