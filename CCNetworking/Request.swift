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
            urlPath += "?" + RequestEncoder.buildParams(parameters)
        }

        guard let url = URL(string: urlPath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else {
            preconditionFailure()
        }

        let request = NSMutableURLRequest(url: url)
        request.httpMethod = method.rawValue

        if method == .post {
            request.addValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
            request.httpBody = RequestEncoder.buildParams(parameters).data(using: .utf8)
        }

        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            self.completion(data, response, error)
        }

        task.resume()
    }
}
