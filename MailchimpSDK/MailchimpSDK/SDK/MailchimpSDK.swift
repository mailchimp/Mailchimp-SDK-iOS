//
//  MailchimpSDK.swift
//  Mailchimp SDK
//
//  Created by Chez Browne on 5/13/19.
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

/// Provides an interface for storing user behavior in Mailchimp
///
public class MailchimpSDK: NSObject {
    public enum InitError: Error { case invalidToken(String) }
    
    /// Automatically tags contacts with basic device information when created or updated. On by default.
    public static var autoTagContacts: Bool = true

    /// Toggles debug mode which prints logs to the console. Off by default.
    public static var debugMode: Bool = false

    /// Version of this SDK.
    public static let version: String = "0.1.2"

    /// The API protocol conforming object that processes requests for this class.
    static var api: API?
    
    static var tokenRegex = #"^[A-z0-9]*-us[0-9]*$"#

    public typealias RequestCallback = (Result<Data, APIError>) -> Void
    private static var serialOperationQueue: OperationQueue = {
      var queue = OperationQueue()
      queue.maxConcurrentOperationCount = 1
      return queue
    }()
    
    /// Initializes SDK with API token, and optional configuration settings.
    /// (Throws if the token is malformed)
    public class func initialize(token: String, autoTagContacts: Bool = true, debugMode: Bool = false) throws {
        guard token.range(of: tokenRegex, options: .regularExpression) != nil else {
            throw InitError.invalidToken(token)
        }
        
        api = AnzeeAPI(token: token)
        MailchimpSDK.autoTagContacts = autoTagContacts
        MailchimpSDK.debugMode = debugMode

        if debugMode {
            print("Mailchimp SDK Initialized. Version: \(version)")
        }
    }
    
    /// Creates a new Contact and permanently sets the status. If the Contact already exists, contact
    /// information (other than status, which is permanent) is updated.
    ///
    /// If no status is set for the Contact, the status permanently defaults to a Transactional status.
    /// For GDPR compliance, set marketing permissions before creating a new Contact.
    ///
    /// - Parameters:
    ///     - contact: A Mailchimp contact
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func createOrUpdate(contact: Contact, result: RequestCallback? = nil) -> ContactOperation? {
        var contactInfo = contact // Editable copy, in case of auto-tagging

        if autoTagContacts {
            let combinedTags = autoTags() + (contactInfo.tags ?? [])
            contactInfo.tags = combinedTags

            if debugMode {
                for tag in autoTags() {
                    print("Adding auto-tag \"\(tag.name)\" to create contact request.")
                }
            }
        }

        return executeRequestForContact(contact: contactInfo, result: result)
    }

    @discardableResult
    fileprivate class func executeRequestForContact(contact: Contact, result: RequestCallback? = nil) -> ContactOperation? {
        let contactOperation = ContactOperation(contact, result: result)
        serialOperationQueue.addOperation(contactOperation)

        return contactOperation
    }
    
    @discardableResult
    fileprivate class func updateMergeFields(emailAddress: String, fields: [String: MergeFieldValue], result: RequestCallback? = nil) -> ContactOperation? {
         var contact = Contact(emailAddress: emailAddress)
         contact.mergeFields = fields
         return executeRequestForContact(contact: contact, result: result)
     }
    
    
    /// MARK  Convenience methods

    /// Adds a tag to a Contact by email address
    ///
    /// - Parameters:
    ///     - name: Name of the tag to add
    ///     - emailAddress: Email address of the contact to add the tag to
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func addTag(name: String, emailAddress: String, result: RequestCallback? = nil) -> ContactOperation? {
        let tag = Contact.Tag(name: name, status: Contact.TagStatus.active)
        return toggleTags(tags: [tag], emailAddress: emailAddress, result: result)
    }

    /// Adds tags to a Contact by email address
    ///
    /// - Parameters:
    ///     - names: Names of the tags to add
    ///     - emailAddress: Email address of the contact to add the tags to
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func addTags(names: [String], emailAddress: String, result: RequestCallback? = nil) -> ContactOperation? {
        let tags = names.map { name -> Contact.Tag in
            return Contact.Tag(name: name, status: Contact.TagStatus.active)
        }

        return toggleTags(tags: tags, emailAddress: emailAddress, result: result)
    }

