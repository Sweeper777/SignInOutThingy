import UIKit
import BNHtmlPdfKit
import MessageUI
import SwiftyUtils

class ArchiveViewerController: UIViewController, BNHtmlPdfKitDelegate, MFMailComposeViewControllerDelegate, UIPrintInteractionControllerDelegate {
    var entries: [Entry]!
    @IBOutlet var webView: UIWebView!
    var archiveName: String!
    var pdfKit: BNHtmlPdfKit!
    var html: String!
    var pdf: Data!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let css = try! String(contentsOfFile: Bundle.main.path(forResource: "modest", ofType: "css")!)
        archiveName = "Archive: " + formatter.string(from: entries.first!.time1! as Date)
        var html = "<style>\(css)</style><div id=\"main\"><h3>\(archiveName!)</h3><hr>"
        for entry in entries {
            html += "\(entry.description)<hr>"
        }
        html += "</div>"
        webView.loadHTMLString(html, baseURL: nil)
        self.html = html
        
        pdfKit = BNHtmlPdfKit()
        pdfKit.delegate = self
        pdfKit.saveHtml(asPdf: html)
    }
    
    @IBAction func print(_ sender: Any) {
        guard let pdf = self.pdf else {
            let alert = UIAlertController(title: "Error", message: "The PDF file is still being generated. Please wait.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        let printController = UIPrintInteractionController.shared
        printController.delegate = self
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = archiveName
        printController.printInfo = printInfo
//
//        let formatter = webView.viewPrintFormatter()
//
//        formatter.perPageContentInsets = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)
        printController.printingItem = pdf
        
        (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = UIColor(hex: "5abb5a")
        printController.present(animated: true, completionHandler: nil)
    }
    
    @IBAction func mail(_ sender: Any) {
        guard let pdf = self.pdf else {
            let alert = UIAlertController(title: "Error", message: "The PDF file is still being generated. Please wait.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        
        if( MFMailComposeViewController.canSendMail() ) {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.modalPresentationStyle = .formSheet
            mailComposer.addAttachmentData(pdf, mimeType: "application/pdf", fileName: archiveName)
            self.present(mailComposer, animated: true)
        } else {
            let alert = UIAlertController(title: "Error", message: "Your mail accounts might not be set up.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func htmlPdfKit(_ htmlPdfKit: BNHtmlPdfKit!, didSavePdfData data: Data!) {
        self.pdf = data
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func printInteractionControllerDidDismissPrinterOptions(_ printInteractionController: UIPrintInteractionController) {
        (UIApplication.shared.delegate as! AppDelegate).window?.tintColor = UIColor(hex: "3b7b3b")
    }
    
}
