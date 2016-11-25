import Eureka
import CoreData

class SignInOutFormController: FormViewController {
    let people = ["Narek", "Jack", "Jeremy", "David"]
    @IBOutlet var signInOutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ PickerInlineRow<String>(tagLocation) {
            row in
            row.title = "Location"
            row.options = ["Location 1", "Location 2", "Location 3", "Custom"]
        }
        
            <<< TextRow(tagCustomLocation) {
                row in
                row.title = "Custom Location"
                row.hidden = .function([tagLocation]) {
                    form in
                    let locationRow: PickerInlineRow<String> = form.rowBy(tag: tagLocation)!
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
            let present = CoreDataHelper.hasPersonCompletedEntry(person: person)
            form.allSections.last! <<< CheckRow("\(tagPerson)_\(person)") {
                row in
                row.title = person
                row.value = false
                row.hidden = .function([tagInOrOut]) {
                    form in
                    let inOrOutRow: SegmentedRow<String> = form.rowBy(tag: tagInOrOut)!
                    if inOrOutRow.value == "In" && !present {
                        return false
                    }
                    
                    if inOrOutRow.value == "Out" && present {
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
}
