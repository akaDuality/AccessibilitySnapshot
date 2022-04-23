//
//  File.swift
//  
//
//  Created by Mikhail Rubanov on 23.04.2022.
//

import Foundation
import XCTest

@testable import AccessibilitySnapshotCore

private let rect = CGRect(origin: .zero, size: CGSize(width: 300, height: 100))

class DescriptionTests: XCTestCase {
    
    var view: UIView!

    override func setUp() {
        super.setUp()
        
        view = UIView(frame: rect)
        view.isAccessibilityElement = true
    }
    
    func test_customAction() {
        view.accessibilityLabel = "Pizza"
        view.accessibilityValue = "Pepperoni"
        view.accessibilityTraits = .button
        
        if #available(iOS 13.0, *) {
            view.accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Add to favorites", actionHandler: { _ in return true }),
                UIAccessibilityCustomAction(name: "Share to friend", actionHandler: { _ in return true })
            ]
        }
        
        let sut = AccessibilitySnapshotDescription(containedView: view)
        let result = sut.parseAccessibility()
        
        XCTAssertEqual(result, """
Pizza: Pepperoni. Button.

↓ Actions Available
- Add to favorites
- Share to friend
""")
    }
}

class AccessibilityMarkerTextDescription: XCTestCase {
    func test() {
        let marker = AccessibilityMarker(
            description: "Pizza: Pepperoni. Button.",
            hint: "Tap twice to purchase",
            shape: .frame(rect),
            activationPoint: .zero,
            usesDefaultActivationPoint: true,
            customActions: ["Add to favorites",
                           "Share to friend"])
        
        XCTAssertEqual(marker.textDescription, """
Pizza: Pepperoni. Button.
Tap twice to purchase

↓ Actions Available
- Add to favorites
- Share to friend
""")
    }
}
