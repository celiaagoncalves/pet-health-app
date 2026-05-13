import SwiftUI
import SwiftData

private struct AlertItem: Identifiable {
    let id = UUID()
    let pet: Pet
    let record: HealthRecord
    var dueDate: Date { record.nextDueDate! }
    var isOverdue: Bool { dueDate < .now }
    var daysUntilDue: Int {
        Calendar.current.dateComponents([.day], from: .now, to: dueDate).day ?? 0
    }
}

struct AlertsView: View {
    @Query private var pets: [Pet]

    private var allAlerts: [AlertItem] {
        pets.flatMap { pet in
            pet.healthRecords.compactMap { record in
                guard record.nextDueDate != nil else { return nil }
                return AlertItem(pet: pet, record: record)
            }
        }
        .sorted { $0.dueDate < $1.dueDate }
    }

    private var overdueAlerts: [AlertItem] { allAlerts.filter { $0.isOverdue } }
    private var upcomingAlerts: [AlertItem] { allAlerts.filter { !$0.isOverdue } }

    var body: some View {
        NavigationStack {
            Group {
                if allAlerts.isEmpty {
                    emptyState
                } else {
                    List {
                        if !overdueAlerts.isEmpty {
                            Section {
                                ForEach(overdueAlerts) { AlertRow(item: $0) }
                            } header: {
                                Label("Em atraso", systemImage: "exclamationmark.circle.fill")
                                    .foregroundStyle(.red)
                            }
                        }
                        if !upcomingAlerts.isEmpty {
                            Section("Próximos") {
                                ForEach(upcomingAlerts) { AlertRow(item: $0) }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Alertas")
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56)).foregroundStyle(.green)
            Text("Tudo em dia!")
                .font(.title2).fontWeight(.semibold)
            Text("Sem alertas pendentes. Adiciona registos de saúde com datas de alerta para os ver aqui.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
    }
}

private struct AlertRow: View {
    let item: AlertItem

    private var statusColor: Color {
        item.isOverdue ? .red : item.daysUntilDue <= 7 ? .orange : .blue
    }

    private var statusLabel: String {
        if item.isOverdue {
            let days = abs(item.daysUntilDue)
            return days == 0 ? "Hoje" : "Há \(days) dia\(days == 1 ? "" : "s")"
        }
        if item.daysUntilDue == 0 { return "Hoje" }
        return "Em \(item.daysUntilDue) dia\(item.daysUntilDue == 1 ? "" : "s")"
    }

    private var typeColor: Color {
        switch item.record.type {
        case .vaccine:      return .blue
        case .deworming:    return .green
        case .consultation: return .orange
        case .surgery:      return .red
        case .exam:         return .purple
        case .other:        return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: item.record.type.icon).foregroundStyle(typeColor)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.record.name).font(.headline)
                HStack(spacing: 4) {
                    Text(item.pet.species.icon)
                    Text(item.pet.name).fontWeight(.medium)
                    Text("·")
                    Text(item.record.type.rawValue)
                }
                .font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(statusLabel)
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(statusColor)
                    .clipShape(Capsule())
                Text(item.dueDate, style: .date)
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
