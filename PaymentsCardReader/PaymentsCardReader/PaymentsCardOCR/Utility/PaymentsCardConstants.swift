import Foundation
extension String {
  func localized(_ comment: String = "") -> String? {
    return NSLocalizedString(self, comment: comment)
  }
}
struct PaymentsCardConstants {
  static var addCardDetails = "Add card details".localized()
  static var cardNoPlaceholder = "16 digit card number".localized()
  static var carndNamePlaceholder = "Account holder's name".localized()
  static var expiryDatePlaceholder = "Expiry".localized()
}
