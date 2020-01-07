//
//  Result.swift
//  Anzee
//
//  Created by Michael Patzer on 4/30/19.
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

extension Result where Success == Data, Failure == APIError {
    func decoded<T: Decodable>(using decoder: JSONDecoder = .init()) throws -> T {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let data = try get()
        return try decoder.decode(T.self, from: data)
    }
}
