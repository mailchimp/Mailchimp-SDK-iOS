//
//  ContactOperation.swift
//  MailchimpSDK
//
//  Created by Michael Patzer on 11/4/19.
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

public class ContactOperation: Operation {
    let contact: Contact
    var request: ContactRequest?
    let result: MailchimpSDK.RequestCallback?
    public var dataTask: URLSessionDataTask?

    init(_ contact: Contact, result: MailchimpSDK.RequestCallback? = nil) {
        self.contact = contact
        self.result = result
    }

    public override var isAsynchronous: Bool { return false }
    public override var isExecuting: Bool { return state == .executing }
    public override var isFinished: Bool { return state == .finished }

    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }

    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }

    public override func start() {
        if isCancelled {
            state = .finished
        } else {
            state = .ready
            main()
        }
    }

    public override func main() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .executing

            request = ContactRequest(contact: contact) { requestResult in
                self.result?(requestResult)

                if MailchimpSDK.debugMode {
                    switch requestResult {
                    case .success:
                        print("Contact request succeeded.")
                    case .failure(let error):
                        print("Contact request failed with error: \(error.localizedDescription)")
                        if case .apiError(let response) = error {
                            print("API Error status: \(response.status)")
                            print("API Error detail: \(response.detail)")
                            print("API Error type: \(response.type)")
                        }
                    }
                }

                self.state = .finished
            }

            self.dataTask = MailchimpSDK.api?.process(request: request!)
        }
    }
}
