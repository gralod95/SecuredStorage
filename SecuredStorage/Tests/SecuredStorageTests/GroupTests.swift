import XCTest
@testable import SecuredStorage

final class GroupTests: XCTestCase {
    private let storageName = "stubServiceName"
    private let accessGroup = "stubAccessGroup"
    private let key = kSecAttrAccessGroup as String

    let spy: MockDataProvider = .init()

    lazy var storageWithGroup = SecuredStorage(
        name: storageName,
        accessGroup: accessGroup,
        dataProvider: spy
    )

    lazy var storageWithoutGroup = SecuredStorage(
        name: storageName,
        dataProvider: spy
    )

    func testWithGroup() {
        _ = storageWithGroup.searchAllValues(accessibility: .whenUnlocked(shouldBeMigrated: false))

        XCTAssertNotNil(spy.query)
        XCTAssertEqual(Dictionary(_immutableCocoaDictionary: spy.query!)[key], accessGroup)
    }

    func testWithoutGroup() {
        _ = storageWithoutGroup.searchAllValues(accessibility: .whenUnlocked(shouldBeMigrated: false))

        XCTAssertNotNil(spy.query)
        XCTAssertNil(Dictionary(_immutableCocoaDictionary: spy.query!)[key])
    }
}
