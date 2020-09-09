//
//  ViewController.swift
//  PaymentsCardReader
//
//  Created by Christina Taflin on 03/09/20.
//  Copyright © 2020 Pratheesh Bennet. All rights reserved.
//

import UIKit
import Vision
import VisionKit
import CoreML
class ViewController: UIViewController {
  @IBOutlet weak var btnScan: UIButton!
  @IBOutlet weak var cardNameTextField: UITextField!
  @IBOutlet weak var cardNumberTextField: UITextField!
  let paymentsCardCheckViewController = PaymentsCardCheckViewController()
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  @IBAction func btnScanTapped(_ sender: Any) {
    self.present(paymentsCardCheckViewController, animated: true, completion: nil)
    paymentsCardCheckViewController.isShowDocumentScan = true
    paymentsCardCheckViewController.confirmHanler = { [weak self] (cardDetails)in
      guard let self = self, let cardInfo = cardDetails as? CardDetails else { return }
      self.cardNumberTextField.text = cardInfo.cardNumber
      self.cardNameTextField.text = cardInfo.cardName
    }
  }
}

