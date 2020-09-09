import UIKit
import Vision
import VisionKit
class PaymentsCardCheckViewController: UIViewController {
  var spinner = SpinnerViewController()
  var isShowDocumentScan: Bool = false{
    didSet {
      if (isShowDocumentScan) {
        presentDocumentScanController()
      }
    }
  }
  typealias ConfirmHandler = (Codable) -> Void
  var confirmHanler: ConfirmHandler?
  var textRecognitionRequest: VNRecognizeTextRequest = {
    let vnTextRequest = VNRecognizeTextRequest()
    vnTextRequest.recognitionLevel = .accurate
    vnTextRequest.usesLanguageCorrection = true
    return vnTextRequest
  }()
  var paymentsCardEngine =  PaymentsCardEngine()
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  func presentDocumentScanController() {
    executeTextRecognitionRequest()
    let documentCameraViewController = VNDocumentCameraViewController()
    documentCameraViewController.delegate = self
    present(documentCameraViewController, animated: true)
  }
  fileprivate func stopSpinner() {
    spinner.willMove(toParent: nil)
    spinner.view.removeFromSuperview()
    spinner.removeFromParent()
  }
  
  func createSpinnerView() {
    spinner = SpinnerViewController()
    addChild(spinner)
    spinner.view.frame = view.frame
    view.addSubview(spinner.view)
    spinner.didMove(toParent: self)
  }
  func executeTextRecognitionRequest() {
    textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
      if let results = request.results, !results.isEmpty {
        if let requestResults = request.results as? [VNRecognizedTextObservation] {
          DispatchQueue.main.async {
            let maximumCandidates = 1
            var cardDetails = CardDetails()
            for observation in requestResults {
              guard let candidate = observation.topCandidates(maximumCandidates).first else { continue } // goes to next iteration
              if let predictionTuple = self.paymentsCardEngine.parseNormalisedCoordinates(boundingBox: observation.boundingBox, with: candidate.string) {
                print("prediction", predictionTuple.0, predictionTuple.1)
                cardDetails[String(describing: predictionTuple.0)] = predictionTuple.1
              }
            }
            print("card details", cardDetails)
            self.stopSpinner()
            self.isShowDocumentScan = false
            if ((cardDetails.cardName != nil) && (cardDetails.cardNumber != nil)) {
              self.showAlert(card: cardDetails)
            } else {
              self.dismiss(animated: true, completion: nil)
            }
          }
        }
      }
    })
  }
  func showAlert(card: CardDetails) {
    let alert = UIAlertController(title: "Card Details", message: "Card Number : \(String(describing: card.cardNumber ?? ""))\n Card Name: \(String(describing: card.cardName ?? ""))", preferredStyle: .actionSheet)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{ (UIAlertAction)in
      self.confirmHanler?(card)
    }))
    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler:{ (UIAlertAction)in
      alert.dismiss(animated: true, completion: nil)
    }))
    self.dismiss(animated: true) {
      UIApplication.shared.keyWindow!.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
  }
  func processImage(image: UIImage) {
    guard let cgImage = image.cgImage else {
      print("Failed to get cgimage from input image")
      return
    }
    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
      try handler.perform([textRecognitionRequest])
    } catch {
      print(error)
    }
  }
}
extension PaymentsCardCheckViewController: VNDocumentCameraViewControllerDelegate {
  func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
    controller.dismiss(animated: true) {
      self.createSpinnerView()
      DispatchQueue.global(qos: .userInitiated).async {
        for pageNumber in 0 ..< scan.pageCount {
          let image = scan.imageOfPage(at: pageNumber)
          self.processImage(image: image)
        }
      }
    }
  }
  func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
    controller.dismiss(animated: true)
    self.dismiss(animated: true, completion: nil)
  }
}
