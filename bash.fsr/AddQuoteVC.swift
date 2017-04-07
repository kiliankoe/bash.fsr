//
//  AddQuoteVC.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 16/11/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class AddQuoteVC: UIViewController {

	@IBOutlet weak var textView: UITextView?
	
	var activityButton: UIBarButtonItem?
    var doneButton: UIBarButtonItem?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        activityIndicator.color = UIColor.black
        activityIndicator.startAnimating()
        self.activityButton = UIBarButtonItem(customView: activityIndicator)
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddQuoteVC.addQuote))
        
        self.navigationItem.rightBarButtonItem = doneButton

		self.automaticallyAdjustsScrollViewInsets = false
        self.textView?.becomeFirstResponder()
    }
	
	func addQuote() {
		guard
            let quote = self.textView?.text,
            quote != ""
        else {
			let alert = UIAlertController(title: "Nop", message: "Quote is empty! Try again...", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}

        self.navigationItem.rightBarButtonItem = self.activityButton

		Bash.addQuote(quote) { [weak self] (success) -> Void in
            OperationQueue.main.addOperation {
                if success {
                    self?.navigationController?.popViewController(animated: true)
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let mainVC = appDelegate?.window?.rootViewController?.childViewControllers[0] as? BashViewController
                    mainVC?.updateQuotes()
                } else {
                    let alert = UIAlertController(title: "Nop", message: "Submit failed!", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                    self?.navigationItem.rightBarButtonItem = self?.doneButton
                }
            }
		}
	}

}
