//
//  AccessibilityMarkerTextDescription.swift
//  
//
//  Created by Mikhail Rubanov on 24.04.2022.
//

import XCTest
@testable import AccessibilitySnapshotCore

class AccessibilityMarkerTextDescription: XCTestCase {
    func test_fullDescription() {
        let marker = AccessibilityMarker(
            description: "Pizza: Pepperoni. Button.",
            hint: "Tap twice to purchase",
            shape: .frame(.zero),
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
