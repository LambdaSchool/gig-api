import Authentication
import FluentSQLite
import Vapor

final class User: SQLiteModel {
    var id: Int?
    var username: String
    var password: String
    
    init(id: Int? = nil, username: String, password: String) {
        self.id = id
        self.username = username
        self.password = password
    }
}

final class PublicUser: Codable {
    var id: Int?
    var username: String
    
    init(id: Int?, username: String) {
        self.id = id
        self.username = username
    }
}
extension PublicUser: Content {
    
}

extension User: Content {}
extension User: Migration {}
extension User: Parameter {}

extension User {
    func convertToPublic() -> PublicUser {
        return PublicUser(id: id, username: username)
    }
}

extension Future where T: User {
    func convertToPublic() -> Future<PublicUser> {
        return self.map(to: PublicUser.self) { user in
            return user.convertToPublic()
        }
    }
}
//
extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}
//
extension User: TokenAuthenticatable {
    typealias TokenType = Token
}
