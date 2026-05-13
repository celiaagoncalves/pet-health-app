import Foundation
import SwiftData

enum HealthRecordType: String, Codable, CaseIterable {
    case vaccine      = "Vacina"
    case deworming    = "Desparasitação"
    case consultation = "Consulta"
    case surgery      = "Cirurgia"
    case exam         = "Exame"
    case other        = "Outro"

    var icon: String {
        switch self {
        case .vaccine:      return "syringe"
        case .deworming:    return "cross.circle.fill"
        case .consultation: return "stethoscope"
        case .surgery:      return "staroflife.fill"
        case .exam:         return "doc.text"
        case .other:        return "heart.fill"
        }
    }

    var accentColor: String {
        switch self {
        case .vaccine:      return "blue"
        case .deworming:    return "green"
        case .consultation: return "orange"
        case .surgery:      return "red"
        case .exam:         return "purple"
        case .other:        return "gray"
        }
    }
}

@Model
final class HealthRecord {
    var type: HealthRecordType
    var name: String
    var date: Date
    var notes: String
    var nextDueDate: Date?
    var notificationID: String?
    var pet: Pet?

    init(type: HealthRecordType, name: String, date: Date,
         notes: String = "", nextDueDate: Date? = nil) {
        self.type = type
        self.name = name
        self.date = date
        self.notes = notes
        self.nextDueDate = nextDueDate
        self.notificationID = UUID().uuidString
    }
}
