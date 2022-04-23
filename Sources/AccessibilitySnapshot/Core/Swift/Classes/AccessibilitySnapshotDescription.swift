//
//  Copyright 2019 Square Inc.
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

import CoreImage
import UIKit
import SwiftUI

// MARK: -

/// A container view that displays a snapshot of a view and overlays it with accessibility markers, as well as shows a
/// legend of accessibility descriptions underneath.
///
/// The overlays and legend will be added when `parseAccessibility()` is called. In order for the coordinates to be
/// calculated properly, the view must already be in the view hierarchy.
public final class AccessibilitySnapshotDescription: UIView {

    // MARK: - Public Types

    public enum Error: Swift.Error {

        /// An error indicating that the `containedView` is too large too snapshot using the specified rendering
        /// parameters.
        ///
        /// - Note: This error is thrown due to filters failing. To avoid this error, try rendering the snapshot in
        /// polychrome, reducing the size of the `containedView`, or running on a different iOS version. In particular,
        /// this error is known to occur when rendering a monochrome snapshot on iOS 13.
        case containedViewExceedsMaximumSize(viewSize: CGSize, maximumSize: CGSize)

        /// An error indicating that the `containedView` has a transform that is not support while using the specified
        /// rendering parameters.
        ///
        /// - Note: In particular, this error is known to occur when using a non-identity transform that requires
        /// tiling. To avoid this error, try setting an identity transform on the `containedView` or using the
        /// `.renderLayerInContext` view rendering mode
        case containedViewHasUnsupportedTransform(transform: CATransform3D)

    }

    // MARK: - Life Cycle

    /// Initializes a new snapshot container view.
    ///
    /// - parameter containedView: The view that should be snapshotted, and for which the accessibility markers should
    /// be generated.
    /// - parameter viewRenderingMode: The method to use when snapshotting the `containedView`.
    /// - parameter markerColors: An array of colors to use for the highlighted regions. These colors will be used in
    /// order, repeating through the array as necessary.
    /// - parameter activationPointDisplayMode: Controls when to show indicators for elements' accessibility activation
    /// points.
    public init(
        containedView: UIView
    ) {
        self.containedView = containedView

        super.init(frame: containedView.bounds)

        snapshotView.clipsToBounds = true
        addSubview(snapshotView)

        backgroundColor = .init(white: 0.9, alpha: 1.0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Properties

    private let containedView: UIView

    private let snapshotView: UIImageView = .init()

    private var displayMarkers: [AccessibilityMarker] = []

    // MARK: - Public Methods

    /// Parse the `containedView`'s accessibility and add appropriate visual elements to represent it.
    ///
    /// This must be called _after_ the view is in the view hierarchy.
    public func parseAccessibility() -> String {
        // Clean up any previous markers.

        let viewController = containedView.next as? UIViewController

        viewController?.removeFromParent()
        addSubview(containedView)

        defer {
            containedView.removeFromSuperview()

        }

        // Force a layout pass after the view is in the hierarchy so that the conversion to screen coordinates works
        // correctly.
        containedView.setNeedsLayout()
        containedView.layoutIfNeeded()

        let parser = AccessibilityHierarchyParser()
        let markers = parser.parseAccessibilityElements(in: containedView)
        
        return markers
            .map { marker in marker.textDescription }
            .joined(separator: "\n")
    }

    // MARK: - Public Static Properties


    // MARK: - Private Types

}

extension AccessibilityMarker {
    var textDescription: String {
        var components = [String]()
        components.append(description)
        
        if let hint = hint {
            components.append(hint)
        }
        
        if !customActions.isEmpty {
            components.append("") // Separate by empty line
            components.append(
                customActionDescription()
            )
        }

        return components.joinedAsLines()
    }
    
    private func customActionDescription() -> String {
        let title = "↓ " + Strings.actionsAvailableText(for: accessibilityLanguage)
        
        return [
            title,
            customActions.map { text in "- " + text }.joinedAsLines()
        ].joinedAsLines()
    }
}

extension Array where Element == String {
    func joinedAsLines() -> String {
        joined(separator: "\n")
    }
}
