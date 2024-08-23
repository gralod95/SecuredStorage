//
//  DefaultSecuredDataProvider.swift
//  SecuredStorage
//
//  Created by Odinokov G. A. on 19.08.2024.
//

import Foundation

public struct DefaultSecuredDataProvider: SecuredDataProvider {
    public init() { }

    public func addItem(query: CFDictionary) -> OSStatus {
        SecItemAdd(query, nil)
    }

    public func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus {
        SecItemCopyMatching(query, &result)
    }

    public func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus {
        SecItemUpdate(query, attributesToUpdate)
    }

    public func deleteItem(query: CFDictionary) -> OSStatus {
        SecItemDelete(query)
    }
}
