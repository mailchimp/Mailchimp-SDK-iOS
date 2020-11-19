// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "MailchimpSDK",
    products: [
        .library(
            name: "MailchimpSDK",
            targets: ["MailchimpSDK"]),
    ],
    targets: [
        .target(
            name: "MailchimpSDK",
            exclude: ["MailchimpSDK/Info.plist"]),
        .testTarget(
            name: "MailchimpSDKTests",
            dependencies: ["MailchimpSDK"],
            exclude: ["../../Tests/MailchimpSDKTests/Info.plist"]),
    ]
)
