import Foundation

struct ToDo: Codable {
    var id: Int?
    var name: String
    var dueDate: Int64
    var done: Bool
}
