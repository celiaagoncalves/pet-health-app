import SwiftUI
import SwiftData

struct AddEditPetView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var pet: Pet?

    @State private var name = ""
    @State private var species: Species = .dog
    @State private var birthDate = Calendar.current.date(byAdding: .year, value: -1, to: .now)!
    @State private var breed = ""
    @State private var gender: Gender = .male
    @State private var color = ""
    @State private var coatType: CoatType = .short

    private var isEditing: Bool { pet != nil }
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !breed.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de animal") {
                    Picker("", selection: $species) {
                        ForEach(Species.allCases, id: \.self) { s in
                            Text("\(s.icon) \(s.rawValue)").tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(.init())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 6)
                }

                Section("Informações básicas") {
                    TextField("Nome *", text: $name)
                    TextField("Raça *", text: $breed)
                    DatePicker("Data de nascimento", selection: $birthDate,
                               in: ...Date.now, displayedComponents: .date)
                }

                Section("Características") {
                    Picker("Género", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Label(g.rawValue, systemImage: g == .male ? "mars" : "venus").tag(g)
                        }
                    }
                    TextField("Cor", text: $color)
                    Picker("Tipo de pelo", selection: $coatType) {
                        ForEach(CoatType.allCases, id: \.self) { ct in
                            Text(ct.rawValue).tag(ct)
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Editar pet" : "Novo pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditing ? "Guardar" : "Adicionar", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: loadExistingData)
        }
    }

    private func loadExistingData() {
        guard let pet else { return }
        name      = pet.name
        species   = pet.species
        birthDate = pet.birthDate
        breed     = pet.breed
        gender    = pet.gender
        color     = pet.color
        coatType  = pet.coatType
    }

    private func save() {
        if let pet {
            pet.name      = name
            pet.species   = species
            pet.birthDate = birthDate
            pet.breed     = breed
            pet.gender    = gender
            pet.color     = color
            pet.coatType  = coatType
        } else {
            let newPet = Pet(name: name, species: species, birthDate: birthDate,
                             breed: breed, gender: gender, color: color, coatType: coatType)
            modelContext.insert(newPet)
        }
        dismiss()
    }
}
