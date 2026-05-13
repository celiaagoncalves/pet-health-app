import SwiftUI

struct AddHealthRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pet: Pet

    @State private var type: HealthRecordType = .vaccine
    @State private var name = ""
    @State private var date = Date.now
    @State private var notes = ""
    @State private var hasNextDue = false
    @State private var nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: .now)!
    @State private var scheduleNotification = true

    private var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    private var namePlaceholder: String {
        switch type {
        case .vaccine:      return "Ex: Raiva, Parvovírus, Esgana..."
        case .deworming:    return "Ex: Milbemax, Advocate, Bravecto..."
        case .consultation: return "Motivo da consulta"
        case .surgery:      return "Nome da cirurgia"
        case .exam:         return "Tipo de exame"
        case .other:        return "Descrição"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Tipo de registo") {
                    Picker("Tipo", selection: $type) {
                        ForEach(HealthRecordType.allCases, id: \.self) { t in
                            Label(t.rawValue, systemImage: t.icon).tag(t)
                        }
                    }
                }

                Section("Detalhes") {
                    TextField(namePlaceholder, text: $name)
                    DatePicker("Data", selection: $date,
                               in: ...Date.now, displayedComponents: .date)
                    TextField("Notas (opcional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Definir próxima data / alerta", isOn: $hasNextDue.animation())
                    if hasNextDue {
                        DatePicker("Data do alerta", selection: $nextDueDate,
                                   in: Date.now..., displayedComponents: .date)
                        Toggle("Ativar notificações", isOn: $scheduleNotification)
                    }
                } header: {
                    Text("Próxima dose / alerta")
                } footer: {
                    if hasNextDue && scheduleNotification {
                        Text("Receberás uma notificação às 9h no dia do alerta e 3 dias antes.")
                    }
                }
            }
            .navigationTitle("Novo registo — \(pet.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar", action: save)
                        .fontWeight(.semibold)
                        .disabled(!isValid)
                }
            }
        }
    }

    private func save() {
        let record = HealthRecord(
            type: type,
            name: name,
            date: date,
            notes: notes,
            nextDueDate: hasNextDue ? nextDueDate : nil
        )
        modelContext.insert(record)
        record.pet = pet

        if hasNextDue && scheduleNotification, let id = record.notificationID {
            NotificationManager.shared.schedule(
                id: id,
                petName: pet.name,
                recordName: name,
                type: type,
                date: nextDueDate
            )
        }
        dismiss()
    }
}
