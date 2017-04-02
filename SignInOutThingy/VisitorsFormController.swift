import Eureka
import CoreData

class VisitorsFormController: FormViewController {
    let people = CoreDataHelper.nameList
    @IBOutlet var signInOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ TextRow(tagVisitor) {
            row in
            row.title = "Visitor"
            row.value = ""
            }
            
            +++ SegmentedRow<String>(tagInOrOut) {
                row in
                row.options = ["Out", "In"]
                row.value = "In"
                }.onChange {
                    row in
                    if row.value == "In" {
                        self.signInOutButton.title = "Sign In"
                    } else {
                        self.signInOutButton.title = "Sign Out"
                    }
        }
        
        //        var presenceDict = [String: Bool]()
        for person in people {
            var temp = CoreDataHelper.hasPersonCompletedEntry(person: person, isVisitor: true)
            temp = temp == nil ? nil : !temp!
            let visiting = temp
            form.allSections.last! <<< CheckRow("\(tagPerson)_\(person)") {
                row in
                row.title = person
                row.value = false
                row.hidden = .function([tagInOrOut]) {
                    form in
                    let inOrOutRow: SegmentedRow<String> = form.rowBy(tag: tagInOrOut)!
                    if visiting == nil {
                        return true
                    }
                    
                    if inOrOutRow.value == "In" && !visiting! {
                        return false
                    }
                    
                    if inOrOutRow.value == "Out" && visiting! {
                        return false
                    }
                    return true
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func signInOut(_ sender: Any) {
        func showErrorMessage(_ msg: String) {
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
        
        let values = form.values(includeHidden: false)
        let visitor = values[tagVisitor] as! String
        let inOrOut = values[tagInOrOut] as! String
        guard visitor.trimmed() != "" || inOrOut == "Out" else {
            showErrorMessage("Please enter the visitor's identity!")
            return
        }
        
        var selectedPerson: String?
        for person in people {
            if let selected = values["\(tagPerson)_\(person)"] as? Bool {
                if selected {
                    if selectedPerson == nil {
                        selectedPerson = person
                    } else {
                        showErrorMessage("Please select only one person!")
                        return
                    }
                }
            }
        }
        
        if selectedPerson == nil {
            showErrorMessage("Please select a person!")
            return
        }
        
        if inOrOut == "In" {
            let entry = Entry(entity: NSEntityDescription.entity(forEntityName: "Entry", in: CoreDataHelper.context)!, insertInto: CoreDataHelper.context, name: selectedPerson!, secondaryItem: visitor)
            entry.isVisitor = true
            try? CoreDataHelper.context.save()
        } else {
            let entry = (CoreDataHelper.entriesToday.filter { $0.name == selectedPerson }).sorted(by: { ($0.0.time1 as! Date) < ($0.1.time1 as! Date) } ).last!
            entry.time2 = NSDate()
            try? CoreDataHelper.context.save()
        }
        
        
        performSegue(withIdentifier: "signInOut", sender: self)
    }
}
