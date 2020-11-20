//
//  MergeFieldTests.swift
//  MailchimpSDKTests
//
//  Created by Chez Browne on 5/24/19.
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

class MergeFieldTests: XCTestCase {

    var token = "PUT YOUR API TOKEN HERE"
    
    override func setUp() {
        try? Mailchimp.initialize(token: token)
    }

    func testMergeFields() {
        let address = Address(addressLineOne: "123 Chimp St.",
                              addressLineTwo: "Suite 456",
                              city: "Atlanta",
                              state: "GA",
                              zipCode: "30308",
                              country: CountryCode.USA)
        let mergeFields = ["Title": MergeFieldValue.string("Mr."),
                           "Interest": MergeFieldValue.string("Bananas"),
                           "Home": MergeFieldValue.address(address)]
        
        var contact: Contact = Contact(emailAddress: "test@mailchimp.com")
        contact.mergeFields = mergeFields
        XCTAssertNotNil(contact.mergeFields)
        XCTAssertEqual(3, contact.mergeFields?.count)
    }
    
    func testCustomMergeFieldString() {
        let mockApi = MockAnzeeAPI()
        Mailchimp.api = mockApi
        
        mockApi.verifyRequest = { request in
            guard let contact = request?.contact else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(contact.emailAddress, "test@mailchimp.com")
            
            guard let fields = contact.mergeFields, let genre = fields.first else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(fields.count, 1)
            XCTAssertEqual("Genre", genre.key)

            if case .string(let value) = genre.value {
                XCTAssertEqual("Action", value)
            } else {
                XCTFail("")
            }
        }
        
        let fieldName = "Genre"
        let favoriteGenre = "Action"
        Mailchimp.setMergeField(emailAddress: "test@mailchimp.com", name: fieldName, value: favoriteGenre)
    }
    
    func testCustomMergeFieldAddress() {
        let mockApi = MockAnzeeAPI()
        Mailchimp.api = mockApi
        
        mockApi.verifyRequest = { request in
            guard let contact = request?.contact else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(contact.emailAddress, "test@mailchimp.com")
            
            guard let fields = contact.mergeFields, let address = fields.first else {
                XCTFail()
                return
            }
            
            XCTAssertEqual(fields.count, 1)
            XCTAssertEqual("Second Home", address.key)
            
            if case .address(let value) = address.value {
                let a1 = Address(addressLineOne: "123 Chimp St.",
                                 addressLineTwo: "Suite 456",
                                 city: "Atlanta",
                                 state: "GA",
                                 zipCode: "30308",
                                 country: CountryCode.USA)
                XCTAssertEqual(a1, value)
            } else {
                XCTFail("")
            }
        }
        
        let fieldName = "Second Home"
        let address = Address(addressLineOne: "123 Chimp St.",
                              addressLineTwo: "Suite 456",
                              city: "Atlanta",
                              state: "GA",
                              zipCode: "30308",
                              country: CountryCode.USA)
        Mailchimp.setMergeField(emailAddress: "test@mailchimp.com", name: fieldName, address: address)
    }
    
    // MockAnzeeAPI in a class since it's self-mutating
     class MockAnzeeAPI: API {
        var verifyRequest: ((ContactRequest?) -> Void)?
        
        func process<T>(request: T) -> URLSessionDataTask? where T : APIRequest {
            verifyRequest?(request as? ContactRequest)

            return nil
        }
        
    }

}
