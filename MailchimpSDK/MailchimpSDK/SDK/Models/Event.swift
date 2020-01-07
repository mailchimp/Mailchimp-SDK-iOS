//
//  Event.swift
//  MailchimpSDK
//
//  Created by Jennifer Starratt on 10/30/19.
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

public struct Event: Codable {
    public enum InitError: Error { case invalid(String) }
    
    public var emailAddress: String
    public var name: String
    public var properties: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case name = "event_name"
        case properties
    }
    
    /// Initializes an event
    /// - Parameters:
    ///   - emailAddress: The email address of the Contact
    ///   - name: Name of the Event (must be 30 characters or less)
    ///   - properties: Properties of the Event (names must include only A-z or underscores)
    public init(emailAddress: String, name: String, properties: [String: String]?) throws {
        guard name.count <= 30 else {
            throw InitError.invalid("Event names have a 30 character limit: \(name)")
        }

        for (propertyName, _) in properties ?? [:] {
            // Names are restricted to A-z and underscores
            var allowed = CharacterSet.letters
            allowed.insert("_")
            
            if propertyName.rangeOfCharacter(from: allowed.inverted) != nil {
                throw InitError.invalid("Property names must include only A-z or underscores: \(propertyName)")
            }
        }
        
        self.emailAddress = emailAddress
        self.name = name
        self.properties = properties
    }
}
