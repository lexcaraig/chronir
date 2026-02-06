// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CycleAlarm",
    platforms: [
        .iOS(.v17),
        // TODO: Update to iOS 26 minimum when Xcode 18 is available
        .macOS(.v14)
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk",
            from: "11.0.0"
        )
    ],
    targets: [
        .executableTarget(
            name: "CycleAlarm",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseStorage", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
            ],
            path: "Sources",
            exclude: [
                "App/Configuration/GoogleService-Info.plist"
            ]
        ),
        .testTarget(
            name: "CycleAlarmTests",
            dependencies: ["CycleAlarm"],
            path: "Tests"
        ),
    ]
)
