import CoreData

extension Entry {
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, name: String, location: String) {
        self.init(entity: entity, insertInto: context)
        self.name = name
        self.location = name
        self.goTime = NSDate()
    }
    
    public override var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .long
        
        var returnValue = "[\(dateFormatter.string(from: goTime as! Date))] \(name) went to \(location) at \(timeFormatter.string(from: goTime as! Date))"
        if let returnTime = self.returnTime {
            returnValue += " and returned at \(timeFormatter.string(from: returnTime as Date))"
        }
        
        return returnValue
    }
}
