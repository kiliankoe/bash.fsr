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

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addQuote")
		navigationItem.rightBarButtonItem = addButton
		
		let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: "updateQuotes")
		navigationItem.leftBarButtonItem = refreshButton
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: "updateQuotes", forControlEvents: .ValueChanged)
		
		updateQuotes()
	}

	func addQuote() {
		performSegueWithIdentifier("showAddQuote", sender: nil)
	}
	
	func updateQuotes() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		quotes = Bash.getLatest()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		self.refreshControl?.endRefreshing()
		tableView.reloadData()
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let quote = quotes[indexPath.row]
				let dest = segue.destinationViewController as! QuoteViewController
				dest.detailItem = quote
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return quotes.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("QuoteCell", forIndexPath: indexPath) as! QuoteCell
		let quote = quotes[indexPath.row]
		cell.quote = quote
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}
	
	// MARK: - Swipe Stuff
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
		let upvote = UITableViewRowAction(style: .Normal, title: " 👍 ") { [unowned self] action, index in
			let quote = (self.tableView.cellForRowAtIndexPath(indexPath) as! QuoteCell).quote!
			Bash.voteQuote(quote.id, type: .Up, completion: { [unowned self] (result) -> Void in
				if result {
					self.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nop", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.Alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				}
			})
		}
		upvote.backgroundColor = UIColor(hex: 0x27AE60)
		
		let downvote = UITableViewRowAction(style: .Normal, title: " 👎 ") { [unowned self] (action, index) -> Void in
			let quote = (self.tableView.cellForRowAtIndexPath(indexPath) as! QuoteCell).quote!
			Bash.voteQuote(quote.id, type: .Down, completion: { [unowned self] (result) -> Void in
				if result {
					self.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nop", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.Alert)
					alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
					self.presentViewController(alert, animated: true, completion: nil)
				}
			})
		}
		downvote.backgroundColor = UIColor(hex: 0x7F8C8D)
		
		return [upvote, downvote]
	}
}
