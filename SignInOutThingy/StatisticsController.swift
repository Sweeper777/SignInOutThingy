import UIKit

class StatisticsController: UITableViewController {
    var person: String?
    
    @IBOutlet var wentOutTimes: UILabel!
    @IBOutlet var beingVisitedTimes: UILabel!
    @IBOutlet var totalTimeOutisde: UILabel!
    @IBOutlet var totalTimeBeingVisited: UILabel!
    @IBOutlet var forgotTimes: UILabel!
    
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
