import XCTest
@testable import SecuredStorage

final class UpdateValueTests: XCTestCase {
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
        kSecAttrAccount as String: "stubKey"
    ] as CFDictionary
    private let outputAttributesToUpdate = [
        kSecValueData as String: "stubValue".data(using: .utf8)!
    ] as CFDictionary

    let spy: SpyForUpdateItem = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testUpdateValueSuccessfully() {
        spy.result = errSecSuccess
        let result = storage.updateValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(spy.attributesToUpdate, outputAttributesToUpdate)
        XCTAssertEqual(result, .success)
    }

    func testUpdateValueFailed() {
        spy.result = errSecMemoryError
        let result = storage.updateValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(spy.attributesToUpdate, outputAttributesToUpdate)
        XCTAssertEqual(result, .failure(errSecMemoryError))
    }

    override func tearDown() {
        spy.tearDown()
    }
}

class SpyForUpdateItem: SecuredDataProvider {
    var entranceCount = 0
    var entranceToOtherMethods = 0
    var query: CFDictionary?
    var attributesToUpdate: CFDictionary?
    var result: OSStatus?

    func tearDown() {
        entranceCount = .zero
        entranceToOtherMethods = .zero
        query = nil
        result = nil
    }

    func addItem(query: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }

    func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus {
        otherMethodsLogic()
    }

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        entranceCount += 1
        self.query = query
        self.attributesToUpdate = attributesToUpdate

        return result!
    }

    func deleteItem(query: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }

    private func otherMethodsLogic() -> OSStatus {
        entranceToOtherMethods += 1
        return errSecSuccess
    }
}
