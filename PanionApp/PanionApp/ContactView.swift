//
//  ContactView.swift
//  PanionApp
//
//  Created by Chez Browne on 8/5/19.
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

import Combine
import SwiftUI
import MailchimpSDK

class ContactFormData: ObservableObject {
    class MergeField {
        var key: String
        var value: String

        init(_ key: String, _ value: String) {
            self.key = key
            self.value = value
        }
    }

    enum Status: String, Codable {
        case subscribed
        case transactional
        case none

        var contactStatus: Contact.Status? {
            switch self {
            case .subscribed: return Contact.Status.subscribed
            case .transactional: return Contact.Status.transactional
            default: return nil
            }
        }
    }

    @Published var emailAddress: String = ""
    @Published var status: Status = .none
    @Published var address: Address? = nil

    @Published var tagsToAdd: [String] = []
    @Published var tagsToRemove: [String] = []
    @Published var pendingTag: String = ""

    @Published var mergeFields: [MergeField] = []
    @Published var pendingMergeFieldName: String = ""
    @Published var pendingMergeFieldValue: String = ""

    @Published var canSendEmail: Bool = false
    @Published var canSendDirectMail: Bool = false
    @Published var canCustomizeAds: Bool = false
}

struct ContactView: View {
    @ObservedObject private var contactFormData = ContactFormData()
    @State var showDetail = false
    @State private var showingAlert = false

