//
//  APIRequest.swift
//  Anzee
//
//  Created by Shawn Veader on 4/2/19.
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

/// Protocol that defines the properties that are needed in order to
///     make a Mailchimp API request
protocol APIRequest {
    associatedtype T: Codable
    associatedtype U: PostBodyParamable
    
    /// An array of query params that will be used to make a GET request.
    var params: [URLQueryItem]? { get }
    
    /// Path within API for the request.
    var apiPath: String { get }
    
    /// A dictionary containing all the HTTP header fields of the
    /// receiver.
    func headers() -> [String : String]?
    
    /// Does this request require the default basic auth header?
    /// - Note: Default implementation returns true
    func requiresAuth() -> Bool
    
    /// Which HTTP verb should be used for the request?
    /// - Note: Default implementation returns HTTPVerb.get
    func httpVerb() -> HTTPVerb
    
    /// URL used to make request to API.
    /// - Note: Default implementation considers proper base URL, default params,
    ///         request specific params, etc.
    func url(datacenter: String?) -> URL?
    
    /// Callback used by request runner to indicate data (or error) has been returned.
    func requestComplete(_: Result<Data, APIError>)
    
    /// This data is serialized and sent as the message body of a POST request.
    func postBody() -> PostBody<T, U>?
}


// MARK: - Default Method Implementations
extension APIRequest {
    func headers() -> [String : String]? {
        return nil
    }
    
    func requiresAuth() -> Bool {
        return true
    }
    
    func httpVerb() -> HTTPVerb {
        return .get
    }
    
    func url(datacenter: String?) -> URL? {
        guard
            let baseURL = baseURL(datacenter: datacenter),
            let url = URL(string: "\(apiPath)", relativeTo: baseURL),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else { return nil }
        
        var updatedComponents = components
        
        let queryItems = fullQueryParams()
        updatedComponents.queryItems = queryItems

        return updatedComponents.url
    }
    
    func postBody() -> PostBody<CodableDefault, ParametersDefault>? {
        return nil
    }
    
    /// Return all query params required to perform this API requst.
    ///
    /// Includes default params and request specific GET parameters.
    ///
    /// - Returns: `[NSURLQueryItem]` array of query params
    fileprivate func fullQueryParams() -> [URLQueryItem] {
        // add values here for default query params for all requests
        var queryItems: [URLQueryItem] = [
            //            URLQueryItem(name: "abc", value: "xyz"),
            //            URLQueryItem(name: "version", value: "foo"),
        ]
        
        // add any request specific GET params
        if case .get = httpVerb(), let params = params {
            queryItems.append(contentsOf: params)
        }
        
        return queryItems
    }
    
    /// Create the base URL based on the datacenter component of the API token.
    ///
    /// - Returns: `URL?` for accessing API with datacenter set
    fileprivate func baseURL(datacenter: String?) -> URL? {
        guard let datacenter = datacenter else { return nil }
        return URL(string: "https://\(datacenter).\(AnzeeConstants.APIHost)/")
    }
    
}
