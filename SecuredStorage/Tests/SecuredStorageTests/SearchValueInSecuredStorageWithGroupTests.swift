import XCTest
@testable import SecuredStorage

final class SearchValueInSecuredStorageWithGroupTests: XCTestCase {
    private let storageName = "stubServiceName"
    private let accessGroup = "stubAccessGroup"
    private let key = "stubKey"
    private let value = "stubValue".data(using: .utf8)!
    private let out = "stubOut".data(using: .utf8)!
    private let accessibility = SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false)
    private let outputQuery = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccessible as String: SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false).queryValue,
        kSecAttrService as String: "stubServiceName",
        kSecAttrAccessGroup as String: "stubAccessGroup",
        kSecAttrAccount as String: "stubKey",
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true
    ] as CFDictionary

    let spy: SpyForSearchValue = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testSearchValueSuccessfully() {
        spy.result = errSecSuccess
        spy.out = NSData(data: out)
        let result = storage.searchValue(key: key, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .success(out))
    }

    func testSearchValueNotFound() {
        spy.result = errSecItemNotFound
        let result = storage.searchValue(key: key, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .notFound)
    }

    func testSearchValueFailed() {
        spy.result = errSecMemoryError
        let result = storage.searchValue(key: key, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.query, outputQuery)
        XCTAssertEqual(result, .failure(errSecMemoryError))
    }

    func testOtherMethodsNotToEnterInCopyItemMatching() {
        spy.result = errSecSuccess
        _ = storage.addValue(key: key, value: value, accessibility: accessibility)
        _ = storage.removeValue(key: key, accessibility: accessibility)
        _ = storage.searchAllValues(accessibility: accessibility)
        _ = storage.updateValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.entranceCount, 1)
    }

    override func tearDown() {
        spy.tearDown()
    }
}

class SpyForSearchValue: SecuredDataProvider {
    var entranceCount = 0
    var entranceToOtherMethods = 0
    var query: CFDictionary?
    var result: OSStatus?
    var out: CFTypeRef?

    func tearDown() {
        entranceCount = .zero
        entranceToOtherMethods = .zero
        query = nil
        result = nil
        out = nil
    }

    func addItem(query: CFDictionary) -> OSStatus {
        otherMethodsLogic()
    }

    func copyItemMatching(query: CFDictionary, result out: inout CFTypeRef?) -> OSStatus {
        entranceCount += 1
        self.query = query
        out = self.out

        return result!
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
