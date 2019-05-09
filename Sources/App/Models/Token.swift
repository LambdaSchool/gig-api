import Authentication
import Crypto
import FluentSQLite
import Vapor

final class Token: SQLiteModel {
    var id: Int?
    var token: String
    var userId: User.ID
    
    init(token: String, userId: User.ID) {
        self.token = token
        self.userId = userId
    }
}
extension Token {
    var user: Parent<Token, User> {
        return parent(\.userId)
    }
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}

extension Token: Authentication.Token {
    typealias UserType = User
    typealias UserIDType = User.ID
    static var userIDKey: WritableKeyPath<Token, User.ID> {
        return \Token.userId
    }
}

extension Token: Migration {
    //    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
    //        return Database.create(self, on: connection) { builder in
    //            try addProperties(to: builder)
    //            builder.reference(from: \.userID, to: \User.id)
    //        }
    //    }
}

extension Token: Content {}
