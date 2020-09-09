import UIKit
import CoreML
enum CardLocationResult: Int {
  case cardNumber = 1
  case cardName = 2
  case cardExpiry = 3
}
class PaymentsCardEngine {
  let model: CardLocation?
  init() {
    model = CardLocation()
  }
  func parseNormalisedCoordinates(boundingBox: CGRect, with value: String) -> (CardLocationResult, String)? {
    var transformedBoundingBox = boundingBox
    transformedBoundingBox.origin.x = transformedBoundingBox.origin.x + transformedBoundingBox.width/2
    transformedBoundingBox.origin.y = 1 - (transformedBoundingBox.origin.y + transformedBoundingBox.height/2)
    guard 0.53...0.9 ~= Double(transformedBoundingBox.origin.y),
      let cardLocationOutput = try? model?.prediction(X: Double(transformedBoundingBox.origin.x) , Y: Double(transformedBoundingBox.origin.y), Width: Double(transformedBoundingBox.width), Height: Double(transformedBoundingBox.height)),
      let predictedKey = CardLocationResult(rawValue: Int(cardLocationOutput.Location.rounded(.toNearestOrAwayFromZero)))
      else {
        return nil
    }
    return (predictedKey, value)
  }
}
