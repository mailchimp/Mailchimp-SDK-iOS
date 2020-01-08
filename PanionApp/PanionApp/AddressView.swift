//
//  AddressView.swift
//  PanionApp
//
//  Created by Chez Browne on 7/9/19.
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

class AddressFormData : ObservableObject {
    @Published var addressLineOne: String = ""
    @Published var addressLineTwo: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    @Published var country: CountryCode = CountryCode.USA
}

extension AddressFormData {
    convenience init?(_ address: Address?) {
        guard let address = address else { return nil }
        
        self.init()
        self.addressLineOne = address.addressLineOne
        self.addressLineTwo = address.addressLineTwo ?? ""
        self.city = address.city
        self.state = address.state ?? ""
        self.zipCode = address.zipCode
        self.country = address.country
    }
}

struct AddressView: View {
    @ObservedObject var contactFormData: ContactFormData
    @ObservedObject var addressFormData: AddressFormData
    @State private var selectedCountry = CountryCode.USA.rawValue
    @Environment(\.presentationMode) var presentationMode
    
    init(contactFormData: ContactFormData) {
        self.contactFormData = contactFormData
        self.addressFormData = AddressFormData(contactFormData.address) ?? AddressFormData()
    }
    
    var id = UUID()
    var countryNames = CountryCode.allCases.map { $0.rawValue }
    var body: some View {
        Form {
            DetailRow(labelText: "Line One:", detailText: "Enter your address", data: $addressFormData.addressLineOne)
            DetailRow(labelText: "Line Two:", detailText: "Enter apartment number (optional)", data: $addressFormData.addressLineTwo)
            DetailRow(labelText: "City:", detailText: "Enter your city", data: $addressFormData.city)
            DetailRow(labelText: "State:", detailText: "Enter your state / province / region", data: $addressFormData.state)
            Picker(selection: $selectedCountry, label: Text("Country")) {
                ForEach(self.countryNames, id: \.self) { name in
                    Text(name)
                }
            }
            DetailRow(labelText: "Zip:", detailText: "Enter your zip / postal code", data: $addressFormData.zipCode)
            Button(action: {
                self.addAddress()
            }) {
                Text("Add Address")
            }
        }
    }
    
    func addAddress() {
        if self.addressFormData.addressLineOne != "" {
            let address = Address(
                addressLineOne: self.addressFormData.addressLineOne,
                addressLineTwo: self.addressFormData.addressLineTwo,
                city: self.addressFormData.city,
                state: self.addressFormData.state,
                zipCode: self.addressFormData.zipCode,
                country: self.addressFormData.country)
            self.contactFormData.address = address
        }
        self.presentationMode.wrappedValue.dismiss()
    }
}