    var body: some View {
        Form {
            DetailRow(labelText: "Email Address:", detailText: "Enter your email address", data: $contactFormData.emailAddress)

            VStack(alignment: .leading) {
                Text("Status")
                    .bold()
                Picker(selection: $contactFormData.status, label: Text("Status")) {
                    Text("None").tag(ContactFormData.Status.none)
                    Text("Subscribed").tag(ContactFormData.Status.subscribed)
                    Text("Transactional").tag(ContactFormData.Status.transactional)
                }
                    .pickerStyle(SegmentedPickerStyle())
            }

            NavigationLink(destination: AddressView(contactFormData: contactFormData), isActive: $showDetail) {
                VStack(alignment: .leading) {
                    Text("Address:").bold()
                    Text(contactFormData.address?.string ?? "")
                }
            }

            Section(header: Header(text: "Merge Fields")) {
                VStack(alignment: .leading) {
                    Text("Add a merge field")
                        .bold()
                    HStack {
                        TextField("Name", text: $contactFormData.pendingMergeFieldName)
                        TextField("Value", text: $contactFormData.pendingMergeFieldValue)
                        Spacer()
                        Button(action: {
                            self.addMergeField()
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                // ForEach on index because it does not seem to support bindings
                ForEach(0..<self.contactFormData.mergeFields.count, id: \.self) { index in
                    HStack {
                        TextField("", text: self.$contactFormData.mergeFields[index].key)
                        TextField("", text: self.$contactFormData.mergeFields[index].value)
                    }
                }
            }

            Section(header: Header(text: "Tags")) {
                VStack(alignment: .leading) {
                    Text("Add a tag")
                        .bold()
                    HStack {
                        TextField("Name", text: $contactFormData.pendingTag)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        Spacer()
                        Button(action: {
                            self.addTag()
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                ForEach(self.contactFormData.tagsToAdd, id: \.self) { tag in
                    ContactRowTag(tagText: tag)
                        .onTapGesture {
                            self.contactFormData.tagsToAdd.removeAll { $0 == tag }
                            self.contactFormData.tagsToRemove.append(tag)
                    }
                }
            }

            VStack(alignment: .leading) {
                Text("Permission To")
                    .bold()
                Toggle(isOn: $contactFormData.canSendEmail) {
                    Text("Send You Email")
                }
                Toggle(isOn: $contactFormData.canSendDirectMail) {
                    Text("Send You Direct Email")
                }
                Toggle(isOn: $contactFormData.canCustomizeAds) {
                    Text("Customize Your Online Ads")
                }
            }

        }.navigationBarItems(trailing:
            Button(action: {
                self.addContactAction()
            }) {
                Text("Add/Update Contact")
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Completed"), dismissButton: .default(Text("OK")))
        }
    }

    /// Button methods

    func addTag() {
        let trimmedTagName = self.contactFormData.pendingTag.trimmingCharacters(in: .whitespaces)

        if trimmedTagName != "" {
            self.contactFormData.tagsToAdd.append(trimmedTagName)
            self.contactFormData.pendingTag = ""
        }
    }

    func addMergeField() {
        let trimmedFieldName = self.contactFormData.pendingMergeFieldName.trimmingCharacters(in: .whitespaces)
        let trimmedFieldValue = self.contactFormData.pendingMergeFieldValue.trimmingCharacters(in: .whitespaces)

        if trimmedFieldName != "" && trimmedFieldValue != "" {
            self.contactFormData.mergeFields.append(ContactFormData.MergeField(trimmedFieldName, trimmedFieldValue))
            self.contactFormData.pendingMergeFieldName = ""
            self.contactFormData.pendingMergeFieldValue = ""
        }
    }

    func addContactAction() {
        let emailAddress = self.contactFormData.emailAddress
        let status = self.contactFormData.status
        var contact = Contact(emailAddress: emailAddress)
        if let status = status.contactStatus {
            contact.status = status
        }

        let emailPermission = Contact.MarketingPermission(marketingPermissionId: "84fe21b67f", enabled: self.contactFormData.canSendEmail)
        let mailPermission = Contact.MarketingPermission(marketingPermissionId: "37975cc3fe", enabled: self.contactFormData.canSendDirectMail)
        let adPermission = Contact.MarketingPermission(marketingPermissionId: "12e3771672", enabled: self.contactFormData.canCustomizeAds)

        contact.marketingPermissions = [emailPermission, mailPermission, adPermission]

        let group = DispatchGroup()

        Mailchimp.createOrUpdate(contact: contact) { result in
            switch result {
            case .success:
                print("Successfully added or updated contact: \(emailAddress)")
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }

            // Once contact is created/updated then adjust the rest
            self.addAddress(group)
            self.addMergeFields(group)
            self.addTags(group)
            self.removeTags(group)
        }

        group.notify(queue: .main) {
            self.showingAlert = true
        }
    }

    func addAddress(_ group: DispatchGroup) {
        if let address = self.contactFormData.address {
            group.enter()
            Mailchimp.setMergeField(emailAddress: self.contactFormData.emailAddress,
                                   name: "ADDRESS",
                                   address: address) { result in
                                    switch result {
                                    case .success:
                                        print("Successfully added address.")
                                    case .failure(let error):
                                        print("Error: \(error.localizedDescription)")
                                    }
                                    group.leave()
            }
        }
    }

    func addMergeFields(_ group: DispatchGroup) {
        guard !self.contactFormData.mergeFields.isEmpty else { return }

        for mergeField in self.contactFormData.mergeFields {
            group.enter()
            let (key, value) = (mergeField.key, mergeField.value)
            Mailchimp.setMergeField(emailAddress: self.contactFormData.emailAddress, name: key, value: value) { result in
                switch result {
                case .success:
                    print("Successfully added merge field: \(key), \(value)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
    }

    func addTags(_ group: DispatchGroup) {
        for tagToAdd in self.contactFormData.tagsToAdd {
            group.enter()
            Mailchimp.addTag(name: tagToAdd, emailAddress: self.contactFormData.emailAddress) { result in
                switch result {
                case .success:
                    print("Successfully added tag: \(tagToAdd)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
    }

    func removeTags(_ group: DispatchGroup) {
        for tagToRemove in self.contactFormData.tagsToRemove {
            group.enter()
            Mailchimp.removeTag(name: tagToRemove, emailAddress: self.contactFormData.emailAddress) { result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self.contactFormData.tagsToRemove = []
                    }
                    print("Successfully removed tag: \(tagToRemove)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
                group.leave()
            }
        }
    }
}

struct ContactRowTag: View, Identifiable {
    var id = UUID()
    var tagText: String

    var body: some View {
        HStack {
            Text("\(tagText)")
            Spacer()
            Image(systemName: "minus.circle")
        }
    }
}

extension Address {
    var string: String {
        let addressLineTwoValue = addressLineTwo.flatMap { $0.isEmpty ? nil : $0 }
        let stateValue = state.flatMap { $0.isEmpty ? nil : $0 }

        switch (addressLineTwoValue, stateValue) {
        case (nil, nil):
            return """
                   \(addressLineOne)
                   \(city) \(country) \(zipCode)
                   """
        case let (a2?, nil):
            return """
                   \(addressLineOne) \(a2)
                   \(city) \(country) \(zipCode)
                   """
        case let (nil, s?):
            return """
                   \(addressLineOne)
                   \(city), \(s) \(country) \(zipCode)
                   """
        case let (a2?, s?):
            return """
                   \(addressLineOne) \(a2)
                   \(city), \(s) \(country) \(zipCode)
                   """
        }
    }
}
