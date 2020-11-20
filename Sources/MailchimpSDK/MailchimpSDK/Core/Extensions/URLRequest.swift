//
//  URLRequest.swift
//  Anzee
//
//  Created by Shawn Veader on 4/23/19.
//  Copyright 2019 The Rocket Science Group LLC
//
//    Licensed under the Mailchimp Mobile SDK License Agreement (the "License");
//    you may not use this file except in compliance with the License. Unless
//    required by applicable law or agreed to in writing, software distributed
//    under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
//    OR CONDITIONS OF ANY KIND, either or express or implied.
//
//    See the License for the specific language governing permissions and
//    limitations under the License.
//

import Foundation

extension URLRequest {
    /// Add a basic authorization header to the request.
    ///
    /// The username and password are combined and base 64 encoded per standards.
    ///
    /// - Parameters:
    ///     - username: `String` representing the username
    ///     - password: `String?` representing the password
    public mutating func addBasicAuthHeader(username: String, password: String?) {
        let authString = "\(username):\(password ?? "")"
        if let authData = authString.data(using: String.Encoding.utf8) {
            let base64AuthString = authData.base64EncodedString()
            setValue("Basic \(base64AuthString)", forHTTPHeaderField: "Authorization")
        }
    }
}
