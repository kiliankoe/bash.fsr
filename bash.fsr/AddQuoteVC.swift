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
        activityButton = UIBarButtonItem(customView: activityIndicator)
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddQuoteVC.addQuote))
        
        navigationItem.rightBarButtonItem = doneButton

		automaticallyAdjustsScrollViewInsets = false
        textView?.becomeFirstResponder()
    }
	
	func addQuote() {
		let quote = textView?.text
		guard quote != "" else {
			let alert = UIAlertController(title: "Nop", message: "Quote is empty! Try again...", preferredStyle: UIAlertControllerStyle.alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
			self.present(alert, animated: true, completion: nil)
			return
		}

        self.navigationItem.rightBarButtonItem = self.activityButton

		Bash.addQuote(quote!) { [unowned self] (success) -> Void in
			if success {
				self.navigationController?.popViewController(animated: true)
				let appDelegate = UIApplication.shared.delegate as? AppDelegate
				let mainVC = appDelegate?.window?.rootViewController?.childViewControllers[0] as? BashViewController
				mainVC?.updateQuotes()
			} else {
				let alert = UIAlertController(title: "Nop", message: "Submit failed!", preferredStyle: UIAlertControllerStyle.alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
				self.present(alert, animated: true, completion: nil)
                self.navigationItem.rightBarButtonItem = self.doneButton
			}
		}
	}

}
