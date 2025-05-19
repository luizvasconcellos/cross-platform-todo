import Foundation
import Capacitor

//var mockedData = [
//    1: [
//        "id": 1,
//        "name": "Interview with Ionic",
//        "dueDate": 1634569785944,
//        "done": true
//    ],
//    2: [
//        "id": 2,
//        "name": "Create amazing product",
//        "dueDate": 1634569785944,
//        "done": false
//    ],
//    3: [
//        "id": 3,
//        "name": "???",
//        "dueDate": 1634569785944,
//        "done": false
//    ],
//    4: [
//        "id": 4,
//        "name": "Profit",
//        "dueDate": 1634569785944,
//        "done": false
//    ],
//]

@objc(ToDoPlugin)
public class ToDoPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "ToDoPlugin"
    public let jsName = "ToDo"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "getAll", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "getOne", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "upsert", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "delete", returnType: CAPPluginReturnPromise)
    ]
    
    private let todoService: TodoServiceProtocol
    
    // MARK: - init
    public override init() {
        todoService = ToDoService()
        super.init()
    }

    // MARK: - Plugin methods
     @objc func getAll(_ call: CAPPluginCall) {
         Task { @MainActor in
             let todos = await todoService.getAll()
             let serializedTodos = todos.sorted { $0.key < $1.key }
                 .reduce(into: [[String: Any]]()) { result, item in
                     result.append(serializeToDo(id: item.key, todo: item.value))
                 }
             
             call.resolve(["todos": serializedTodos])
         }
     }

     @objc func getOne(_ call: CAPPluginCall) {
         guard let id = call.getInt("id") else {
             call.reject("Malformed request, missing option id")
             return
         }
         Task { @MainActor in
             do {
                 if let todo = try await todoService.getOne(id: id) {
                     let serializedTodo = serializeToDo(id: id, todo: todo)
                     call.resolve(["todo": serializedTodo])
                 } else {
                     call.reject("Todo not found")
                 }
             } catch {
                 call.reject("Failed to fetch todo")
             }
         }
     }

     @objc func upsert(_ call: CAPPluginCall) {
         Task { @MainActor in
             guard let name = call.getString("name"),
                   let dueDate = call.getDouble("dueDate"),
                   let done = call.getBool("done") else {
                 call.reject("Missing fields")
                 return
             }
             
             let id = call.getInt("id")
             
             let todoObj = ToDo(id: id,
                                name: name,
                                dueDate: Int64(dueDate),
                                done: done)
             
             await todoService.save(todoObj)
             
             call.resolve()
         }
     }

     @objc func delete(_ call: CAPPluginCall) {
         guard let id = call.getInt("id") else {
             call.reject("Malformed request, missing option id")
             return
         }
         Task { @MainActor in
             do {
                 try await todoService.delete(id: id)
                 call.resolve()
             } catch {
                 call.reject("Failed to delete todo")
             }
         }
                
     }
 }

// MARK: - Private functions
extension ToDoPlugin {
    private func serializeToDo(id: Int, todo: ToDo) -> [String: Any] {
        return [
            "id": id,
            "name": todo.name,
            "dueDate": todo.dueDate,
            "done": todo.done
        ]
    }
}
