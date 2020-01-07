//
//  EventRequest.swift
//  MailchimpSDK
//
//  Created by Jennifer Starratt on 10/30/19.
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

struct EventRequest: APIRequest {
    let event: Event
    
    var params: [URLQueryItem]?
    
    var apiPath: String { return "clientapi/1.0/contacts/events" }
    
    /// Callback once API request is complete.
    public var callback: MailchimpSDK.RequestCallback?
    
    
    init(event: Event, _ callback: MailchimpSDK.RequestCallback? = nil) {
        self.event = event
        self.callback = callback
    }
    
    func postBody() -> PostBody<Event, ParametersDefault>? {
        return .object(event)
    }
    
    func headers() -> [String : String]? {
        return ["Mailchimp-SDK-Version": MailchimpSDK.version, "Mailchimp-SDK-Platform": "iOS"]
    }
    
    func httpVerb() -> HTTPVerb {
        return .post
    }
    
    func requestComplete(_ result: Result<Data, APIError>) {
        switch result {
        case .success(let data):
            callback?(.success(data))
        case .failure(let error):
            if case .apiError(let apiError) = error {
                callback?(.failure(.apiError(response: apiError)))
            } else {
                callback?(.failure(error))
            }
        }
    }
}
