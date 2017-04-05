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

	var quote: Quote? {
		didSet {
		    self.configureView()
		}
	}

	func configureView() {
		if let quote = self.quote {
			detailDescriptionLabel?.text = quote.quote
			navigationItem.title = "#\(quote.id)"
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
	}
}
