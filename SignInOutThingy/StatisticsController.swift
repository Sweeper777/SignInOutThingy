import UIKit
import SwiftChart
import SwiftDate

class StatisticsController: UITableViewController, ChartDelegate {
    var person: String?
    
    @IBOutlet var wentOutTimes: UILabel!
    @IBOutlet var beingVisitedTimes: UILabel!
    @IBOutlet var totalTimeOutside: UILabel!
    @IBOutlet var totalTimeBeingVisited: UILabel!
    @IBOutlet var forgotTimes: UILabel!
    @IBOutlet var timeOutsideChart: Chart!
    @IBOutlet var label: UILabel!
    @IBOutlet var labelLeadingMarginConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = person
        label.isHidden = true
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
            self.totalTimeOutside.text = normalize(timeInterval: totalTimeOutside)
            
            let totalTimeBeingVisited = visitorEntries.reduce(0) {
                (interval: Double, entry: Entry) in
                if entry.time2 == nil {
                    return interval
                }
                return interval + entry.time2!.timeIntervalSince(entry.time1 as! Date) as Double
            }
            self.totalTimeBeingVisited.text = normalize(timeInterval: totalTimeBeingVisited)
            
            let forgotTimes = entries.filter { $0.time2 == nil && !($0.time1 as! Date).isToday }.count
            
            if forgotTimes == 1 {
                self.forgotTimes.text = "1 Time"
            } else {
                self.forgotTimes.text = "\(forgotTimes) Times"
            }
            
            var groupedWentOutEntries = [(date: Date, totalTime: TimeInterval)]()
            for entry in (wentOutEntries.filter { $0.time2 != nil }) {
                let indexOptional = groupedWentOutEntries.index(where: { $0.date.isTheSameDayAs(entry.time1! as Date) })
                if let index = indexOptional {
                    groupedWentOutEntries[index].totalTime += entry.time2!.timeIntervalSince(entry.time1! as Date)
                } else {
                    groupedWentOutEntries.append(((entry.time1 as! Date).ignoreTimeComponents(), entry.time2!.timeIntervalSince(entry.time1! as Date)))
                }
            }
            
            if groupedWentOutEntries.count > 1 {
                timeOutsideChart.delegate = self
                
                let dataSeries = ChartSeries(groupedWentOutEntries.map { Float($0.totalTime) })
                dataSeries.area = true
                timeOutsideChart.add(dataSeries)
                timeOutsideChart.minY = 0
                timeOutsideChart.yLabelsFormatter = {
                    index, value in
                    return self.getHumanReadableTime(timeInterval: TimeInterval(value))
                }
                
                let max = groupedWentOutEntries.map { $0.totalTime }.max()!
                timeOutsideChart.yLabels = getYValues(max: max)
                
                timeOutsideChart.xLabelsFormatter = {
                    index, value in
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .short
                    dateFormatter.timeStyle = .none
                    return dateFormatter.string(from: groupedWentOutEntries[index].date)
                }
                
                timeOutsideChart.xLabels = Array(stride(from: 0.0, through: Float(groupedWentOutEntries.count), by: 1))
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed to retrieve statistics", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func getYValues(max: TimeInterval) -> [Float] {
        if max < 60 {
            return [0, 10, 20, 30, 40, 50, 60]
        }
        
        if max < 60 * 30 {
            return stride(from: 0, through: 30, by: 3).map { $0 * 60 }
        }
        
        if max < 60 * 60 {
            return [0, 600, 1200, 1800, 2400, 3000, 3600]
        }
        
        let hours = ceil(max / 60 / 60)
        return Array(stride(from: 0.0, through: Float(hours) * 60 * 60, by: Float(hours * 60 * 60 / 10)))
    }
    
    func getHumanReadableTime(timeInterval: TimeInterval) -> String {
        let decimalFormatter = NumberFormatter()
        decimalFormatter.maximumFractionDigits = 2
        if timeInterval == 0 {
            return "0"
        }
        if timeInterval < 60 {
            return "\(Int(timeInterval)) sec"
        } else if timeInterval < 60 * 60 {
            return "\(decimalFormatter.string(from: (timeInterval / 60) as NSNumber)!) min"
        } else {
            return "\(decimalFormatter.string(from: (timeInterval / 60 / 60) as NSNumber)!) h"
        }
    }
    
    func didTouchChart(_ chart: Chart, indexes: Array<Int?>, x: Float, left: CGFloat) {
        
        if let value = chart.valueForSeries(0, atIndex: indexes[0]) {
            label.isHidden = false
            let labelLeadingMarginInitialConstant = CGFloat(0)
            label.text = getHumanReadableTime(timeInterval: TimeInterval(value))
            
            // Align the label to the touch left position, centered
            var constant = labelLeadingMarginInitialConstant + left - (label.frame.width / 2)
            
            // Avoid placing the label on the left of the chart
            if constant < labelLeadingMarginInitialConstant {
                constant = labelLeadingMarginInitialConstant
            }
            
            // Avoid placing the label on the right of the chart
            let rightMargin = chart.frame.width - label.frame.width
            if constant > rightMargin {
                constant = rightMargin
            }
            
            labelLeadingMarginConstraint.constant = constant
            
        }
        
    }
    
    func didFinishTouchingChart(_ chart: Chart) {
        label.isHidden = true
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
