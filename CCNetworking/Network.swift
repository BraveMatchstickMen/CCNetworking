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

        let request = Request(url: url, method: method, parameters: params, completion: completion)
        request.request()
    }
}
