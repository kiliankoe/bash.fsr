//
//  Bash.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 28/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Ji

struct Quote {
	let id: Int
	let rating: Int
	let quote: String
	let isAlreadyVoted: Bool
}

enum Bash {
    static func getLatest(completion: @escaping ([Quote]?) -> Void) {
        let url = URL(string: BashURL + "?latest")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                let res = response as? HTTPURLResponse,
                res.statusCode == 200,
                let data = data
            else {
                completion(nil)
                return
            }

            let document = Ji(htmlData: data, encoding: .utf8)
            guard let quotes = document?.xPath("//div[@class='quote_whole']") else {
                completion(nil)
                return
            }

            let latest = quotes.flatMap { quote -> Quote? in
                guard
                    let idStr = quote.xPath("div[@class='quote_option-bar']/a").first?.content?.replacingOccurrences(of: "#", with: ""),
                    let id = Int(idStr),
                    let ratingStr = quote.xPath("div[@class='quote_option-bar']/span[@class='quote_rating']/span").first?.content,
                    let rating = Int(ratingStr),
                    let text = quote.xPath("div[@class='quote_quote']").first?.content?.trimmingCharacters(in: .whitespacesAndNewlines)
                else {
                    return nil
                }

                var isAlreadyVoted: Bool
                if quote.xPath("div[@class='quote_option-bar']/span[@class='quote_plus']/@title").first?.content == "You have already voted this quote" {
                    isAlreadyVoted = true
                } else {
                    isAlreadyVoted = false
                }
                
                return Quote(id: id, rating: rating, quote: text, isAlreadyVoted: isAlreadyVoted)
            }

            completion(latest)
        }.resume()
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

        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        URLSession.shared.dataTask(with: url) { _, response, error in

            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
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
