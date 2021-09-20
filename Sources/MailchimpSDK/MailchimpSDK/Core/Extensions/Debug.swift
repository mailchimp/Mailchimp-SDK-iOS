//
//
//  Debug.swift
//  MailchimpSDK
//
//  Created by Jennifer Starratt on 9/20/21.
//  Copyright 2021 The Rocket Science Group LLC
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

/// A debug version of print. `print()` will only be called if debug mode is enabled.
///
/// - Parameters:
///     - items: Zero or more items to print.
///     - separator: A string to print between each item. The default is a single space (" ").
///     - terminator: The string to print after all items have been printed. The default is a newline ("\n").
func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if Mailchimp.debugMode {
        print(items, separator: separator, terminator: terminator)
    }
}
