import XCTest
@testable import SecuredStorage

final class AccessibilityTests: XCTestCase {
    private let storageName = "stubServiceName"
    private let accessGroup = "stubAccessGroup"
    private let key = kSecAttrAccessible as String

    let spy: MockDataProvider = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testWhenUnlocked() {
        _ = storage.searchAllValues(accessibility: .whenUnlocked(shouldBeMigrated: false))

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], kSecAttrAccessibleWhenUnlockedThisDeviceOnly)
    }

    func testWhenUnlockedWithMigration() {
        _ = storage.searchAllValues(accessibility: .whenUnlocked(shouldBeMigrated: true))

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], kSecAttrAccessibleWhenUnlocked)
    }

    func testAfterFirstUnlock() {
        _ = storage.searchAllValues(accessibility: .afterFirstUnlock(shouldBeMigrated: false))

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly)
    }

    func testAfterFirstUnlockWithMigration() {
        _ = storage.searchAllValues(accessibility: .afterFirstUnlock(shouldBeMigrated: true))

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], kSecAttrAccessibleAfterFirstUnlock)
    }

    func testWhenPasscodeSet() {
        _ = storage.searchAllValues(accessibility: .whenPasscodeSet)

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly)
    }
}

class MockDataProvider: SecuredDataProvider {
    var query: CFDictionary?

    func addItem(query: CFDictionary) -> OSStatus {
        logic(query: query)
    }

    func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus {
        logic(query: query)
    }

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        logic(query: query)
    }

    func deleteItem(query: CFDictionary) -> OSStatus {
        logic(query: query)
    }

    private func logic(query: CFDictionary) -> OSStatus {
        self.query = query

        return errSecSuccess
    }
}
