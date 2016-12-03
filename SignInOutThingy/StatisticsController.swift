import UIKit

class StatisticsController: UITableViewController {
    var person: String?
    
    @IBOutlet var wentOutTimes: UILabel!
    @IBOutlet var beingVisitedTimes: UILabel!
    @IBOutlet var totalTimeOutisde: UILabel!
    @IBOutlet var totalTimeBeingVisited: UILabel!
    @IBOutlet var forgotTimes: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = person
        if let entries = (CoreDataHelper.allEntries?.filter { $0.name == self.person }) {
            let wentOutEntries = entries.filter { !$0.isVisitor }
            if wentOutEntries.count == 1 {
                wentOutTimes.text = "1 Time"
            } else {
                wentOutTimes.text = "\(wentOutEntries.count) Times"
            }
            
            let visitorEntries = entries.filter { $0.isVisitor }
            if visitorEntries.count == 1 {
                beingVisitedTimes.text = "1 Time"
            } else {
                beingVisitedTimes.text = "\(visitorEntries.count) Times"
            }
            
            let totalTimeOutside = wentOutEntries.reduce(0) {
                (interval: Double, entry: Entry) in
                if entry.time2 == nil {
                    return interval
                }
                return interval + entry.time2!.timeIntervalSince(entry.time1 as! Date) as Double
            }
            self.totalTimeOutisde.text = normalize(timeInterval: totalTimeOutside)
            
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed to retrieve statistics", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.presentVC(alert)
        }
    }
}

func normalize(timeInterval: TimeInterval) -> String {
    let hours = Int(timeInterval) % 86400 / 60 / 60
    let minutes = Int(timeInterval) % 3600 / 60
    let seconds = Int(timeInterval) % 60
    
    if hours == minutes && minutes == seconds && seconds == 0 {
        return "N/A"
    }
    
    var normalized = ""
    
    if hours == 1 {
        normalized += "\(hours) Hour "
    } else if hours != 0 {
        normalized += "\(hours) Hours "
    }
    
    if minutes == 1 {
        normalized += "\(minutes) Minute "
    } else if minutes != 0 {
        normalized += "\(minutes) Minutes "
    }
    
    if seconds == 1 {
        normalized += "\(seconds) Second "
    } else if seconds != 0 {
        normalized += "\(seconds) Seconds "
    }
    
    return normalized
}