    /// Removes a tag from a Contact by email address
    ///
    /// - Parameters:
    ///     - name: Name of the tag to remove
    ///     - emailAddress: Email address of the contact to remove the tag from
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func removeTag(name: String, emailAddress: String, result: RequestCallback? = nil) -> ContactOperation? {
        let tag = Contact.Tag(name: name, status: Contact.TagStatus.inactive)
        return toggleTags(tags: [tag], emailAddress: emailAddress, result: result)
    }

    /// Removes tags from a Contact by email address
    ///
    /// - Parameters:
    ///     - names: Names of the tags to remove
    ///     - emailAddress: Email address of the contact to remove the tags from
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func removeTags(names: [String], emailAddress: String, result: RequestCallback? = nil) -> ContactOperation? {
        let tags = names.map { name -> Contact.Tag in
            return Contact.Tag(name: name, status: Contact.TagStatus.inactive)
        }

        return toggleTags(tags: tags, emailAddress: emailAddress, result: result)
    }

    private class func toggleTags(tags: [Contact.Tag], emailAddress: String, result: RequestCallback? = nil) -> ContactOperation? {
        var contact = Contact(emailAddress: emailAddress)
        contact.tags = tags

        return executeRequestForContact(contact: contact, result: result)
    }

    private class func autoTags() -> [Contact.Tag] {
        let platform = "iOS"
        let deviceType: String?

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            deviceType = "Tablet"
        case .phone:
            deviceType = "Phone"
        default:
            deviceType = nil
        }

        var tags = [Contact.Tag(name: platform, status: .active)]

        // Only auto-tag device type if a valid type is detected. Sending a blank Tag to the API is a bad practice.
        if let deviceType = deviceType {
            tags.append(Contact.Tag(name: deviceType, status: .active))
        }

        return tags
    }

    /// Adds a String MergeField value to a Contact by email address
    ///
    /// - Parameters:
    ///     - emailAddress: Email address of the contact
    ///     - name: Name of the Merge Field
    ///     - value: String passed in for the Merge Field value
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func setMergeField(emailAddress: String, name: String, value: String, result: RequestCallback? = nil) -> ContactOperation? {
        return updateMergeFields(emailAddress: emailAddress, fields: [name: MergeFieldValue(string: value)], result: result)
    }
    
    /// Adds an Address MergeField to a Contact by email address
    ///
    /// - Parameters:
    ///     - emailAddress: Email address of the contact
    ///     - name: Name of the Merge Field
    ///     - value: Address passed in for the Merge Field value
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func setMergeField(emailAddress: String, name: String, address: Address, result: RequestCallback? = nil) -> ContactOperation? {
        return updateMergeFields(emailAddress: emailAddress, fields: [name: MergeFieldValue(address: address)], result: result)
    }
    
    
    /// Sets the status for a Contact ONLY if a contact has NOT yet been created with the supplied email address
    /// Otherwise, this method will NOT change the status of a contact
    ///
    /// - Parameters:
    ///     - emailAddress: Email address of the contact
    ///     - status: Status of the Contact
    /// - Returns: `ContactOperation?`
    @discardableResult
    public class func setContactStatus(emailAddress: String, status: Contact.Status, result: RequestCallback? = nil) -> ContactOperation? {
        var contact = Contact(emailAddress: emailAddress)
        contact.status = status
        return executeRequestForContact(contact: contact, result: result)
    }
    
    /// Adds a new event for the given email address.
    ///
    /// - Parameters:
    ///     - event: A Mailchimp event for a contact
    ///     - result: Callback with the Result (success/failure) of the action
    /// - Returns: `EventOperation?`
    @discardableResult
    public class func trackEventWithAttributes(event: Event, result: RequestCallback? = nil) -> EventOperation? {
        return executeRequestForEvent(event: event, result: result)
    }

    @discardableResult
    fileprivate class func executeRequestForEvent(event: Event, result: RequestCallback? = nil) -> EventOperation? {
        let eventOperation = EventOperation(event, result: result)
        serialOperationQueue.addOperation(eventOperation)

        return eventOperation
    }
}
