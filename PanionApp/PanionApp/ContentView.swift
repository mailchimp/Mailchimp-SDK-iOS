//
//  ContentView.swift
//  Panion App
//
//  Created by Chez Browne on 6/14/19.
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

struct ContentView : View {
    @State var apiKey: String = ""
    @State var autoTag: Bool = true
    @State var debugMode: Bool = true
    @State var showingTokenAlert: Bool = false
    @State var showCreateView: Bool? = nil

    var body: some View {
        NavigationView {
            Form {
                Group {
                    VStack(alignment: .leading) {
                        Text("SDK Key")
                            .bold()
                        TextField("Enter key", text: $apiKey)
                            .multilineTextAlignment(.leading)
                        Divider()
                        Toggle(isOn: $autoTag) {
                            Text("Autotag Contacts")
                        }
                        Toggle(isOn: $debugMode) {
                            Text("Debug Mode")
                        }
                    }
                }
                Group {
                    VStack(alignment: .leading) {
                        NavigationLink(destination: CreateView(), tag: true, selection: $showCreateView) {
                            EmptyView()
                        }
                        Button("Start") {
                            do {
                                try MailchimpSDK.initialize(token: self.apiKey,
                                                        autoTagContacts: self.autoTag,
                                                        debugMode: self.debugMode)
                                self.showCreateView = true
                            } catch MailchimpSDK.InitError.invalidToken {
                                self.showingTokenAlert = true
                                self.showCreateView = false
                            } catch {
                                print("Unexpected error: \(error)")
                                self.showCreateView = false
                            }
                        }
                    }
                }
                .alert(isPresented: $showingTokenAlert) {
                    if apiKey.isEmpty {
                        return Alert(title: Text("Token Required"), message: Text("A token is required to initialize MailchimpSDK"), dismissButton: .cancel(Text("OK")))
                    } else {
                        return Alert(title: Text("Invalid Token"), message: Text("Unable to initialize MailchimpSDK with token: \(apiKey)"), dismissButton: .cancel(Text("OK")))
                    }
                }
            }
            .navigationBarTitle(Text("Panion"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
