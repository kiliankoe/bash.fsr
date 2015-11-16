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
		
		let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
		if appDelegate.showAddVC {
			performSegueWithIdentifier("showAddQuote", sender: nil)
			appDelegate.showAddVC = false
		}
		
		updateQuotes()
	}

	func addQuote() {
		performSegueWithIdentifier("showAddQuote", sender: nil)
	}
	
	func updateQuotes() {
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		quotes = Bash.getLatest()
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
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
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

		let quote = quotes[indexPath.row]
		cell.textLabel!.text = quote.quote
		cell.detailTextLabel?.text = "\(quote.rating)"
		return cell
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
	}

}
