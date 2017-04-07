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
    var showLatest = true

    @IBOutlet weak var titleButton: UIButton!

	override func viewDidLoad() {
		super.viewDidLoad()

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addQuote))
		self.navigationItem.rightBarButtonItem = addButton
		
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareToken))
		self.navigationItem.leftBarButtonItem = shareButton

        let title = showLatest ? "Latest" : "Random"
        self.titleButton.setTitle(title, for: .normal)

		self.refreshControl = UIRefreshControl()
		self.refreshControl?.addTarget(self, action: #selector(updateQuotes), for: .valueChanged)
		
		updateQuotes()
	}

    func shareToken() {
        let sharingItems: [Any] = [pushtoken]
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    @IBAction func onTitleButtonTap(_ sender: UIButton) {
        self.showLatest = !self.showLatest
        let title = showLatest ? "Latest" : "Random"
        self.titleButton.setTitle(title, for: .normal)
        self.updateQuotes()
    }

	func addQuote() {
		performSegue(withIdentifier: "showAddQuote", sender: nil)
	}
	
	func updateQuotes() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Bash.get(latest: showLatest) { [weak self] quotes in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self?.refreshControl?.endRefreshing()

                guard let quotes = quotes else { return }

                self?.quotes = quotes
                self?.tableView.reloadData()
            }
        }
	}

    func setQuoteVoted(withId id: Int, andAction action: Vote) {
        let ratingDiff = action == .up ? 1 : -1
        let oldQuoteIdx = self.quotes.index { $0.id == id }
        guard let idx = oldQuoteIdx else { return }

        let oldQuote = self.quotes[idx]
        let newQuote = Quote(id: id, rating: oldQuote.rating + ratingDiff, quote: oldQuote.quote, isAlreadyVoted: true)

        self.quotes.remove(at: idx)
        self.quotes.insert(newQuote, at: idx)
        self.tableView.reloadData()
    }

	// MARK: - Segues

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "showDetail" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
		        let quote = quotes[indexPath.row]
				let dest = segue.destination as? QuoteViewController
				dest?.quote = quote
                dest?.bashVC = self
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

    // MARK: - Shaking Stuff

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if event?.subtype == .motionShake {
            self.performSegue(withIdentifier: "showCardView", sender: self)
        }
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
                    let newQuote = Quote(id: quote.id, rating: quote.rating + 1, quote: quote.quote, isAlreadyVoted: true)
                    self?.quotes.remove(at: indexPath.row)
                    self?.quotes.insert(newQuote, at: indexPath.row)
                    OperationQueue.main.addOperation {
                        self?.tableView.reloadData()
                    }
				} else {
					let alert = UIAlertController(title: "Nope", message: "Vote failed!", preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
					self?.present(alert, animated: true, completion: nil)
				}
			})
		}
		upvote.backgroundColor = UIColor(hex: 0x27AE60)
		
		let downvote = UITableViewRowAction(style: .normal, title: " 👎 ") { [weak self] _, _ in
            guard !quote.isAlreadyVoted else {
                let alert = UIAlertController(title: "Nope", message: "You already voted this one, chill!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
                return
            }

			Bash.voteQuote(quote.id, type: .down, completion: { result in
				if result {
                    let newQuote = Quote(id: quote.id, rating: quote.rating - 1, quote: quote.quote, isAlreadyVoted: true)
                    self?.quotes.remove(at: indexPath.row)
                    self?.quotes.insert(newQuote, at: indexPath.row)
                    OperationQueue.main.addOperation {
                        self?.tableView.reloadData()
                    }
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
