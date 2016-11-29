import UIKit
import Eureka

class OptionsFormController: FormViewController {
    @IBAction func done(_ sender: Any) {
        let values = form.values()
        UserDefaults.standard.set(values[tagNameList]!, forKey: tagNameList)
        UserDefaults.standard.set(values[tagLocationList]!, forKey: tagLocationList)
        dismissVC(completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ TextAreaRow(tagNameList) {
            row in
            row.placeholder = "Name List"
            row.value = UserDefaults.standard.string(forKey: tagNameList) ?? ""
        }
        
        form +++ TextAreaRow(tagLocationList) {
            row in
            row.placeholder = "Location List"
            row.value = UserDefaults.standard.string(forKey: tagLocationList) ?? ""
        }
    }

}
