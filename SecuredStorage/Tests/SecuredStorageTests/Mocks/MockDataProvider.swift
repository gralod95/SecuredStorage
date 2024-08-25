import XCTest
@testable import SecuredStorage

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
