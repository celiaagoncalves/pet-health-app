import Foundation
import SwiftData

enum Species: String, Codable, CaseIterable {
    case dog = "Cão"
    case cat = "Gato"

    var icon: String {
        switch self {
        case .dog: return "🐕"
        case .cat: return "🐈"
        }
    }
}

enum Gender: String, Codable, CaseIterable {
    case male = "Macho"
    case female = "Fêmea"
}

enum CoatType: String, Codable, CaseIterable {
    case short = "Curto"
    case medium = "Médio"
    case long = "Longo"
    case curly = "Encaracolado"
    case hairless = "Sem pelo"
}

@Model
final class Pet {
    var name: String
    var species: Species
    var birthDate: Date
    var breed: String
    var gender: Gender
    var color: String
    var coatType: CoatType

    @Relationship(deleteRule: .cascade)
    var healthRecords: [HealthRecord] = []

    var age: String {
        let comps = Calendar.current.dateComponents([.year, .month], from: birthDate, to: .now)
        let y = comps.year ?? 0
        let m = comps.month ?? 0
        if y > 0 { return y == 1 ? "1 ano" : "\(y) anos" }
        if m > 0 { return m == 1 ? "1 mês" : "\(m) meses" }
        return "Recém-nascido"
    }

    init(name: String, species: Species, birthDate: Date, breed: String,
         gender: Gender, color: String, coatType: CoatType) {
        self.name = name
        self.species = species
        self.birthDate = birthDate
        self.breed = breed
        self.gender = gender
        self.color = color
        self.coatType = coatType
    }
}
