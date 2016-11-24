import CoreData
import UIKit
import SwiftDate

class CoreDataHelper {
    private static var context = {
       return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }()
    
    static var allEntries = { () -> [Entry]? in
        let entityDesc = NSEntityDescription.entity(forEntityName: "Entry", in: context)
        let request = NSFetchRequest<Entry>()
        request.entity = entityDesc
        return try? context.fetch(request)
    }()
    
    static func updateData() {
        let entityDesc = NSEntityDescription.entity(forEntityName: "Entry", in: context)
        let request = NSFetchRequest<Entry>()
        request.entity = entityDesc
        allEntries = try? context.fetch(request)
    }
    
    static var entriesToday: [Entry]! {
        if let entries = allEntries {
            return entries.filter { ($0.goTime as! Date).isTheSameDayAs(Date()) }
        }
        return nil
    }
    
    static func isPersonIn(person: String) -> Bool {
        let personsEntries = entriesToday.filter { $0.name == person }
        if let lastEntry = personsEntries.sorted(by: { ($0.0.goTime as! Date) < ($0.1.goTime as! Date) } ).last {
            return lastEntry.isIn
        } else {
            return true
        }
    }
}

extension Date {
    func isTheSameDayAs(_ other: Date) -> Bool {
        return self.day == other.day &&
            self.month == other.month &&
            self.year == other.year
    }
}
