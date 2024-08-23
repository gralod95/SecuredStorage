//
//  RequestResult.swift
//  SecuredStorage
//
//  Created by Odinokov G. A. on 19.08.2024.
//  Copyright © 2024 BCS-Broker. All rights reserved.
//

import Foundation

extension SecuredStorage {
    /// Result of adding item to storage
    public enum AddingResult: Equatable {
        /// Item successfully added
        case success
        /// You try to duplicate existed item, you may use `updateValue()` method instead
        case tryToDuplicate
        /// Use [link](https://www.osstatus.com/search/results?platform=ios) for translating code to normal error
        case failure(OSStatus)
    }

    /// Result of searching item in storage
    enum SearchResult<Element> {
        /// Item successfully found
        case success(Element)
        /// No matches to key and accessibility (be careful with accessibility, it must equal to accessibility in item)
        case notFound
        /// Use [link](https://www.osstatus.com/search/results?platform=ios) for translating code to normal error
        case failure(OSStatus)
    }

    /// Result of updating item in storage
    enum UpdateResult: Equatable {
        /// Item successfully updated
        case success
        /// Use [link](https://www.osstatus.com/search/results?platform=ios) for translating code to normal error
        case failure(OSStatus)
    }
}
