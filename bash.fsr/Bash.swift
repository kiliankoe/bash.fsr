//
//  Bash.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 28/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Alamofire
import Ji

extension String {
	func trim() -> String {
		return self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
	}
}

struct Quote {
	let id: Int
	let rating: Int
	let quote: String
	let isAlreadyVoted: Bool
}

enum Vote: String {
	case Up = "plus"
	case Down = "minus"
}

class Bash {
	static func getLatest() -> [Quote] {
		let document = Ji(contentsOfURL: BashConfig.URL, encoding: NSUTF8StringEncoding, isXML: false)
		let quotes = document?.xPath("//div[@class='quote_whole']")
		
		var latest_quotes = [Quote]()
		
		if let quotes = quotes {
			for quote in quotes {
				let id = Int((quote.xPath("div[@class='quote_option-bar']/a").first?.content?.stringByReplacingOccurrencesOfString("#", withString: ""))!)
				let rating = quote.xPath("div[@class='quote_option-bar']/span[@class='quote_rating']/span").first?.content
				let text = quote.xPath("div[@class='quote_quote']").first?.content?.trim()
				
				var isAlreadyVoted: Bool
				if quote.xPath("div[@class='quote_option-bar']/span[@class='quote_plus']/@title").first?.content == "You have already voted this quote" {
					isAlreadyVoted = true
				} else {
					isAlreadyVoted = false
				}
				
				let quote = Quote(id: id!, rating: Int(rating!)!, quote: text!, isAlreadyVoted: isAlreadyVoted)
				latest_quotes.append(quote)
			}
		}
		
		return latest_quotes
	}
	
	
	static func addQuote(quote: String, completion: (Bool -> Void)) {
		let manager = Manager.sharedInstance
		manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
		let bodyParameters = ["rash_quote": quote]
		manager.request(.POST, BashConfig.submitURL, parameters: bodyParameters).response { (req, res, _, _) -> Void in
			if res?.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}
	}
	
	static func voteQuote(id: Int, type: Vote, completion: (Bool -> Void)) {
		Alamofire.request(.GET, BashConfig.voteURL(id, type: type)).response { (_, res, _, _) -> Void in
			if res?.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}
	}
}
