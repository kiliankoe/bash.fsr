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

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
		self.navigationItem.rightBarButtonItem = addButton
		
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updateQuotes))
		self.navigationItem.leftBarButtonItem = refreshButton

        let titleButton = UIButton()
        titleButton.titleLabel?.text = "bash.fsr"
        titleButton.setTitle("bash.fsr", for: .normal)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.setTitleShadowColor(.black, for: .normal)
        titleButton.addTarget(self, action: #selector(onTitleButtonTap), for: .touchUpInside)
        self.navigationItem.titleView = titleButton
		
		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(updateQuotes), for: .valueChanged)
		
		updateQuotes()
	}

    func onTitleButtonTap() {
        let sharingItems: [Any] = [pushtoken]
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

	func addQuote() {
		performSegue(withIdentifier: "showAddQuote", sender: nil)
	}
	
	func updateQuotes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Bash.getLatest { [weak self] quotes in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.refreshControl?.endRefreshing()

                guard let quotes = quotes else { return }

                self?.quotes = quotes
                self?.tableView.reloadData()
            }
        }
	}

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let quote = quotes[indexPath.row]
				let dest = segue.destination as? QuoteViewController
				dest?.quote = quote
		    }
		}
	}

	// MARK: - Table View

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return quotes.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: QuoteCell.self), for: indexPath) as? QuoteCell ?? QuoteCell()
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
        let quote = self.quotes[indexPath.row]

		let upvote = UITableViewRowAction(style: .normal, title: " 👍 ") { [weak self] _, _ in
            guard !quote.isAlreadyVoted else {
                let alert = UIAlertController(title: "Nope", message: "You already voted this one, chill!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }

			Bash.voteQuote(quote.id, type: .up, completion: { result in
				if result {
					self?.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nope", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
			})
		}
		upvote.backgroundColor = UIColor(hex: 0x27AE60)
		
		let downvote = UITableViewRowAction(style: .normal, title: " 👎 ") { [weak self] _, _ in
            guard !quote.isAlreadyVoted else {
                let alert = UIAlertController(title: "Nope", message: "You already voted this one, chill!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }

			Bash.voteQuote(quote.id, type: .down, completion: { result in
				if result {
					self?.updateQuotes()
				} else {
					let alert = UIAlertController(title: "Nope", message: "Vote failed!", preferredStyle: UIAlertControllerStyle.alert)
					alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
			})
		}
		downvote.backgroundColor = UIColor(hex: 0x7F8C8D)
		
		return [upvote, downvote]
	}
}
