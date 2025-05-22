import Foundation
import CoreData
import SwiftUI

// A SwiftUI wrapper for NSFetchedResultsController to provide reactive updates
class FetchedResultsControllerWrapper<T: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var items: [T] = []
    private let controller: NSFetchedResultsController<T>
    
    init(fetchRequest: NSFetchRequest<T>, context: NSManagedObjectContext) {
        controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        super.init()
        controller.delegate = self
        
        do {
            try controller.performFetch()
            items = controller.fetchedObjects ?? []
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let newItems = controller.fetchedObjects as? [T] else { return }
        items = newItems
    }
} 