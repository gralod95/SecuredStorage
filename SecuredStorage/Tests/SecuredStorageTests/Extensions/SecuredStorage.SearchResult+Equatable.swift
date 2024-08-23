@testable import SecuredStorage

extension SecuredStorage.SearchResult: Equatable where Element: Equatable {
    public static func == (
        lhs: SecuredStorage.SearchResult<Element>,
        rhs: SecuredStorage.SearchResult<Element>
    ) -> Bool {
        switch (lhs, rhs) {
        case let (.success(lhsOut), .success(rhsOut)):
            return lhsOut == rhsOut
        case (.notFound, .notFound):
            return true
        case let (.failure(lhsOut), .failure(rhsOut)):
            return lhsOut == rhsOut
        case (.failure, .success),
            (.failure, .notFound),
            (.notFound, .success),
            (.notFound, .failure),
            (.success, .notFound),
            (.success, .failure):
            return false
        }
    }
}
