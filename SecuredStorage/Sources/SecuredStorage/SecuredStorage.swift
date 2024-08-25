//
//  SecuredStorage.swift
//  SecuredStorage
//
//  Created by Odinokov G. A. on 19.08.2024.
//  Copyright © 2024 BCS-Broker. All rights reserved.
//

import Foundation

/// Secured storage to store persistence in secure way.
/// Based on Keychain
public struct SecuredStorage {
    // MARK: - Public properties

    public let name: String
    public let accessGroup: String?

    // MARK: - Private properties

    private let dataProvider: SecuredDataProvider

    // MARK: - Init

    /// Service provide easy way to persist secure data
    /// - Parameters:
    ///   - serviceName: name of service, which used for managing data
    ///   - accessGroup: if you want to share data between your app and extension, or your two apps - you can use accessGroup& Otherwise you can skip it.
    public init(
        name: String,
        accessGroup: String? = nil,
        dataProvider: SecuredDataProvider = DefaultSecuredDataProvider()
    ) {
        self.name = name
        self.accessGroup = accessGroup
        self.dataProvider = dataProvider
    }

    // MARK: - Public methods

    // MARK: Add / Update / Save

    public func addValue(
        key: String,
        value: Data,
        accessibility: Accessibility
    ) -> AddingResult {
        var requestQuery = makeDefaultQueryParams(accessibility: accessibility)
        requestQuery[kSecAttrAccount] = key
        requestQuery[kSecValueData] = value

        let requestStatus = dataProvider.addItem(query: getDictionary(from: requestQuery))

        switch requestStatus {
        case errSecDuplicateItem:
            return .tryToDuplicate
        case errSecSuccess:
            return .success
        default:
            return .failure(requestStatus)
        }
    }

    func updateValue(
        key: String,
        value: Data,
        accessibility: Accessibility
    ) -> UpdateResult {
        var requestQuery = makeDefaultQueryParams(accessibility: accessibility)
        requestQuery[kSecAttrAccount] = key

        let attributesToUpdate: [CFString: Any?] = [kSecValueData: value]

        let status = dataProvider.updateItem(
            query: getDictionary(from: requestQuery),
            attributesToUpdate: getDictionary(from: attributesToUpdate)
        )

        switch status {
        case errSecSuccess:
            return .success
        default:
            return .failure(status)
        }
    }

    func saveValue(
        key: String,
        value: Data,
        accessibility: Accessibility
    ) -> UpdateResult {
        let addResult = addValue(key: key, value: value, accessibility: accessibility)

        switch addResult {
        case .success:
            return .success
        case .tryToDuplicate:
            return updateValue(key: key, value: value, accessibility: accessibility)
        case .failure(let status):
            return .failure(status)
        }
    }

    // MARK: Get

    func searchValue(
        key: String,
        accessibility: Accessibility
    ) -> SearchResult<Data?> {
        var requestQuery = makeDefaultQueryParams(accessibility: accessibility)
        requestQuery[kSecAttrAccount] = key
        requestQuery[kSecMatchLimit] = kSecMatchLimitOne
        requestQuery[kSecReturnData] = true

        var item: CFTypeRef?
        let requestStatus = dataProvider.copyItemMatching(query: getDictionary(from: requestQuery), result: &item)

        switch requestStatus {
        case errSecItemNotFound:
            return .notFound
        case errSecSuccess:
            return .success(item as? Data)
        default:
            return .failure(requestStatus)
        }
    }

    func searchAllValues(
        accessibility: Accessibility
    ) -> SearchResult<[String: Data]?> {
        var requestQuery = makeDefaultQueryParams(accessibility: accessibility)
        requestQuery[kSecMatchLimit] = kSecMatchLimitAll
        requestQuery[kSecReturnAttributes] = true
        requestQuery[kSecReturnData] = true

        var item: CFTypeRef?
        let requestStatus = dataProvider.copyItemMatching(query: getDictionary(from: requestQuery), result: &item)

        switch requestStatus {
        case errSecItemNotFound:
            return .notFound
        case errSecSuccess:
            let dictionary = item as? [[String: Any]]
            let result = dictionary?.reduce(into: [String: Data]()) {
                guard let key = $1[kSecAttrAccount as String] as? String,
                      let value = $1[kSecValueData as String] as? Data
                else { return }

                $0[key] = value
            }
            return .success(result)
        default:
            return .failure(requestStatus)
        }
    }

    // MARK: Remove

    func removeValue(
        key: String,
        accessibility: Accessibility
    ) -> UpdateResult {
        var requestQuery = makeDefaultQueryParams(accessibility: accessibility)
        requestQuery[kSecAttrAccount] = key

        let status = dataProvider.deleteItem(query: getDictionary(from: requestQuery))

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return .success
        default:
            return .failure(status)
        }
    }

    // MARK: - Private methods

    private func makeDefaultQueryParams(accessibility: Accessibility) -> [CFString: Any?] {
        [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccessible: accessibility.queryValue,
            kSecAttrService: name,
            kSecAttrAccessGroup: accessGroup
        ]
    }

    private func getDictionary(from dictionary: [CFString: Any?]) -> CFDictionary {
        let stringDictionary = dictionary.reduce(into: [String: Any]()) {
            guard $1.value != nil else { return }

            $0[$1.key as String] = $1.value
        }

        return stringDictionary as CFDictionary
    }
}
