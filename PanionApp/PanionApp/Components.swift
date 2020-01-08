//
//  Components.swift
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

struct Header: View {
    var text: String
    var body: some View {
        Text("\(text)")
            .font(.headline)
    }
}

struct FieldRow: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var value: String = ""
}

struct DetailRow: View, Identifiable {
    var id = UUID()
    var labelText: String
    var detailText: String
    var data: Binding<String>
    var body: some View {
        HStack {
            Text("\(labelText)")
                .bold()
            TextField("\(detailText)", text: data)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}
