//
//  PostBody.swift
//  MailchimpSDK
//
//  Created by Michael Patzer on 5/7/19.
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

// The PostBody may be an object that conforms to the Codable protocol (case object),
// or an object that conforms to the PostBodyParamable protocol (case params).
enum PostBody<T: Codable, U: PostBodyParamable> {
    case object(T)
    case params(U)
}

protocol PostBodyParamable {
    var params: [String: String] { get }
}

// A default empty implementation of the PostBodyParamable protocol,
// to be used when a function returns a PostBody of the other type
struct ParametersDefault: PostBodyParamable {
    var params: [String : String] = [:]
}

// A default empty implementation of the Codable protocol,
// to be used when a function returns a PostBody of the other type
struct CodableDefault: Codable {}
