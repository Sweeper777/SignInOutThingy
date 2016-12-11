import UIKit

class RecordsController: UITableViewController {
    var entries: [Entry]?
    
    override func viewDidLoad() {
        if let entries = CoreDataHelper.entriesToday {
            self.entries = entries
            if UserDefaults.standard.bool(forKey: tagOnlyShowIncompleteEntries) {
                self.entries = self.entries?.filter { !$0.isComplete }
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Failed to get records.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.presentVC(alert)
        }
    }
    
    @IBAction func signInOutBtnPressed(sender: AnyObject) {
        performSegue(withIdentifier: "signInOut", sender: self)
    }
    
    @IBAction func visitorBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "visitorSignInOut", sender: self)
    }
    
    @IBAction func archiveBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "viewArchives", sender: self)
    }
    
    @IBAction func optionsBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "showOptions", sender: self)
    }
    
    @IBAction func statusesBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "showStatuses", sender: self)
    }
    
    @IBAction func unwindFromSignInOut(segue: UIStoryboardSegue) {
        CoreDataHelper.updateData()
        self.entries = CoreDataHelper.entriesToday
        if UserDefaults.standard.bool(forKey: tagOnlyShowIncompleteEntries) {
            self.entries = self.entries?.filter { !$0.isComplete }
        }
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = entries?[indexPath.row].description
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

