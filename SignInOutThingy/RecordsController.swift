import UIKit

class RecordsController: UITableViewController {
    
    @IBAction func signInOutBtnPressed(sender: AnyObject) {
        performSegue(withIdentifier: "signInOut", sender: self)
    }
}

