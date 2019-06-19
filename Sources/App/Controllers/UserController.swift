import Crypto
import Vapor
import FluentSQLite

/// Creates new users and logs them in.
final class UserController {
    /// Logs a user in, returning a token for accessing protected endpoints.
    func login(_ req: Request) throws -> Future<Token> {
        return try req.content.decode(User.self).flatMap { decodedUser -> Future<Token> in
            
            return User.query(on: req)
                .filter(\.username == decodedUser.username)
                .first().flatMap { fetchedUser in
                    guard let existingUser = fetchedUser else {
                        throw Abort(HTTPStatus.notFound)
                    }
                    let hasher = try req.make(BCryptDigest.self)
                    if try hasher.verify(decodedUser.password, created: existingUser.password) {
                        let tokenString = try CryptoRandom().generateData(count: 32).base64EncodedString()
                        let token = try Token(token: tokenString, userId: existingUser.requireID())
                        return token.save(on: req)
                    } else {
                        throw Abort(HTTPStatus.unauthorized)
                    }
            }
        }
    }
    
    /// Creates a new user.
    func create(_ req: Request) throws -> Future<PublicUser> {
        // decode request content
        return try req.content
            .decode(User.self)
            .flatMap { user -> Future<PublicUser> in
            
            user.password = try BCrypt.hash(user.password)
            
                let publicUser = user.save(on: req).convertToPublic()

            return publicUser
            }
    }
    
    func clearUsers(_ req: Request) throws -> Future<HTTPResponseStatus> {
        return User.query(on: req)
            .all().flatMap { (users) -> EventLoopFuture<HTTPResponseStatus> in
                for user in users {
                    _ = user.delete(on: req)
                }
                let promise = req.eventLoop.newPromise(HTTPResponseStatus.self)
                promise.succeed(result: .ok)
                return promise.futureResult
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
