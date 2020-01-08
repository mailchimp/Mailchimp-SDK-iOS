//
//  Contact.swift
//  Mailchimp SDK
//
//  Created by Michael Patzer on 5/6/19.
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

public struct Contact: Codable {
    public var emailAddress: String
    public var tags: [Tag]?
    public var marketingPermissions: [MarketingPermission]?
    public var mergeFields: [String: MergeFieldValue]?
    public var status: Status?
    
    enum CodingKeys: String, CodingKey {
        case emailAddress = "email_address"
        case tags
        case marketingPermissions = "marketing_permissions"
        case mergeFields = "merge_fields"
        case status
    }

    public enum TagStatus: String, Codable {
        case active
        case inactive
    }
    
    public enum Status: String, Codable {
        case subscribed
        case transactional
    }

    public struct Tag: Codable {
        public let name: String
        public let status: TagStatus

        public init(name: String, status: TagStatus) {
            self.name = name
            self.status = status
        }
    }
    
    public struct MarketingPermission: Codable {
        public let marketingPermissionId: String
        public let enabled: Bool
        
        enum CodingKeys: String, CodingKey {
            case marketingPermissionId = "marketing_permission_id"
            case enabled
        }
        
        public init(marketingPermissionId: String, enabled: Bool) {
                self.marketingPermissionId = marketingPermissionId
                self.enabled = enabled
            }
    }

    public init(emailAddress: String) {
        self.emailAddress = emailAddress
    }
}
