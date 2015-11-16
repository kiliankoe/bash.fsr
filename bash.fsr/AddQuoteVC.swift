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
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addQuote")

        textView?.becomeFirstResponder()
    }
	
	func addQuote() {
		let quote = textView?.text
		Bash.addQuote(quote!) { [unowned self] (success) -> Void in
			if !success {
				let alert = UIAlertController(title: "Nop", message: "Submit failed!", preferredStyle: UIAlertControllerStyle.Alert)
				alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}

}
