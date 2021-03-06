import Eureka
import CoreData
import SCLAlertView

class SignInOutFormController: FormViewController {
    let people = CoreDataHelper.nameList
    @IBOutlet var signInOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        form +++ PushRow<String>(tagLocation) {
            row in
            row.title = "Location"
            var options = CoreDataHelper.locationList
            options.append("Custom")
            row.options = options
        }
        
            <<< TextRow(tagCustomLocation) {
                row in
                row.title = "Custom Location"
                row.hidden = .function([tagLocation]) {
                    form in
                    let locationRow: PushRow<String> = form.rowBy(tag: tagLocation)!
                    return locationRow.value != "Custom"
                }
        }
        
            +++ SegmentedRow<String>(tagInOrOut) {
                row in
                row.options = ["In", "Out"]
                row.value = "Out"
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
            let present = CoreDataHelper.hasPersonCompletedEntry(person: person, isVisitor: false)
            form.allSections.last! <<< CheckRow("\(tagPerson)_\(person)") {
                row in
                row.title = person
                row.value = false
                row.hidden = .function([tagInOrOut]) {
                    form in
                    let inOrOutRow: SegmentedRow<String> = form.rowBy(tag: tagInOrOut)!
                    if present == nil {
                        return true
                    }
                    
                    if inOrOutRow.value == "In" && !present! {
                        return false
                    }
                    
                    if inOrOutRow.value == "Out" && present! {
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
            let alert = SCLAlertView(appearance: SCLAlertView.SCLAppearance(showCloseButton:false))
            alert.addButton("OK", action: {})
            alert.showError("Error", subTitle: msg)
        }
        
        let values = form.values(includeHidden: false)
        let location = (values[tagLocation] as? String == "Custom" ? values[tagCustomLocation] : values[tagLocation]) as? String
        let inOrOut = values[tagInOrOut] as! String
        guard (location != nil && location!.trimmed() != "") || inOrOut == "In" else {
            showErrorMessage("Please select a location!")
            return
        }
        
        var selectedPeople = [String]()
        for person in people {
            if let selected = values["\(tagPerson)_\(person)"] as? Bool {
                if selected {
                    selectedPeople.append(person)
                }
            }
        }
        
        if selectedPeople.isEmpty {
            showErrorMessage("Please select a person!")
            return
        }
        
        for person in selectedPeople {
            if inOrOut == "Out" {
                _ = Entry(entity: NSEntityDescription.entity(forEntityName: "Entry", in: CoreDataHelper.context)!, insertInto: CoreDataHelper.context, name: person, secondaryItem: location!)
                try? CoreDataHelper.context.save()
            } else {
                let entry = (CoreDataHelper.entriesToday.filter { $0.name == person }).sorted(by: { ($0.0.time1 as! Date) < ($0.1.time1 as! Date) } ).last!
                entry.time2 = NSDate()
                try? CoreDataHelper.context.save()
            }
        }
        
        performSegue(withIdentifier: "signInOut", sender: self)
    }
}
