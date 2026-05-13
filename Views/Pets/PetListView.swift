import SwiftUI
import SwiftData

struct PetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.name) private var pets: [Pet]
    @State private var showAddPet = false

    private var dogs: [Pet] { pets.filter { $0.species == .dog } }
    private var cats: [Pet] { pets.filter { $0.species == .cat } }

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    emptyState
                } else {
                    List {
                        petSection(title: "Cães 🐕", items: dogs)
                        petSection(title: "Gatos 🐈", items: cats)
                    }
                }
            }
            .navigationTitle("Os meus pets")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddPet = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showAddPet) { AddEditPetView() }
        }
    }

    @ViewBuilder
    private func petSection(title: String, items: [Pet]) -> some View {
        if !items.isEmpty {
            Section(title) {
                ForEach(items) { pet in
                    NavigationLink(destination: PetDetailView(pet: pet)) {
                        PetRowView(pet: pet)
                    }
                }
                .onDelete { offsets in deletePets(from: items, at: offsets) }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "pawprint")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            Text("Ainda não tens pets")
                .font(.title2).fontWeight(.semibold)
            Text("Adiciona o teu primeiro cão ou gato")
                .foregroundStyle(.secondary)
            Button { showAddPet = true } label: {
                Label("Adicionar pet", systemImage: "plus")
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .padding()
    }

    private func deletePets(from list: [Pet], at offsets: IndexSet) {
        for i in offsets {
            let pet = list[i]
            for record in pet.healthRecords {
                if let id = record.notificationID {
                    NotificationManager.shared.cancelNotification(id: id)
                }
            }
            modelContext.delete(pet)
        }
    }
}

struct PetRowView: View {
    let pet: Pet

    private var pendingCount: Int {
        pet.healthRecords.filter {
            guard let d = $0.nextDueDate else { return false }
            return d >= .now
        }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(pet.species == .dog
                          ? Color.orange.opacity(0.15)
                          : Color.purple.opacity(0.15))
                    .frame(width: 50, height: 50)
                Text(pet.species.icon).font(.title2)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.name).font(.headline)
                Text("\(pet.breed) · \(pet.age)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            if pendingCount > 0 {
                Label("\(pendingCount)", systemImage: "bell.fill")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}
