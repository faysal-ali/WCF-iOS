
import Foundation
import FBSDKCoreKit

class ProfileDataSource {
  var profile: Profile?

  func updateProfile(completion: @escaping SuccessBlock) {
    let request = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name"])
    let _ = request?.start(completionHandler: { [weak self] (_, result: Any?, error: Error?) in
      guard
        error == nil,
        let result = result as? [String: Any],
        let name = result["name"] as? String
        else {
          completion(false)
          return
      }

      // TODO(compnerd) fetch this from our dasta source
      self?.profile = Profile(name: name, team: "Team Name")
      onMain {
        completion(true)
      }
    })
  }
}
