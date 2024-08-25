import XCTest
@testable import SecuredStorage

final class SaveValueTests: XCTestCase {
    private let storageName = "stubServiceName"
    private let accessGroup = "stubAccessGroup"
    private let key = "stubKey"
    private let value = "stubValue".data(using: .utf8)!
    private let accessibility = SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false)

    private let addValueOutputQuery = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccessible as String: SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false).queryValue,
        kSecAttrService as String: "stubServiceName",
        kSecAttrAccessGroup as String: "stubAccessGroup",
        kSecAttrAccount as String: "stubKey",
        kSecValueData as String: "stubValue".data(using: .utf8)!
    ] as CFDictionary

    private let updateValueOutputQuery = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccessible as String: SecuredStorage.Accessibility.afterFirstUnlock(shouldBeMigrated: false).queryValue,
        kSecAttrService as String: "stubServiceName",
        kSecAttrAccessGroup as String: "stubAccessGroup",
        kSecAttrAccount as String: "stubKey"
    ] as CFDictionary

    private let updateItemAttributesToUpdate = [
        kSecValueData as String: "stubValue".data(using: .utf8)!
    ] as CFDictionary

    let spy: SpyForSaving = .init()

    lazy var storage = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    func testAddValueSuccessfully() {
        spy.addItemResult = errSecSuccess
        let result = storage.saveValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.addItemEntranceCount, 1)
        XCTAssertEqual(spy.updateItemEntranceCount, 0)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.addItemQuery, addValueOutputQuery)
        XCTAssertEqual(result, .success)
    }

    func testAddValueFailedWithCustomError() {
        spy.addItemResult = errSecNotAvailable
        let result = storage.saveValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.addItemEntranceCount, 1)
        XCTAssertEqual(spy.updateItemEntranceCount, 0)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.addItemQuery, addValueOutputQuery)
        XCTAssertEqual(result, .failure(errSecNotAvailable))
    }

    func testUpdateValueSuccessfully() {
        spy.addItemResult = errSecDuplicateItem
        spy.updateItemResult = errSecSuccess
        let result = storage.saveValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.addItemEntranceCount, 1)
        XCTAssertEqual(spy.updateItemEntranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.addItemQuery, addValueOutputQuery)
        XCTAssertEqual(spy.updateItemQuery, updateValueOutputQuery)
        XCTAssertEqual(spy.updateItemAttributesToUpdate, updateItemAttributesToUpdate)
        XCTAssertEqual(result, .success)
    }

    func testUpdateValueFailedWithCustomError() {
        spy.addItemResult = errSecDuplicateItem
        spy.updateItemResult = errSecNotAvailable
        let result = storage.saveValue(key: key, value: value, accessibility: accessibility)

        XCTAssertEqual(spy.addItemEntranceCount, 1)
        XCTAssertEqual(spy.updateItemEntranceCount, 1)
        XCTAssertEqual(spy.entranceToOtherMethods, 0)
        XCTAssertEqual(spy.addItemQuery, addValueOutputQuery)
        XCTAssertEqual(spy.updateItemQuery, updateValueOutputQuery)
        XCTAssertEqual(spy.updateItemAttributesToUpdate, updateItemAttributesToUpdate)
        XCTAssertEqual(result, .failure(errSecNotAvailable))
    }

    override func tearDown() {
        spy.tearDown()
    }
}

class SpyForSaving: SecuredDataProvider {
    var addItemEntranceCount = 0
    var updateItemEntranceCount = 0
    var entranceToOtherMethods = 0
    var addItemQuery: CFDictionary?
    var updateItemQuery: CFDictionary?
    var updateItemAttributesToUpdate: CFDictionary?
    var addItemResult: OSStatus?
    var updateItemResult: OSStatus?

    func tearDown() {
        addItemEntranceCount = .zero
        updateItemEntranceCount = .zero
        entranceToOtherMethods = .zero
        addItemQuery = nil
        updateItemQuery = nil
        updateItemAttributesToUpdate = nil
        addItemResult = nil
        updateItemResult = nil
    }

    func addItem(query: CFDictionary) -> OSStatus {
        addItemEntranceCount += 1
        addItemQuery = query

        return addItemResult!
    }

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        updateItemEntranceCount += 1
        updateItemQuery = query
        updateItemAttributesToUpdate = attributesToUpdate

        return updateItemResult!
    }

    func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus {
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
