//
//  MailchimpSDKTests.swift
//  MailchimpSDKTests
//
//  Created by Michael Patzer on 4/29/19.
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

class MailchimpSDKTests: XCTestCase {

    var token = "PUT YOUR API TOKEN HERE"
    var timeout: TimeInterval = 10
    
    override func setUp() {
        try? Mailchimp.initialize(token: token)
    }
    
    func testContactRequest() {
        let api = AnzeeAPI(token: token)
        let contact: Contact = Contact(emailAddress: "test@mailchimp.com")
        XCTAssertNotNil(contact)

        let testExpectation = expectation(description: "Network Request")
        let request = ContactRequest(contact: contact) { result in
            switch result {
            case .success(let responseData):
                XCTAssertNotNil(responseData)
            case .failure(let error):
                XCTAssertNotNil(error as APIError)
                if case .apiError(let response) = error {
                    XCTAssertEqual(response.status, 404)
                    XCTAssertEqual(response.type, "http://developer.mailchimp.com/documentation/mailchimp/guides/error-glossary/")
                    XCTAssertEqual(response.detail, "Invalid path")
                }
            }
            testExpectation.fulfill()
        }
        
        api.process(request: request)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testSDKInitialize() {
        do {
            try Mailchimp.initialize(token: "atesttoken-us1")
        } catch {
            XCTFail("MailchimpSDK cannot be initialized with the token: \(token)")
        }
        XCTAssertNotNil(Mailchimp.api)
    }
    
    func testEventRequest() {
        let api = AnzeeAPI(token: token)
        let event: Event = try! Event(emailAddress: "test@mailchimp.com", name: "TestEventName", properties: ["Attribute_One": "value"])
        
        XCTAssertNotNil(event)

        let testExpectation = expectation(description: "Network Request")
        let request = EventRequest(event: event) { result in
            switch result {
            case .success(let responseData):
                XCTAssertNotNil(responseData)
            case .failure(let error):
                XCTAssertNotNil(error as APIError)
                if case .apiError(let response) = error {
                    XCTAssertEqual(response.status, 404)
                    XCTAssertEqual(response.type, "http://developer.mailchimp.com/documentation/mailchimp/guides/error-glossary/")
                    XCTAssertEqual(response.detail, "Invalid path")
                }
            }
            testExpectation.fulfill()
        }
        
        api.process(request: request)
        waitForExpectations(timeout: timeout, handler: nil)
    }
    
    func testTags() {
        let tags = [Contact.Tag(name: "Ape", status: Contact.TagStatus.active),
                    Contact.Tag(name: "Simian", status: Contact.TagStatus.active),
                    Contact.Tag(name: "VIP", status: Contact.TagStatus.active)]

        var contact: Contact = Contact(emailAddress: "test@mailchimp.com")
        contact.tags = tags
        XCTAssertNotNil(contact.tags)
        XCTAssertEqual(3, contact.tags?.count)
    }

    func testPostBody() {
        let emailAddress = "test@mailchimp.com"
        let contact: Contact = Contact(emailAddress: emailAddress)
        let request = ContactRequest(contact: contact)

        XCTAssertNotNil(request.postBody())

        switch request.postBody().unsafelyUnwrapped {
        case .object(let object):
            XCTAssertEqual(emailAddress, object.emailAddress)
        default:
            XCTFail()
        }
    }

    // MockAnzeeAPI is a class since it's self-mutating
    class MockAnzeeAPI: API {
        var contactRequest: ContactRequest?

        func process<T>(request: T) -> URLSessionDataTask? where T : APIRequest {
            if let request = request as? ContactRequest {
                contactRequest = request
            }

            return nil
        }
    }

    func testAutotagging() {
        XCTAssertTrue(Mailchimp.autoTagContacts) // Defaults to true

        // Use mock API
        let mockApi = MockAnzeeAPI()
        Mailchimp.api = mockApi

        // Test the postBody has the expected tags per platform
        let contact: Contact = Contact(emailAddress: "test@mailchimp.com")
        
        let operation = Mailchimp.createOrUpdate(contact: contact)
        operation?.main()

        guard let request = operation?.request else {
            XCTFail()
            return
        }

        XCTAssertNotNil(request.postBody())

        var deviceTypeName: String = ""
        if UIDevice.current.userInterfaceIdiom == .pad {
            deviceTypeName = "Tablet"
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            deviceTypeName = "Phone"
        }

        switch request.postBody().unsafelyUnwrapped {
        case .object(let object):
            XCTAssertEqual("iOS", object.tags?[0].name)
            XCTAssertEqual(Contact.TagStatus.active, object.tags?[0].status)
            XCTAssertEqual(deviceTypeName, object.tags?[1].name)
            XCTAssertEqual(Contact.TagStatus.active, object.tags?[1].status)
        default:
            XCTFail()
        }


        // Test the postBody does not have tags
        Mailchimp.autoTagContacts = false
        Mailchimp.createOrUpdate(contact: contact)

        guard let noTagRequest = mockApi.contactRequest else {
            XCTFail()
            return
        }

        XCTAssertNotNil(noTagRequest.postBody())

        switch noTagRequest.postBody().unsafelyUnwrapped {
        case .object(let object):
            XCTAssertNotNil(object.tags)
        default:
            XCTFail()
        }

        Mailchimp.autoTagContacts = true // Reset value to default
    }

    // Many of these are tested in other tests, but this tests properties on the public interface for breaking changes
    func testPublicInterface() {
        XCTAssertFalse(Mailchimp.debugMode)
        XCTAssertTrue(Mailchimp.autoTagContacts)
        XCTAssertNotNil(Mailchimp.version)
        XCTAssertNotNil(Mailchimp.api) // This is not nil because the setUp calls initialize()
    }
}
