import SwiftUI
import SwiftData

struct PetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var pet: Pet
    @State private var showEditPet = false
    @State private var showAddRecord = false
    @State private var selectedType: HealthRecordType? = nil

    private var filteredRecords: [HealthRecord] {
        pet.healthRecords
            .filter { selectedType == nil || $0.type == selectedType }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                petHeader
                statsRow
                filterChips
                recordsList
            }
            .padding(.bottom, 24)
        }
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button { showEditPet = true } label: {
                        Label("Editar pet", systemImage: "pencil")
                    }
                    Button { showAddRecord = true } label: {
                        Label("Adicionar registo de saúde", systemImage: "plus")
                    }
                } label: { Image(systemName: "ellipsis.circle") }
            }
        }
        .sheet(isPresented: $showEditPet) { AddEditPetView(pet: pet) }
        .sheet(isPresented: $showAddRecord) { AddHealthRecordView(pet: pet) }
    }

    // MARK: - Header

    private var petHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(pet.species == .dog
                          ? Color.orange.opacity(0.2)
                          : Color.purple.opacity(0.2))
                    .frame(width: 96, height: 96)
                Text(pet.species.icon).font(.system(size: 48))
            }
            VStack(spacing: 4) {
                Text(pet.name).font(.title).fontWeight(.bold)
                HStack(spacing: 6) {
                    Label(pet.gender.rawValue,
                          systemImage: pet.gender == .male ? "mars" : "venus")
                    Text("·")
                    Text(pet.breed)
                    Text("·")
                    Text(pet.age)
                }
                .font(.subheadline).foregroundStyle(.secondary)
            }
            HStack(spacing: 24) {
                infoItem(label: "Cor", value: pet.color.isEmpty ? "—" : pet.color)
                Divider().frame(height: 32)
                infoItem(label: "Pelo", value: pet.coatType.rawValue)
            }
            .padding(.horizontal, 24).padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal)
        }
        .padding(.top)
    }

    private func infoItem(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline).fontWeight(.medium)
        }
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatCard(icon: "syringe", color: .blue, title: "Vacinas",
                     count: pet.healthRecords.filter { $0.type == .vaccine }.count)
            StatCard(icon: "cross.circle.fill", color: .green, title: "Desparasit.",
                     count: pet.healthRecords.filter { $0.type == .deworming }.count)
            StatCard(icon: "bell.fill", color: .orange, title: "Alertas",
                     count: pet.healthRecords.filter {
                         guard let d = $0.nextDueDate else { return false }
                         return d >= .now
                     }.count)
        }
        .padding(.horizontal)
    }

    // MARK: - Filter chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "Todos", isSelected: selectedType == nil) {
                    selectedType = nil
                }
                ForEach(HealthRecordType.allCases, id: \.self) { type in
                    FilterChip(title: type.rawValue, isSelected: selectedType == type) {
                        selectedType = selectedType == type ? nil : type
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Records list

    private var recordsList: some View {
        LazyVStack(spacing: 12) {
            if filteredRecords.isEmpty {
                emptyRecords
            } else {
                ForEach(filteredRecords) { record in
                    HealthRecordCard(record: record) { deleteRecord(record) }
                }
            }
        }
        .padding(.horizontal)
    }

    private var emptyRecords: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 40)).foregroundStyle(.secondary)
            Text("Sem registos de saúde").foregroundStyle(.secondary)
            Button { showAddRecord = true } label: {
                Text("Adicionar registo")
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 30)
    }

    private func deleteRecord(_ record: HealthRecord) {
        if let id = record.notificationID {
            NotificationManager.shared.cancelNotification(id: id)
        }
        modelContext.delete(record)
    }
}

// MARK: - Reusable components

struct StatCard: View {
    let icon: String
    let color: Color
    let title: String
    let count: Int

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color).font(.title3)
            Text("\(count)").font(.title2).fontWeight(.bold)
            Text(title).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 14).padding(.vertical, 7)
                .background(isSelected ? Color.accentColor : Color(.systemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

struct HealthRecordCard: View {
    let record: HealthRecord
    let onDelete: () -> Void

    private var isOverdue: Bool {
        guard let d = record.nextDueDate else { return false }
        return d < .now
    }

    private var isDueSoon: Bool {
        guard let d = record.nextDueDate, !isOverdue else { return false }
        return (Calendar.current.dateComponents([.day], from: .now, to: d).day ?? 0) <= 7
    }

    private var typeColor: Color {
        switch record.type {
        case .vaccine:      return .blue
        case .deworming:    return .green
        case .consultation: return .orange
        case .surgery:      return .red
        case .exam:         return .purple
        case .other:        return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: record.type.icon)
                    .foregroundStyle(typeColor).font(.title3).frame(width: 28)
                VStack(alignment: .leading, spacing: 2) {
                    Text(record.name).font(.headline)
                    Text(record.type.rawValue).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(record.date, style: .date).font(.caption).foregroundStyle(.secondary)
            }

            if !record.notes.isEmpty {
                Text(record.notes)
                    .font(.subheadline).foregroundStyle(.secondary)
                    .padding(.leading, 38)
            }

            if let next = record.nextDueDate {
                Divider()
                HStack {
                    Image(systemName: isOverdue
                          ? "exclamationmark.circle.fill"
                          : isDueSoon ? "clock.fill" : "calendar")
                        .foregroundStyle(isOverdue ? .red : isDueSoon ? .orange : .blue)
                    Group {
                        Text("Próxima: ").foregroundStyle(.secondary)
                        + Text(next, style: .date).fontWeight(.medium)
                    }
                    .font(.caption)
                    Spacer()
                    if isOverdue {
                        statusBadge("Em atraso", color: .red)
                    } else if isDueSoon {
                        statusBadge("Em breve", color: .orange)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Apagar registo", systemImage: "trash")
            }
        }
    }

    private func statusBadge(_ text: String, color: Color) -> some View {
        Text(text).font(.caption2).fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color).clipShape(Capsule())
    }
}
