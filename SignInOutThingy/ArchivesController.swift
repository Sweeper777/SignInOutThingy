import UIKit

class ArchivesController: UITableViewController {
    var entries: [(date: Date, entries: [Entry])] = []
    var entriesToPass: [Entry]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let allEntries = CoreDataHelper.allEntries {
            for entry in allEntries {
                let indexOptional = entries.index(where: { $0.date.isTheSameDayAs(entry.time1! as Date) })
                if let index = indexOptional {
                    entries[index].entries.append(entry)
                } else {
                    entries.append(((entry.time1 as! Date).ignoreTimeComponents(), [entry]))
                }
            }
            self.editButtonItem.tintColor = UIColor.white
            self.navigationItem.rightBarButtonItem = self.editButtonItem
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed to retrieve archives", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        cell.textLabel?.text = formatter.string(from: entries[indexPath.row].date)
        let entryCount = entries[indexPath.row].entries.count
        if entryCount == 1 {
            cell.detailTextLabel?.text = "\(entryCount) Entry"
        } else {
            cell.detailTextLabel?.text = "\(entryCount) Entries"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entriesToDelete = entries[indexPath.row].entries
            entries.remove(at: indexPath.row)
            for entry in entriesToDelete {
                CoreDataHelper.context.delete(entry)
            }
            try! CoreDataHelper.context.save()
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        entriesToPass = entries[indexPath.row].entries
        performSegue(withIdentifier: "showArchive", sender: self)
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ArchiveViewerController {
            vc.entries = entriesToPass
        }
    }

}
