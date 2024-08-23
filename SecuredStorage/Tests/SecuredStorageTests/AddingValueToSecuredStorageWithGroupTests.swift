import XCTest
@testable import SecuredStorage

final class AddingValueToSecuredStorageWithGroupTests: XCTestCase {
    private let storageName = "stubServiceName"
    private let accessGroup = "stubAccessGroup"
    private let key = "stubKey"
    private let value = "stubValue".data(using: .utf8)!
    private let accessibility = SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false)
    private let outputQuery = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccessible as String: SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false).queryValue,
        kSecAttrService as String: "stubServiceName",
        kSecAttrAccessGroup as String: "stubAccessGroup",
        kSecAttrAccount as String: "stubKey",
        kSecValueData as String: "stubValue".data(using: .utf8)!
    ] as CFDictionary

    let spy: SpyForAddItem = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testAddValueSuccessfully() {
        spy.result = errSecSuccess
        let result = storage.addValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .success)
    }

    func testAddValueTryToDuplicate() {
        spy.result = errSecDuplicateItem
        let result = storage.addValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .tryToDuplicate)
    }

    func testAddValueCustomError() {
        spy.result = errSecMemoryError
        let result = storage.addValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .failure(errSecMemoryError))
    }

    func testOtherMethodsNotToEnterInAddItem() {
        _ = storage.removeValue(key: key, accessibility: accessibility)
        _ = storage.searchAllValues(accessibility: accessibility)
        _ = storage.searchValue(key: key, accessibility: accessibility)
        _ = storage.updateValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, .zero)
    }

    override func tearDown() {
        spy.tearDown()
    }
}

class SpyForAddItem: SecuredDataProvider {
    var entranceCount = 0
    var entranceToOtherMethods = 0
    var query: CFDictionary?
    var result: OSStatus?

    func tearDown() {
        entranceCount = .zero
        entranceToOtherMethods = .zero
        query = nil
        result = nil
    }

    func addItem(query: CFDictionary) -> OSStatus {
        entranceCount += 1
        self.query = query

        return result!
    }

    func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus { 
        otherMethodsLogic()
    }

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }
    func deleteItem(query: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }

    private func otherMethodsLogic() -> OSStatus {
        entranceToOtherMethods += 1
        return errSecSuccess
    }
}
