import CoreData
import UIKit

class CoreDataHelper {
    static var context = {
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
            return entries.filter { ($0.time1 as! Date).isTheSameDayAs(Date()) }
        }
        return nil
    }
    
    static func hasPersonCompletedEntry(person: String, isVisitor: Bool) -> Bool? {
        let personsEntries = entriesToday.filter { $0.name == person }
        if let lastEntry = personsEntries.sorted(by: { ($0.0.time1 as! Date) < ($0.1.time1 as! Date) } ).last {
            if lastEntry.isComplete {
                return true
            }
            
            if lastEntry.isVisitor != isVisitor {
                return nil
            } else {
                return lastEntry.isComplete
            }
        } else {
            return true
        }
    }
    
    static var locationList: [String] {
        return (UserDefaults.standard.string(forKey: tagLocationList) ?? "").components(separatedBy: "\n").filter { $0.trimmed() != "" }.sorted()
    }
    
    static var nameList: [String] {
        return (UserDefaults.standard.string(forKey: tagNameList) ?? "").components(separatedBy: "\n").filter { $0.trimmed() != "" }.sorted()
    }
}

extension Date {
    func isTheSameDayAs(_ other: Date) -> Bool {
        return self.date == other.date
    }
    
    func ignoreTimeComponents() -> Date {
        return self.date
    }
}
