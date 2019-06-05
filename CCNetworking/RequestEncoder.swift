//
//  RequestEncoder.swift
//  CCNetworking
//
//  Created by chai.chai on 2019/6/4.
//  Copyright © 2019 chai.chai. All rights reserved.
//

import Foundation

typealias KeyValuePair = (key: String, value: Any)

struct RequestEncoder {
    static let `default` = RequestEncoder()
    
    func encode(request: URLRequest, parameters: [String: Any], contentType: ContentType) throws -> URLRequest {
        guard let url = request.url else {
            throw NSError(domain: "com.cc.network", code: 1000, userInfo: nil)
        }
        guard let method = HTTPMethod(rawValue: request.httpMethod ?? HTTPMethod.get.rawValue) else {
            return request
        }

        switch contentType {
        case .none:
            return request
        case .formURLEncoded:
            return try urlEncode(request, url: url, method: method, parameters: parameters, contentType: contentType)
        case .json:
            return request
        case .multipartFormData:
            return request
        }
    }

    func urlEncode(_ request: URLRequest, url: URL, method: HTTPMethod, parameters: [String: Any], contentType: ContentType) throws -> URLRequest {
        var request = request

        let pairs: [KeyValuePair] = dictToKeyValuePair(parameters)

        request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")

        switch method {
        case .get, .head, .delete:
            if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !pairs.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + query(pairs)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents.url
            }
        default:
            request.httpBody = query(pairs).data(using: .utf8, allowLossyConversion: false)
        }

        return request
    }
}

private extension RequestEncoder {
    func query(_ pairs: [KeyValuePair]) -> String {
        var components: [(String, String)] = []

        for (key, value) in pairs.sorted(by: { $0.key < $1.key }) {
            components += queryComponents(key, value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }

    private func dictToKeyValuePair(_ dict: [String: Any]) -> [KeyValuePair] {
        return dict.map({ ($0.key, $0.value) })
    }

    func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
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
