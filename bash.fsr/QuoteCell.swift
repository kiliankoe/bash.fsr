//
//  QuoteCell.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 16/11/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class QuoteCell: UITableViewCell {
	
	var quote: Quote? {
		didSet {
			if let quote = quote {
				idLabel?.text = quote.id
				ratingLabel?.text = "\(quote.rating)"
				quoteLabel?.text = quote.quote
			}
		}
	}
	
	@IBOutlet weak var idLabel: UILabel?
	@IBOutlet weak var ratingLabel: UILabel?
	@IBOutlet weak var quoteLabel: UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
