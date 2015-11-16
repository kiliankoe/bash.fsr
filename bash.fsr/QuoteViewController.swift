//
//  DetailViewController.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 27/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {

	@IBOutlet weak var detailDescriptionLabel: UILabel?


	var detailItem: Quote? {
		didSet {
		    // Update the view.
		    self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let quote = self.detailItem {
			detailDescriptionLabel?.text = quote.quote
			navigationItem.title = "#\(quote.id)"
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

}
