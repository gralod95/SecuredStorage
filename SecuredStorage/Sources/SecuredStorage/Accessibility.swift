//
//  Accessibility.swift
//  SecuredStorage
//
//  Created by Odinokov G. A. on 19.08.2024.
//  Copyright © 2024 BCS-Broker. All rights reserved.
//

import Foundation

extension SecuredStorage {
    /// Accessibility of item.
    /// When asking `searchValue`/ `searchAllValues` / `updateValue` / `removeValue`,
    /// the error errSecInteractionNotAllowed will be returned if the item's data is not available according to settled accessibility.
    public enum Accessibility {
        /// Item data can only be accessed while the device is unlocked.
        /// This is recommended for items that only need be accesible while the application is in the foreground.
        /// - shouldBeMigrated - If true item will migrate to a new device when using encrypted backups.
        case whenUnlocked(shouldBeMigrated: Bool)
        /// Item data can only be accessed once the device has been unlocked after a restart.
        /// This is recommended for items that need to be accesible by background applications.
        /// - shouldBeMigrated - If true item will migrate to a new device when using encrypted backups.
        case afterFirstUnlock(shouldBeMigrated: Bool)
        ///  Item data can only be accessed while the device is unlocked.
        ///  This is recommended for items that only need to be accessible
        ///  while the application is in the foreground and requires a passcode to be set on the device.
        ///  Items with this attribute will never migrate to a new device, so after a backup is restored to a new device, these items will be missing.
        ///  This attribute will not be available on devices without a passcode.
        ///  Disabling the device passcode will cause all previously protected items to be deleted.
        case whenPasscodeSet

        /// Translating to Keychain constants
        var queryValue: CFString {
            switch self {
            case .whenUnlocked(let shouldBeMigrated):
                switch shouldBeMigrated {
                case true:
                    return kSecAttrAccessibleWhenUnlocked
                case false:
                    return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
                }
            case .afterFirstUnlock(let shouldBeMigrated):
                switch shouldBeMigrated {
                case true:
                    return kSecAttrAccessibleAfterFirstUnlock
                case false:
                    return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                }
            case .whenPasscodeSet:
                return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            }
        }
    }
}
