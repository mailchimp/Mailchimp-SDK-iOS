//
//  CreateView.swift
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

struct CreateView: View {
    enum Create {
        case contact
        case event
    }
    
    @State var show: Create = .contact
    
    var content: some View {
        if show == .contact {
            return AnyView(ContactView())
        } else {
            return AnyView(EventView())
        }
    }
    
    var body: some View {
        VStack {
            Picker(selection: $show, label: Text("What do you want to test?")) {
                Text("Contacts").tag(Create.contact)
                Text("Events").tag(Create.event)
            }.pickerStyle(SegmentedPickerStyle())
            content
        }
    }
}
