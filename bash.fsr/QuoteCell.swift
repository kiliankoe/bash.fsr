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
				idLabel?.text = "#\(quote.id)"
				ratingLabel?.text = quote.rating > 0 ? "+\(quote.rating)" : "\(quote.rating)"
				quoteLabel?.text = quote.quote
				
				if quote.isAlreadyVoted {
					backgroundColor = UIColor(hex: 0xECF0F1)
					mainTextColor = UIColor.black
				} else {
					backgroundColor = UIColor(hex: 0x34495E)
					mainTextColor = UIColor.white
				}
			}
		}
	}
	
	var mainTextColor: UIColor? {
		didSet {
			idLabel?.textColor = mainTextColor
			ratingLabel?.textColor = mainTextColor
			quoteLabel?.textColor = mainTextColor
		}
	}
	
	@IBOutlet weak var idLabel: UILabel?
	@IBOutlet weak var ratingLabel: UILabel?
	@IBOutlet weak var quoteLabel: UILabel?
}
