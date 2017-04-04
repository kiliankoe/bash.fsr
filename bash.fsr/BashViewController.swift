//
//  MasterViewController.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 27/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class BashViewController: UITableViewController {

	var quotes = [Quote]()

	override func viewDidLoad() {
		super.viewDidLoad()

		let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: "addQuote")
		navigationItem.rightBarButtonItem = addButton
		
		let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: "updateQuotes")
		navigationItem.leftBarButtonItem = refreshButton
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "updateQuotes", for: .valueChanged)
		
		updateQuotes()
	}

	func addQuote() {
		performSegue(withIdentifier: "showAddQuote", sender: nil)
	}
	
	func updateQuotes() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		quotes = Bash.getLatest()
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
		self.refreshControl?.endRefreshing()
		tableView.reloadData()
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let quote = quotes[indexPath.row]
				let dest = segue.destination as! QuoteViewController
				dest.detailItem = quote
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return quotes.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath) as! QuoteCell
		let quote = quotes[indexPath.row]
		cell.quote = quote
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	// MARK: - Swipe Stuff
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		
	}
	
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let upvote = UITableViewRowAction(style: .normal, title: " 👍 ") { [unowned self] action, index in
			let quote = (self.tableView.cellForRow(at: indexPath) as! QuoteCell).quote!
			Bash.voteQuote(quote.id, type: .Up, completion: { [unowned self] (result) -> Void in
				if result {
					self.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nop", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			})
		}
		upvote.backgroundColor = UIColor(hex: 0x27AE60)
		
		let downvote = UITableViewRowAction(style: .normal, title: " 👎 ") { [unowned self] (action, index) -> Void in
			let quote = (self.tableView.cellForRow(at: indexPath) as! QuoteCell).quote!
			Bash.voteQuote(quote.id, type: .Down, completion: { [unowned self] (result) -> Void in
				if result {
					self.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nop", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
					self.present(alert, animated: true, completion: nil)
				}
			})
		}
		downvote.backgroundColor = UIColor(hex: 0x7F8C8D)
		
		return [upvote, downvote]
	}
}
