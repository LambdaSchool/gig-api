import Vapor
import FluentSQLite

final class GigController {
    
    func allGigsHandler(_ req: Request) throws -> Future<[Gig]> {
        _ = try req.requireAuthenticated(User.self)
        
        return Gig.query(on: req).all()
    }
    
//    /// Returns a list of all gigs for the auth'd user.
//    func index(_ req: Request) throws -> Future<[Gig]> {
//        // fetch auth'd user
//        let user = try req.requireAuthenticated(User.self)
//
//        // query all todo's belonging to user
//        return try Gig.query(on: req)
//            .filter(\.userID == user.requireID()).all()
//    }
    
    
    /// Creates a new gig for the auth'd user.
    func create(_ req: Request) throws -> Future<Gig> {
        // fetch auth'd user
        _ = try req.requireAuthenticated(User.self)
        
        // decode request content
        
        return try req.content.decode(CreateGigRequest.self).flatMap { gig in
            // save new todo
            
            return Gig(title: gig.title, description: gig.description, dueDate: gig.dueDate)
                .save(on: req)
        }
    }

    /// Deletes an existing Gig for the auth'd user.
//    func delete(_ req: Request) throws -> Future<HTTPStatus> {
//        // fetch auth'd user
//        let user = try req.requireAuthenticated(User.self)
//        
//        // decode request parameter (todos/:id)
//        return try req.parameters.next(Gig.self).flatMap { gig -> Future<Void> in
//            // ensure the todo being deleted belongs to this user
//            guard try gig.userID == user.requireID() else {
//                throw Abort(.forbidden)
//            }
//            
//            // delete model
//            return gig.delete(on: req)
//        }.transform(to: .ok)
//    }
}

// MARK: Content

struct CreateGigRequest: Content {
    
    var title: String
    var description: String
    var dueDate: Date

    enum CodingKeys: String, CodingKey {
        case title
        case description
        case dueDate
    }

    init(with decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let description = try container.decode(String.self, forKey: .description)
        let dueDate = try container.decode(Date.self, forKey: .dueDate)

        self.title = title
        self.description = description
        self.dueDate = dueDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(dueDate, forKey: .dueDate)
    }
}
