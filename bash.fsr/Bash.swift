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
		return self.trimmingCharacters(in: .whitespacesAndNewlines)
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
		let url = URL(string: BashURL + "?latest")!
		let document = Ji(contentsOfURL: url, encoding: String.Encoding.utf8, isXML: false) // FIXME: Ugh, synchronous >.<
		let quotes = document?.xPath("//div[@class='quote_whole']")
		
		var latest_quotes = [Quote]()
		
		if let quotes = quotes {
			for quote in quotes {
                let id = Int((quote.xPath("div[@class='quote_option-bar']/a").first?.content?.replacingOccurrences(of: "#", with: ""))!)
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
	
	
	static func addQuote(_ quote: String, completion: ((Bool) -> Void)) {
		let manager = Manager.sharedInstance
		manager.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-www-form-urlencoded"]
		let bodyParameters = ["rash_quote": quote]
		manager.request(.POST, BashURL + "?add&submit", parameters: bodyParameters).response { (_, res, _, _) -> Void in
			if res?.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}
	}
	
	static func voteQuote(_ id: Int, type: Vote, completion: ((Bool) -> Void)) {
		let url = BashURL + "/index.php?ajaxvote&\(id)&\(type.rawValue)"
		Alamofire.request(.GET, url).response { (_, res, _, _) -> Void in
			if res?.statusCode == 200 {
				completion(true)
			} else {
				completion(false)
			}
		}
	}
}
