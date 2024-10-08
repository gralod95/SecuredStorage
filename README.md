# SecuredStorage
SecuredStorage is a service designed for securely storing data in Keychain, with a focus on simplicity and reliability.
One of the main features of this project is its comprehensive test coverage, ensuring stability and minimizing the risk of errors.

# Key advantages

- Lightweight and independent: The service has no unnecessary dependencies, making it easy to integrate into any project and simple to extend if needed.
- Comprehensive test coverage: The service is fully tested, guaranteeing reliable operation and simplifying future development.

# Setup

You can use service as local spm library, or you can copy files directly into your project)

# Usage

## Init

```swift
init(name: "myStorage")
```

- if you want to make shared storage use `accessGroup` parameter

```swift
init(name: "myStorage", accessGroup: "myGroup")
```

## Set data to storage

There are two ways to do it:
- The Keychain approach: adding new value and update existing ones (`addValue`, `updateValue`)
- A more convenient method for developers (in my opinion): save data (`saveValue`)

### Save data in storage

```swift
myStorage.saveValue(key: "dataKey", value: Data(), accessibility: .whenUnlocked(shouldBeMigrated: false))
```

### Put data in storage

```swift
myStorage.addValue(key: "dataKey", value: Data(), accessibility: .whenUnlocked(shouldBeMigrated: false))
```

This method may return `.tryToDuplicate`, which indicates that a value for the key already exists. 
In this case, you should use `updateValue` or `saveValue` instead

### Update data

```swift
myStorage.updateValue(key: "dataKey", value: Data(), accessibility: .whenUnlocked(shouldBeMigrated: false))
```

## Get data from storage

```swift
myStorage.searchValue(key: "dataKey", accessibility: .whenUnlocked(shouldBeMigrated: false))
```

## Get everything from storage

```swift
myStorage.searchAllValues(accessibility: .whenUnlocked(shouldBeMigrated: false))
```

## Remove data from storage

```swift
myStorage.removeValue(key: "dataKey", accessibility: .whenUnlocked(shouldBeMigrated: false))
```

# P.S.

This project is ideal for those looking for a dependable and straightforward solution for working with Keychain without extra dependencies, while maintaining a high level of confidence in its stability.
Feel free to make suggestions or comments 😉

