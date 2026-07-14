import Foundation
import SwiftData
import Observation

@Observable
final class PeopleListViewModel {
    var searchText = ""
    var isGrid = false

    var showingAddPerson = false
    var showingImportPicker = false
    var exportURL: URL?
    var showingExportShare = false

    var errorMessage: String?
    var lastImportCount: Int?

    private let portabilityService = DataPortabilityService()

    func filteredPeople(from people: [Person]) -> [Person] {
        guard !searchText.isEmpty else { return people }

        return people.filter { person in
            if person.name.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            if person.tags.contains(where: { $0.localizedCaseInsensitiveContains(searchText) }) {
                return true
            }
            if let meetingDate = person.meetingDate,
               formattedDate(meetingDate).localizedCaseInsensitiveContains(searchText) {
                return true
            }
            return false
        }
    }

    func toggleFavorite(_ person: Person) {
        person.isFavorite.toggle()
    }

    func deletePeople(at offsets: IndexSet, from people: [Person], context: ModelContext) {
        for offset in offsets {
            context.delete(people[offset])
        }
    }

    func exportPeople(_ people: [Person]) {
        do {
            exportURL = try portabilityService.exportData(people: people)
            showingExportShare = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importPeople(from url: URL, context: ModelContext) {
        do {
            lastImportCount = try portabilityService.importData(from: url, into: context)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}
