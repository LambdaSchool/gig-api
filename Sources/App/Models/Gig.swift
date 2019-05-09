import FluentSQLite
import Vapor


final class Gig: SQLiteModel, Content, Parameter, Migration {
    
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case dueDate
        case id
//        case userID
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let title = try container.decode(String.self, forKey: .title)
        let description = try container.decode(String.self, forKey: .description)
        let dueDate = try container.decode(Date.self, forKey: .dueDate)
        let id = try container.decodeIfPresent(Int.self, forKey: .id)
//        let userID = try container.decodeIfPresent(Int.self, forKey: .userID)

        self.title = title
        self.description = description
        self.dueDate = dueDate
        self.id = id
//        self.userID = userID
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(dueDate, forKey: .dueDate)
    }
    
    init(id: Int? = nil, title: String, description: String, dueDate: Date) {
        self.id = id
        self.title = title
        self.description = description
        self.dueDate = dueDate
//        self.userID = userID
    }
    
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Gig.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.title)
            builder.field(for: \.description)
//            builder.field(for: \.userID)
            builder.field(for: \.dueDate)
//            builder.reference(from: \.userID, to: \User.id)
        }
    }
    
    var id: Int?
    let title: String
    let description: String
    let dueDate: Date
//    var userID: User.ID?
//
//    var user: Parent<Gig, User> {
//        return parent(\.userID) ?? 1
//    }
}
