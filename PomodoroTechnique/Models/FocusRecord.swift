import Foundation

struct FocusRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let date: String // yyyy/MM/dd
    let taskName: String
    let duration: Int // 秒
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, date, taskName, duration, isCompleted
    }
}
