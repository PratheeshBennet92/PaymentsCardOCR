import Foundation
struct CardDetails: Codable {
  var cardNumber: String?
  var cardName: String?
  var cardExpiry: String?
  subscript(key: String) -> String? {
    get {
      switch key {
      case "cardNumber": return self.cardNumber
      case "cardName": return self.cardName
      case "cardExpiry": return self.cardExpiry
      default: fatalError("Invalid key")
      }
    }
    set {
      switch key {
      case "cardNumber": self.cardNumber = newValue
      case "cardName": self.cardName = newValue
      case "cardExpiry": self.cardExpiry = newValue
      default: fatalError("Invalid key")
      }
    }
  }
}
