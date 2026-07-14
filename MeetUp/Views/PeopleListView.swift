import SwiftUI
import SwiftData
import PhotosUI

struct PeopleListView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var people: [Person]
    @State private var viewModel = PeopleListViewModel()
    private let showFavoriteOnly: Bool

    init(showFavoriteOnly: Bool) {
        self.showFavoriteOnly = showFavoriteOnly
        var predicate: Predicate<Person>?
        if showFavoriteOnly {
            predicate = #Predicate { $0.isFavorite == true }
        }
        _people = Query(filter: predicate, sort: \Person.name)
    }

    var filteredPeople: [Person] {
        viewModel.filteredPeople(from: people)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isGrid {
                    gridView
                } else {
                    listView
                }
            }
            .navigationTitle(showFavoriteOnly ? "Favorites" : "People")
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name, tag or date")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            viewModel.showingImportPicker = true
                        } label: {
                            Label("Import from JSON", systemImage: "square.and.arrow.down")
                        }
                        Button {
                            viewModel.exportPeople(people)
                        } label: {
                            Label("Export to JSON", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddPerson = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.isGrid.toggle()
                    } label: {
                        Image(systemName: viewModel.isGrid ? "list.bullet" : "square.grid.2x2")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddPerson) {
                AddPersonView()
            }
            .sheet(isPresented: $viewModel.showingExportShare) {
                if let url = viewModel.exportURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .fileImporter(isPresented: $viewModel.showingImportPicker, allowedContentTypes: [.json]) { result in
                switch result {
                case .success(let url):
                    viewModel.importPeople(from: url, context: modelContext)
                case .failure(let error):
                    viewModel.errorMessage = error.localizedDescription
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var listView: some View {
        List {
            ForEach(filteredPeople) { person in
                HStack(spacing: 12) {
                    NavigationLink {
                        PersonDetailView(person: person)
                    } label: {
                        HStack {
                            personImage(person)
                            personInfoLabel(person)
                        }
                    }
                    Spacer(minLength: 0)
                    Button {
                        viewModel.toggleFavorite(person)
                    } label: {
                        Image(systemName: person.isFavorite ? "heart.fill" : "heart")
                            .font(.title3)
                            .foregroundColor(person.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .onDelete { offsets in
                viewModel.deletePeople(at: offsets, from: filteredPeople, context: modelContext)
            }
        }
    }

    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                ForEach(filteredPeople) { person in
                    VStack(spacing: 8) {
                        NavigationLink {
                            PersonDetailView(person: person)
                        } label: {
                            VStack(spacing: 8) {
                                personImage(person)
                                    .frame(width: 120, height: 120)
                                Text(person.name)
                                    .font(.caption)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .buttonStyle(.plain)

                        Button {
                            viewModel.toggleFavorite(person)
                        } label: {
                            Image(systemName: person.isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(person.isFavorite ? .red : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func personImage(_ person: Person) -> some View {
        if let uiImage = UIImage(data: person.photo) {
            return AnyView(
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
        } else {
            return AnyView(
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            )
        }
    }

    private func personInfoLabel(_ person: Person) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(person.name)
                .font(.headline)

            if !person.tags.isEmpty {
                Text(person.tags.joined(separator: ", "))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            if person.latitude != nil && person.longitude != nil {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption2)
                    Text("Location saved")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

/// Thin UIKit bridge used to present the system share sheet for the exported JSON file.
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    PeopleListView(showFavoriteOnly: true)
}
