import UIKit

class StatusesController: UITableViewController {
    var nameToPass: String?
    
    let people = CoreDataHelper.nameList
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = people[indexPath.row]
        let personsEntries = CoreDataHelper.entriesToday.filter { $0.name == people[indexPath.row] }
        if let lastEntry = personsEntries.sorted(by: { ($0.0.time1 as! Date) < ($0.1.time1 as! Date) } ).last {
            if lastEntry.isComplete {
                cell.detailTextLabel?.text = "Boarding House"
            } else if lastEntry.isVisitor {
                cell.detailTextLabel?.text = "Being visited by \(lastEntry.secondaryItem!)"
            } else {
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = .short
                timeFormatter.dateStyle = .none
                cell.detailTextLabel?.text = "Went to \(lastEntry.secondaryItem!) at \(timeFormatter.string(from: lastEntry.time1 as! Date))"
            }
        } else {
            cell.detailTextLabel?.text = "Boarding House"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        nameToPass = people[indexPath.row]
        performSegue(withIdentifier: "showStatistics", sender: self)
    }
 
    @IBAction func done(_ sender: Any) {
        dismissVC(completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? StatisticsController {
            vc.person = nameToPass
        }
    }
}
