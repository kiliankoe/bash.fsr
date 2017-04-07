//
//  QuoteCardController.swift
//  bash.fsr
//
//  Created by Kilian Költzsch on 06.04.17.
//  Copyright © 2017 Kilian Koeltzsch. All rights reserved.
//

import UIKit
import Koloda

class QuoteCardController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView?

    override func viewDidLoad() {
        super.viewDidLoad()

        kolodaView?.dataSource = self
        kolodaView?.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QuoteCardController: KolodaViewDataSource {
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 1
    }

    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIView()
    }
}

extension QuoteCardController: KolodaViewDelegate {

}
