//
//  Request.swift
//  CCNetworking
//
//  Created by chai.chai on 2019/5/31.
//  Copyright © 2019 chai.chai. All rights reserved.
//

import Foundation

public class Request {
    public let url: String
    public let method: HTTPMethod
    public let parameters: [String: AnyObject]
    public let completion: HTTPRequestCompletion

    public init(url: String, method: HTTPMethod, parameters: [String: AnyObject], completion: @escaping HTTPRequestCompletion) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.completion = completion
    }

    public func request(contentType: ContentType = .formURLEncoded) {

        let session = URLSession(configuration: .default)

        var urlPath = url
        if method == .get {
            urlPath += "?" + Request.buildParams(parameters)
        }

        guard let url = URL(string: urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            preconditionFailure()
        }

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue

        if method == .post {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            request.httpBody = Request.buildParams(parameters).data(using: .utf8)
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            self.completion(data, response, error)
        }

        task.resume()
    }
}

private extension Request {
    static func buildParams(_ parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sorted(by: <) {
            let value: AnyObject! = parameters[key]
            components += queryComponents(key, value)
        }

        return components.map { "\($0) = \($1)" }.joined(separator: "&")
    }

    static func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
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

    static func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")

        return string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
    }
}
