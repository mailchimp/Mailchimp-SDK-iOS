<p align="center">
  <a href="https://mailchimp.com/developer/">
    <img src="https://raw.githubusercontent.com/mailchimp/mailchimp-client-lib-codegen/master/resources/images/mcdev-banner.png" alt="Mailchimp Developer" width="100%" height="auto">
  </a>
</p>

# MailchimpSDK-iOS

##### Table of Contents  
[Getting Started](#getting-started)  
[Installation](#installation)  
[Initializing the SDK](#initializing-the-sdk)  
[Collecting contact information](#collecting-contact-information)  
[Contact Schema](#contact-schema)  
[Collecting contact events](#collecting-contact-events)  
[Event Schema](#event-schema)

## Getting Started

### Requirements

* Deployment target iOS 12.0 or above
* Xcode version 11 or above
* Ruby 2.4 or above (for fastlane)

### Retrieving SDK Key

* See the [Mailchimp SDK documentation](https://mailchimp.com/developer/guides/mobile-sdk-ios/#Step_1._Retrieve_the_SDK_Key) for details on retrieving the key.

## Installation
### Option 1: Cocoapods
For the latest version of our SDK, add the following to your project's Podfile:
```
pod 'MailchimpSDK'
```

### Option 2: Manual
1. Clone this repository
2. Run `bundle exec fastlane create_binary_framework` to build the Swift binary framework for iOS and iOS Simulator.
3. Add the XCFramework:

  Click on the Project navigator, select your app’s target, go to the General tab, scroll down to Frameworks, Libraries, and Embedded Content. Drag the Mailchimp.xcframework from this repo into this section.

  ![Drag the framework into Frameworks, Libraries, and Embedded Content](https://user-images.githubusercontent.com/42216769/69161161-8f641480-0a9f-11ea-93ec-5599aac85423.gif)
  
  ### Option 3: Swift Package Manager
  To use Swift Package Manager, in Xcode, click File -> Swift Packages -> Add Package Dependency, enter MailchimpSDK repo's URL or you can log into Xcode with your GitHub account and just type MailchimpSDK to search.


## Initializing the SDK

The initialize method has three different fields.

* SDK Key (Required): The SDK key gives you access to your audience.
* Debug Mode (Optional): Debug Mode enables additional debug only functionality such as extra logging. This is off by default.
* Auto Tagging (Optional): Auto Tagging automatically tags contacts with information such as Device Type and Platform. This is on by default.

```swift
Mailchimp.initialize(token: sdkKey)
```

## Collecting contact information

### Adding A Contact

To add a contact to your Mailchimp audience, first instantiate a new Contact struct. Then pass the contact into the `createOrUpdate()` method. This will add the contact to your Mailchimp audience with applied merge fields and/or tags. If the contact already exists, their information will be updated with the values that were passed in.

```swift
var contact: Contact = Contact(emailAddress: "example@email.com")
let mergeFields = ["FNAME": MergeFieldValue.string("Example"),
                   "LNAME": MergeFieldValue.string("User")]
contact.status = .subscribed
contact.mergeFields = mergeFields
contact.tags = [Contact.Tag(name: "mobile-signup", status: .active)]
Mailchimp.createOrUpdate(contact: contact) { result in
    switch result {
    case .success:
        print("Successfully added or updated contact")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

### Updating a Contact

You may update a contact by using the same `createOrUpdate()` method described in the Adding a Contact section.

In addition to updating a whole contact, we provide a number of methods to update a single fields on a contact. These are executed as separate network requests. To update multiple fields at once, use the `createOrUpdate()` method.

Single field update methods include

* `addTag()`: Adds a tag to the given user.
* `addTags()`: Adds multiple tags to the given user.
* `removeTag()`: Removes a tag from the given user.
* `removeTags()`: Removes multiple tags from the given user.
* `setMergeField()`: Sets or updates the merge field for a given user.

### Add/Remove Tags

```swift
Mailchimp.addTag(name: tagName,
                   emailAddress: "example@email.com") { result in
                   switch result {
                   case .success:
                       print("Successfully added tag: \(tagName)")
                   case .failure(let error):
                       print("Error: \(error.localizedDescription)")
                   }
               }

Mailchimp.removeTag(name: tagName,
                      emailAddress: "example@email.com") { result in
                      switch result {
                      case .success:
                         print("Successfully removed tag: \(tagName)")
                      case .failure(let error):
                         print("Error: \(error.localizedDescription)")
                      }
               }
```

### Set Merge Fields

```swift
Mailchimp.setMergeField(emailAddress: "example@email.com",
                          name: fieldName,
                          value: fieldValue) { result in
                          switch result {
                          case .success:
                               print("Successfully added merge field: \(fieldName), \(fieldValue)")
                          case .failure(let error):
                               print("Error: \(error.localizedDescription)")
                          }
               }
```
## Contact Schema

### Email

The Email Address is the unique identifier for each contact in an audience. An email address is required for every interaction with the SDK.

### Tags

Users can add or remove tags from their contact information. Each tag is identified using a String. If a tag has not been previously used on your account, it will be created.

#### Autotagging

If autotagging is enabled, all created or updated contacts will be automatically tagged with `iOS` and either `Phone` or `Tablet`.

### Merge Fields

Merge fields are key value pairs that can be set on each contact. They can be customized for each audience. Common examples of merge fields are first name, last name, and phone number.
The value of a merge field can be set and updated from the SDK. Merge fields are keyed off of a capitalized string. The Key does not include vertical bars on either end (ex. FNAME and not |FNAME|).

While Merge Fields can be marked as required on the audience settings, those requirements will not be enforced when using the Mailchimp SDK.

#### String Merge Fields
The majority of merge field types are represented as a String. This includes Text, Number, Radio Buttons, Drop Downs, Dates, Birthday, Phone Numbers, and Websites.

#### Address Merge Fields

Merge Fields of type address are represented as an Address struct. Addresses have three required fields, Address Line One, City, and Zip.
In addition there are three optional fields, Address Line Two, State, and Country. Below is an example of an Address object.

```swift
let address = Address(addressLineOne: "123 Chimp St.",
                      addressLineTwo: "Suite 456",
                      city: "Atlanta",
                      state: "GA",
                      zipCode: "30308",
                      country: CountryCode.USA)
```

### Contact Status

The Contact Status represents what type of communication the user has consented to. This can either be Subscribed (will receive general marketing campaigns) or Transactional (will only receive transactional emails).
This value can only be set when the contact is created. If this is set at any other time, the new value will be ignored. By default all users will be marked as transactional if this value is not set at creation.

You can subscribe a new contact to general marketing campaigns by setting `status`.

```swift
contact.status = .subscribed
```

### Marketing Permissions

Appropriate marketing permissions need to be set to communicate with any contact/s added to an audience with GDPR enabled fields. These fields specify how a contact would like their information to be used (ex: for direct mail or for customized online advertising).

Marketing permissions are set by instantiating a MarketingPermission struct with the corresponding `marketingPermissionsId` and setting `enabled` if the user granted permission for that permission ID.

```swift
let permission1 = Contact.MarketingPermission(marketingPermissionId: "permission1", enabled: true)
```

## Collecting contact events

### Adding an event

To add an event associated with a contact, first instantiate a new Event struct. Then pass the event into the `trackEventWithAttributes()` method. This will add the event to the specified contact.

```swift
let event: Event = try! Event(emailAddress: "example@email.com", name: "signup", properties: ["source": "iOS"])
Mailchimp.trackEventWithAttributes(event: event) { result in
    switch result {
    case .success:
        print("Successfully tracked an event")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}
```

## Event Schema

### Email

The Email Address is the unique identifier for each contact in an audience. An email address is required for every interaction with the SDK.

### Name

Each event is identified using a String. The maximum length of an event name is 30 characters.

### Properties

Any event can have properties associated with it. These properties have a String key and String value. Property names are limited to A-z and underscores.

## FAQ

Do you have an Android version?
>Yes! You can find it [here](https://github.com/mailchimp/Mailchimp-SDK-Android)

Why is the SDK throwing an error when I try to create a contact?
>Check that you are initializing the SDK with the correct token format. The token includes the `-us` suffix.

Why do calls silently fail?
>For security, our SDK is write-only. Contact data cannot be retrieved via the SDK. Calls fail silently so that contact data cannot be deduced from error messages. (e.g. If adding a contact failed loudly, one could deduce that the contact exists on your list.)

How do I use the SDK in my Objective-C project?
>The best way to interact with an Objective-C project is to create a Swift wrapper object that can initialize the SDK and create a contact for you.

Does the Mailchimp mobile SDK track my users?
>The Mailchimp mobile SDK does not track your users. The Mailchimp mobile SDK automatically adds your mobile application users to your Mailchimp audience so that you can send them marketing communications. Mailchimp does not provide information about your app’s users to data brokers. The mobile SDK does not combine user data from your app with information from other apps in order to place targeted advertisements. For more information regarding Mailchimp’s mobile SDK, please click [here](https://mailchimp.com/help/mobile-sdk/).
