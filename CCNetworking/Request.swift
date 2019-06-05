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
    public let parameters: [String: Any]
    public let completion: HTTPRequestCompletion
    let session = URLSession(configuration: .default)

    public init(url: String, method: HTTPMethod, parameters: [String: AnyObject], completion: @escaping HTTPRequestCompletion) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.completion = completion
    }

    func request(encoder: RequestEncoder = RequestEncoder.default) {
        do {
            guard let url = URL(string: url) else { return }
            var originRequest = URLRequest(url: url)
            originRequest.httpMethod = method.rawValue
            let encodedRequest = try encoder.encode(request: originRequest, parameters: parameters, contentType: .formURLEncoded)

            let task = session.dataTask(with: encodedRequest) { (data, response, error) in
                self.completion(data, response, error)
            }

            task.resume()
        } catch {

        }
    }
}
