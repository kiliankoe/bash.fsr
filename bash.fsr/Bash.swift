//
//  Bash.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 28/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
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
	
	
	static func addQuote(_ quote: String, completion: @escaping (Bool) -> Void) {
        var request = URLRequest(url: URL(string: BashURL + "?add&submit")!)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        let params = ["rash_quote": quote]
        guard let body = try? JSONSerialization.data(withJSONObject: params) else { // TODO: Check if this works
            completion(false)
            return
        }
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard
                error == nil,
                let res = response as? HTTPURLResponse,
                res.statusCode == 200
            else {
                completion(false)
                return
            }

            completion(true)
        }.resume()
	}
	
    static func voteQuote(_ id: Int, type: Vote, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: BashURL + "/index.php?ajaxvote&\(id)&\(type.rawValue)") else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { _, response, error in
            guard
                error == nil,
                let res = response as? HTTPURLResponse,
                res.statusCode == 200
            else {
                completion(false)
                return
            }

            completion(true)
        }.resume()
	}
}
