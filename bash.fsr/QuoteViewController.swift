//
//  DetailViewController.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 27/09/15.
//  Copyright © 2015 Kilian Koeltzsch. All rights reserved.
//

import UIKit

class QuoteViewController: UIViewController {

	@IBOutlet weak var detailDescriptionLabel: UILabel?

    @IBOutlet weak var downvoteButton: UIButton?
    @IBOutlet weak var upvoteButton: UIButton?

    weak var bashVC: BashViewController?

	var quote: Quote?

	func configureView() {
        guard let quote = self.quote else { return }
        detailDescriptionLabel?.text = quote.quote
        navigationItem.title = "#\(quote.id)"

        setButtonStates(to: !quote.isAlreadyVoted)
	}

    func setButtonStates(to: Bool) {
        downvoteButton?.isEnabled = to
        downvoteButton?.isHighlighted = !to // FIXME: Why isn't this working?
        upvoteButton?.isEnabled = to
        upvoteButton?.isHighlighted = !to

        if to {
            downvoteButton?.backgroundColor = UIColor(hex: 0x7F8C8D)
            upvoteButton?.backgroundColor = UIColor(hex: 0x27AE60)
        } else {
            downvoteButton?.backgroundColor = UIColor(hex: 0xABABAB)
            upvoteButton?.backgroundColor = UIColor(hex: 0xABABAB)
        }
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		self.configureView()
	}

    @IBAction func onShareButtonTap(_ sender: UIBarButtonItem) {
        guard let quoteId = quote?.id else { return }
        let sharingItems = ["\(BaseBashURL)/?\(quoteId)"]
        let activityController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.present(activityController, animated: true, completion: nil)
    }

    @IBAction func onVoteButtonTap(_ sender: UIButton) {
        let action: Vote
        if sender.titleLabel?.text == "👎" {
            action = .down
        } else {
            action = .up
        }

        guard let quote = quote else { return }

        Bash.voteQuote(quote.id, type: action) { _ in
            OperationQueue.main.addOperation {
                self.setButtonStates(to: false)
                self.bashVC?.setQuoteVoted(withId: quote.id, andAction: action)
            }
        }
    }
}
