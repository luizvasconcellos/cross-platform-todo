import Foundation

protocol TodoServiceProtocol {
    func getAll() async -> [Int: ToDo]
    func getOne(id: Int?) async throws -> ToDo?
    func save(_ todo: ToDo) async
    func delete(id: Int?) async throws
}

class ToDoService: TodoServiceProtocol {
    
    private var mockedData: [Int: ToDo] = [
        1: ToDo(id: 1, name: "Interview with Ionic", dueDate: 1634569785944, done: true),
        2: ToDo(id: 2, name: "Create amazing product", dueDate: 1634569785944, done: false),
        3: ToDo(id: 3, name: "???", dueDate: 1634569785944, done: false),
        4: ToDo(id: 4, name: "Profit", dueDate: 1634569785944, done: false)
    ]
    
    func getAll() async -> [Int: ToDo] {
        let todoItems = mockedData.sorted { $0.key < $1.key }
        return Dictionary(uniqueKeysWithValues: todoItems)
    }
    
    func getOne(id: Int?) async throws -> ToDo? {
        guard let id = id else {
            throw NSError(domain: "ToDoService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid ID"])
        }
        return mockedData[id]
    }

    func save(_ todo: ToDo) async {
        var todo = todo
        let id = todo.id ?? (mockedData.keys.max() ?? 0) + 1
        todo.id = id
        return mockedData[id] = todo
    }
    
    func delete(id: Int?) async throws {
        guard let id = id else {
            throw NSError(domain: "ToDoService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid ID"])
        }
        mockedData.removeValue(forKey: id)
    }
}
