import FluentSQLite
import Vapor


final class Gig: SQLiteModel, Content, Parameter, Migration {
    
    init(id: Int? = nil, title: String, description: String, dueDate: TimeInterval, userID: User.ID) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.userID = userID
    }
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Gig.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.description)
            builder.field(for: \.userID)
            builder.field(for: \.dueDate)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
    var id: Int?
    let title: String
    let description: String
    let dueDate: TimeInterval
    var userID: User.ID
    
    var user: Parent<Gig, User> {
        return parent(\.userID)
    }
}
