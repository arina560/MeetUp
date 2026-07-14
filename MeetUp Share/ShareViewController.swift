import UIKit
import SwiftUI
import UniformTypeIdentifiers
import SwiftData
import CoreLocation

class ShareViewController: UIViewController {
    private let groupIdentifier = "group.com.arinapetr.MeetUp"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadSharedImage { [weak self] data in
            guard let self else { return }
            DispatchQueue.main.async {
                self.presentShareUI(with: data)
            }
        }
    }

    private func presentShareUI(with imageData: Data?) {
        let shareView = ShareView(
            imageData: imageData,
            onCancel: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: NSError(domain: "MeetUpShare", code: 0))
            },
            onSave: { [weak self] name, photo, coordinate in
                self?.save(name: name, photo: photo, coordinate: coordinate)
            }
        )

        let hosting = UIHostingController(rootView: shareView)
        addChild(hosting)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
    }

    private func loadSharedImage(completion: @escaping (Data?) -> Void) {
        guard
            let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let attachment = item.attachments?.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.image.identifier) })
        else {
            completion(nil)
            return
        }

        attachment.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
            if let url = item as? URL, let data = try? Data(contentsOf: url) {
                completion(data)
            } else if let image = item as? UIImage {
                completion(image.pngData())
            } else if let data = item as? Data {
                completion(data)
            } else {
                completion(nil)
            }
        }
    }

    private func save(name: String, photo: Data, coordinate: CLLocationCoordinate2D?) {
        do {
            let schema = Schema([Person.self])
            let configuration = ModelConfiguration(schema: schema, groupContainer: .identifier(groupIdentifier))
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)

            let person = Person(name: name, photo: photo, latitude: coordinate?.latitude, longitude: coordinate?.longitude)
            context.insert(person)
            try context.save()

            extensionContext?.completeRequest(returningItems: nil)
        } catch {
            print("Share extension: failed to save person: \(error)")
            extensionContext?.cancelRequest(withError: error)
        }
    }
}
