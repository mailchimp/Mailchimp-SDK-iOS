//
//  EventView.swift
//  PanionApp
//
//  Created by Jennifer Starratt on 11/7/19.
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

import SwiftUI
import MailchimpSDK

class EventFormData: ObservableObject {
    class Property {
        var key: String
        var value: String

        init(_ key: String, _ value: String) {
            self.key = key
            self.value = value
        }
    }

    @Published var emailAddress: String = ""
    @Published var eventName: String = ""

    @Published var properties: [Property] = []
    @Published var pendingPropertyKey: String = ""
    @Published var pendingPropertyValue: String = ""
}

struct EventView: View {
    @ObservedObject private var eventFormData = EventFormData()
    @State private var showingAlert = false

    var body: some View {
        Form {
            DetailRow(labelText: "Email Address:", detailText: "Enter your email address", data: $eventFormData.emailAddress)
            
            DetailRow(labelText: "Event Name:", detailText: "Enter your event name", data: $eventFormData.eventName)

            Section(header: Header(text: "Properties (optional)")) {
                VStack(alignment: .leading) {
                    Text("Add a property")
                        .bold()
                    HStack {
                        TextField("Key", text: $eventFormData.pendingPropertyKey)
                        TextField("Value", text: $eventFormData.pendingPropertyValue)
                        Spacer()
                        Button(action: {
                            self.addProperty()
                        }) {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                // ForEach on index because it does not seem to support bindings
                ForEach(0..<self.eventFormData.properties.count, id: \.self) { index in
                    HStack {
                        TextField("", text: self.$eventFormData.properties[index].key)
                        TextField("", text: self.$eventFormData.properties[index].value)
                    }
                }
            }

        }.navigationBarItems(trailing:
            Button(action: {
                self.addEventAction()
            }) {
                Text("Add Event")
        })
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Completed"), dismissButton: .default(Text("OK")))
        }
    }

    /// Button methods

    func addProperty() {
        let trimmedPropertyKey = self.eventFormData.pendingPropertyKey.trimmingCharacters(in: .whitespaces)
        let trimmedPropertyValue = self.eventFormData.pendingPropertyValue.trimmingCharacters(in: .whitespaces)

        if trimmedPropertyKey != "" && trimmedPropertyValue != "" {
            self.eventFormData.properties.append(EventFormData.Property(trimmedPropertyKey, trimmedPropertyValue))
            self.eventFormData.pendingPropertyKey = ""
            self.eventFormData.pendingPropertyValue = ""
        }
    }

    func addEventAction() {
        let emailAddress = self.eventFormData.emailAddress
        let eventName = self.eventFormData.eventName
        let properties: [String: String]? = self.eventFormData.properties.isEmpty ? nil : Dictionary(uniqueKeysWithValues: self.eventFormData.properties.map{ ($0.key, $0.value) })
        
        do {
            let event = try Event(emailAddress: emailAddress, name: eventName, properties: properties)
            
            Mailchimp.trackEventWithAttributes(event: event) { result in
                switch result {
                case .success:
                    print("Successfully added event to \(emailAddress)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }

                self.showingAlert = true
            }
        } catch Event.InitError.invalid(let error) {
            print("Could not create Event: \(error)")
        } catch (let error) {
            print("Unknown error: \(error.localizedDescription)")
        }
    }
}
