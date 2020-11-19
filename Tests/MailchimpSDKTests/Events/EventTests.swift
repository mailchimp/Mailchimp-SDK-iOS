//
//  EventTests.swift
//  MailchimpSDKTests
//
//  Created by Jennifer Starratt on 10/31/19.
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

import XCTest
@testable import MailchimpSDK

class EventTests: XCTestCase {
    func testValidEvent() {
        let emailAddress = "test@mailchimp.com"
        let name = "TestEventName"
        let properties = ["Attribute_One": "value"]
        
        XCTAssertNoThrow(try Event(emailAddress: emailAddress, name: name, properties: properties))
    }
    
    func testInvalidEventName() {
        let emailAddress = "test@mailchimp.com"
        let name = "TestEventNamesLongerThan30Chars"
        let properties = ["Attribute_One": "value"]
        
        XCTAssertThrowsError(try Event(emailAddress: emailAddress, name: name, properties: properties))
    }
    
    func testInvalidPropertyName() {
        let emailAddress = "test@mailchimp.com"
        let name = "TestEventName"
        let properties = ["Attribute-One": "value"]
        
        XCTAssertThrowsError(try Event(emailAddress: emailAddress, name: name, properties: properties))
    }
}
