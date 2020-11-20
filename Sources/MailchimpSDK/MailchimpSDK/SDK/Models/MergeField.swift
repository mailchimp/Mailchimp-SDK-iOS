//
//  MergeField.swift
//  MailchimpSDK
//
//  Created by Chez Browne on 5/21/19.
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

public enum MergeFieldValue: Codable {
    case string(String)
    case address(Address)
}

extension MergeFieldValue {
    enum CodingError: Error { case decoding(String) }

    public init(string: String) {
        self = .string(string)
    }

    public init(address: Address) {
        self = .address(address)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let string = try? container.decode(String.self) {
          self = .string(string)
          return
        }

        if let address = try? container.decode(Address.self) {
          self = .address(address)
          return
        }

        throw CodingError.decoding("Decoding Failed.")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let string):
            try container.encode(string)
        case .address(let address):
            try container.encode(address)
        }
    }
}

public struct Address: Codable, Equatable {
    public var addressLineOne: String
    public var addressLineTwo: String?
    public var city: String
    public var state: String?
    public var zipCode: String
    public var country: CountryCode

    enum CodingKeys: String, CodingKey {
        case addressLineOne = "addr1"
        case addressLineTwo = "addr2"
        case city
        case state
        case zipCode = "zip"
        case country
    }

    public init(
        addressLineOne: String,
        addressLineTwo: String?,
        city: String,
        state: String?,
        zipCode: String,
        country: CountryCode) {
        self.addressLineOne = addressLineOne
        self.addressLineTwo = addressLineTwo
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
    }
}
