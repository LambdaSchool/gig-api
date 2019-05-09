import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<UserToken> {
        // get user auth'd by basic auth middleware
        return try req.content.decode(CreateUserRequest.self).flatMap({ (decodedUser) -> EventLoopFuture<UserToken> in
            
            return User.query(on: req)
                .filter(\.username == decodedUser.username)
                .first()
                .flatMap({ (databaseUser) -> EventLoopFuture<UserToken> in
                    
                    guard let databaseUser = databaseUser else {
                        throw Abort(.notFound)
                    }
                    
                    let hasher = try req.make(BCryptDigest.self)
                    
                    if try hasher.verify(decodedUser.password, created: databaseUser.passwordHash) {
                        let tokenString = try CryptoRandom().generateData(count: 32).base64EncodedString()
                        
                        let token = try UserToken(id: nil, string: tokenString, userID: databaseUser.requireID())
                        return token.save(on: req)
                    } else {
                        throw Abort(HTTPStatus.unauthorized)
                    }
                })
        })
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<UserResponse> {
        // decode request content
        return try req.content.decode(CreateUserRequest.self).flatMap { user -> Future<User> in
            
            // hash user's password using BCrypt
            let hash = try BCrypt.hash(user.password)
            // save new user
            return User(id: nil, username: user.username, passwordHash: hash)
                .save(on: req)
            }.map { user in
                // map to public user response (omits password hash)
                return try UserResponse(id: user.requireID(), username: user.username)
        }
    }
}

// MARK: Content

/// Data required to create a user.
struct CreateUserRequest: Content {
    /// User's username.
    var username: String
    
    /// User's desired password.
    var password: String
}

/// Public representation of user data.
struct UserResponse: Content {
    /// User's unique identifier.
    /// Not optional since we only return users that exist in the DB.
    var id: Int
    
    /// User's username
    var username: String
}
