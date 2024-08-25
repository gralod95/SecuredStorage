import XCTest
@testable import SecuredStorage

final class RemoveValueTests: XCTestCase {
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

    let spy: SpyForRemoveItem = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testRemoveValueSuccessfully() {
        spy.result = errSecSuccess
        let result = storage.removeValue(key: key, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .success)
    }

    func testRemoveValueFailure() {
        spy.result = errSecMemoryError
        let result = storage.removeValue(key: key, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .failure(errSecMemoryError))
    }

    override func tearDown() {
        spy.tearDown()
    }
}

class SpyForRemoveItem: SecuredDataProvider {
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
        otherMethodsLogic()
    }

    func deleteItem(query: CFDictionary) -> OSStatus {
        entranceCount += 1
        self.query = query

        return result!
    }

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }

    func copyItemMatching(query: CFDictionary, result out: inout CFTypeRef?) -> OSStatus {
        otherMethodsLogic()
    }

    private func otherMethodsLogic() -> OSStatus {
        entranceToOtherMethods += 1
        return errSecSuccess
    }
}
