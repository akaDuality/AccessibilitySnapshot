//
//  AccessibilitySnapshotDescription.swift
//  
//
//  Created by Mikhail Rubanov on 23.04.2022.
//

import Foundation
import XCTest

@testable import AccessibilitySnapshotCore

private let rect = CGRect(origin: .zero, size: CGSize(width: 300, height: 100))

class DescriptionTests: XCTestCase {
    
    func test_customAction() {
        let parent = UIView(frame: rect)
        
        let view = UIView(frame: rect)
        view.isAccessibilityElement = true
        
        view.accessibilityLabel = "Pizza"
        view.accessibilityValue = "Pepperoni"
        view.accessibilityTraits = .header
        
        if #available(iOS 13.0, *) {
            view.accessibilityCustomActions = [
                UIAccessibilityCustomAction(name: "Add to favorites", actionHandler: { _ in return true }),
                UIAccessibilityCustomAction(name: "Share to friend", actionHandler: { _ in return true })
            ]
        }
        
        let button = UIButton(frame: rect)
        button.isAccessibilityElement = true
        button.accessibilityLabel = "Purchase"
        button.accessibilityTraits = .button
        
        parent.addSubview(view)
        parent.addSubview(button)
        
        let sut = AccessibilitySnapshotDescription(containedView: parent)
        let result = sut.parseAccessibility()
        
        XCTAssertEqual(result, """
Pizza: Pepperoni. Heading.
↓ Actions Available
- Add to favorites
- Share to friend

Purchase. Button.
""")
    }
}

// """
// Close. Button.
//
// Cart. Button
//
// Description:
// | Pepperoni. Heading.
// |
// | Contains: ...
// |
// | Size: medium, 2 of 3. Adjustable.
// |
// | Dough: traditional, 1 of 2. Button.
// |____
//
// Add to product:
// | Cheese: 20 rubles, 1 of 7. Button.
// | Cucumber: 30 rubles, 2 of 7. Button.
// | ...
// |____
//
// Add to cart for 839 rubles. Button.
// """

