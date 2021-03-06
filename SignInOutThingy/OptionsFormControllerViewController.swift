import UIKit
import Eureka

class OptionsFormController: FormViewController {
    @IBAction func done(_ sender: Any) {
        let values = form.values()
        UserDefaults.standard.set(values[tagNameList]!, forKey: tagNameList)
        UserDefaults.standard.set(values[tagLocationList]!, forKey: tagLocationList)
        UserDefaults.standard.set(values[tagOnlyShowIncompleteEntries]!, forKey: tagOnlyShowIncompleteEntries)
        performSegue(withIdentifier: "unwindFromOptions", sender: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(header: "name list", footer: "Enter all the people's names, one name per line")
        <<< TextAreaRow(tagNameList) {
            row in
            row.value = UserDefaults.standard.string(forKey: tagNameList) ?? ""
            row.cell.height = { 200 }
        }
        
        form +++ Section(header: "location list", footer: "Enter all the preset locations, one location per line")
        <<< TextAreaRow(tagLocationList) {
            row in
            row.value = UserDefaults.standard.string(forKey: tagLocationList) ?? ""
            row.cell.height = { 200 }
        }
        
        form +++ SwitchRow(tagOnlyShowIncompleteEntries) {
            row in
            row.title = "Only Show Incomplete Entries"
            row.value = UserDefaults.standard.bool(forKey: tagOnlyShowIncompleteEntries)
            }
    }

}
