//
//  SecuredDataProvider.swift
//  SecuredStorage
//
//  Created by Odinokov G. A. on 19.08.2024.
//

import Foundation

public protocol SecuredDataProvider {
    func addItem(query: CFDictionary) -> OSStatus

    func copyItemMatching(query: CFDictionary, result: inout CFTypeRef?) -> OSStatus

    func updateItem(query: CFDictionary, attributesToUpdate: CFDictionary) -> OSStatus

    func deleteItem(query: CFDictionary) -> OSStatus
}
