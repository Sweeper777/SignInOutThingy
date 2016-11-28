import CoreData

extension Entry {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, name: String, secondaryItem: String) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.secondaryItem = secondaryItem
        self.time1 = NSDate()
        self.isVisitor = false
    }
    
    public override var description: String {
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        
        if !isVisitor {
            var returnValue = "\(name!) went to \(secondaryItem!) at \(timeFormatter.string(from: time1 as! Date))"
            if let time2 = self.time2 {
                returnValue += " and returned at \(timeFormatter.string(from: time2 as Date))"
            } else if !(time1 as! Date).isToday {
                returnValue += " <b>and forgot to sign in</b>"
            }
            
            return returnValue
        } else {
            var returnValue = "\(secondaryItem!) visited \(name!) at \(timeFormatter.string(from: time1 as! Date))"
            if let time2 = self.time2 {
                returnValue += " and left at \(timeFormatter.string(from: time2 as Date))"
            } else if !(time1 as! Date).isToday {
                returnValue += " <b>and forgot to sign out</b>"
            }
            
            return returnValue
        }
    }
    
    var isComplete: Bool {
        return time2 != nil
    }
}
