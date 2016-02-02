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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "addQuote")

		automaticallyAdjustsScrollViewInsets = false
        textView?.becomeFirstResponder()
    }
	
	func addQuote() {
        self.navigationItem.rightBarButtonItem!.action = nil
		let quote = textView?.text
		guard quote != "" else {
			let alert = UIAlertController(title: "Nop", message: "Quote is empty! Try again...", preferredStyle: UIAlertControllerStyle.Alert)
			alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
			self.presentViewController(alert, animated: true, completion: nil)
            self.navigationItem.rightBarButtonItem?.action = Selector("addQuote")
			return
		}
		Bash.addQuote(quote!) { [unowned self] (success) -> Void in
			if success {
				self.navigationController?.popViewControllerAnimated(true)
				let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
				let mainVC = appDelegate?.window?.rootViewController?.childViewControllers[0] as? BashViewController
				mainVC?.updateQuotes()
			} else {
				let alert = UIAlertController(title: "Nop", message: "Submit failed!", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
        self.navigationItem.rightBarButtonItem?.action = Selector("addQuote")
	}

}
