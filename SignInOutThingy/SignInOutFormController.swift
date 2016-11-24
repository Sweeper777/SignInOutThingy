import Eureka

class SignInOutFormController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        form +++ PickerInlineRow<String>(tagLocation) {
            row in
            row.title = "Location"
            row.options = ["Location 1", "Location 2", "Location 3", "Custom"]
            row.value = "Location 1"
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
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
