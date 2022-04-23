//
//  Copyright 2020 Square Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SnapshotTesting
import UIKit

#if SWIFT_PACKAGE
import AccessibilitySnapshotCore
import AccessibilitySnapshotCore_ObjC
#endif

extension Snapshotting where Value == UIView, Format == String {

    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
    /// approximation of the description that VoiceOver will read for each element.
    public static var accessibilityDescription: Snapshotting {
        return .accessibilityDescriptionFunc()
    }

    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
    /// approximation of the description that VoiceOver will read for each element.
    public static func accessibilityDescriptionFunc() -> Snapshotting {
        guard isRunningInHostApplication else {
            fatalError("Accessibility snapshot tests cannot be run in a test target without a host application")
        }

        return SimplySnapshotting
            .lines
            .pullback { (view: UIView) in
                let containerView = AccessibilitySnapshotDescription(
                    containedView: view
                )

                let window = UIWindow(frame: UIScreen.main.bounds)
                window.makeKeyAndVisible()
                containerView.center = window.center
                window.addSubview(containerView)


                let voiceOverDescription = containerView.parseAccessibility()


                return voiceOverDescription
            }
    }

    // MARK: - Internal Properties

    internal static var isRunningInHostApplication: Bool {
        // The tests must be run in a host application in order for the accessibility properties to be populated
        // correctly. The `UIApplication.shared` singleton is non-optional, but will be uninitialized when the tests are
        // running outside of a host application, so we can use this check to determine whether we have a test host.
        let hostApplication: UIApplication? = UIApplication.shared
        return (hostApplication != nil)
    }

}

// TODO: Restore
//extension Snapshotting where Value == UIViewController, Format == String {
//
//    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
//    /// approximation of the description that VoiceOver will read for each element.
//    public static var accessibilityDescription: Snapshotting {
//        return .accessibilityDescription()
//    }
//
//    /// Snapshots the current view with colored overlays of each accessibility element it contains, as well as an
//    /// approximation of the description that VoiceOver will read for each element.
//    public static func accessibilityDescription(
//    ) -> Snapshotting {
//        return Snapshotting<UIView, String>
//            .accessibilityDescription()
//            .pullback { viewController in
//                viewController.view
//            }
//    }
//}
