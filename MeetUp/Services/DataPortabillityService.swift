import Foundation
import SwiftData

enum DataPortabilityError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileWriteFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Не удалось подготовить данные для экспорта."
        case .decodingFailed:
            return "Не удалось прочитать файл — проверьте, что это корректный экспорт MeetUp."
        case .fileWriteFailed:
            return "Не удалось сохранить файл экспорта."
        }
    }
}

final class DataPortabilityService {
    func exportData(people: [Person]) throws -> URL {
        let dtos = people.map(PersonDTO.init)
        let file = PeopleExportFile(people: dtos)

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(file) else {
            throw DataPortabilityError.encodingFailed
        }

        let fileName = "MeetUp-Export-\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw DataPortabilityError.fileWriteFailed
        }
    }

    @discardableResult
    func importData(from url: URL, into context: ModelContext) throws -> Int {
        let needsSecurityScope = url.startAccessingSecurityScopedResource()
        defer { if needsSecurityScope { url.stopAccessingSecurityScopedResource() } }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let file = try? decoder.decode(PeopleExportFile.self, from: data) else {
            throw DataPortabilityError.decodingFailed
        }

        for dto in file.people {
            context.insert(dto.toPerson())
        }
        try context.save()
        return file.people.count
    }
}
