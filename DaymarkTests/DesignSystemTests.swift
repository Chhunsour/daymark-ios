import XCTest
import SwiftUI
@testable import Daymark

final class DesignSystemTests: XCTestCase {
    func testColorTokensAreDefined() {
        XCTAssertNotNil(Color.dmBackground)
        XCTAssertNotNil(Color.dmCard)
        XCTAssertNotNil(Color.dmTextPrimary)
        XCTAssertNotNil(Color.dmTextSecondary)
        XCTAssertNotNil(Color.dmBorder)
        XCTAssertNotNil(Color.dmAccent)
    }

    func testSpacingTokensValues() {
        XCTAssertEqual(DMSpacing.xs, 4)
        XCTAssertEqual(DMSpacing.sm, 8)
        XCTAssertEqual(DMSpacing.md, 16)
        XCTAssertEqual(DMSpacing.lg, 24)
        XCTAssertEqual(DMSpacing.xl, 32)
    }
}
