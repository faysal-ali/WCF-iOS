
import Foundation

import HealthKit

protocol DataProvider {
  typealias StepCountCallback = (_ steps: Int) -> Void
  func retrieveStepCountForDateRange(_ interval : DateInterval,
                                     _ completion : @escaping StepCountCallback)
}

class HealthKitDataProvider : DataProvider {
  let store = HKHealthStore()
  
  func retrieveStepCountForDateRange(_ interval : DateInterval,
                                     _ completion: @escaping StepCountCallback) {
    guard
      let stepCount = HKSampleType.quantityType(forIdentifier: .stepCount)
    else { return }

    if store.authorizationStatus(for: stepCount) == .sharingAuthorized {
      query(sampleType: stepCount, interval: interval, completion: completion)
    } else {
      store.requestAuthorization(toShare: nil, read: [stepCount]) {
        [weak self] (success: Bool, error: Error?) in
        guard error == nil && success else {
          print("Error getting HealthKit access: \(String(describing: error))")
          return
        }
        self?.query(sampleType: stepCount, interval: interval,
                    completion: completion)
      }
    }
  }
    
  private func query(sampleType: HKSampleType, interval: DateInterval,
                     completion: @escaping StepCountCallback) {
    let predicate = HKQuery.predicateForSamples(withStart: interval.start,
                                                end: interval.end, options: [])
    let query = HKSampleQuery(sampleType: sampleType, predicate: predicate,
                              limit: 0, sortDescriptors: nil) {
      (query, results, error) in
      var steps = 0.0
      if let count = results?.count {
        if count > 0 {
          for result in results as! [HKQuantitySample] {
            steps = steps + result.quantity.doubleValue(for: .count())
          }
        }
      }
      completion(Int(steps))
    }
    self.store.execute(query)
  }
}

class ProfileDataSource {
  var realName: String = ""
  var teamName: String = ""
  var dataProvider: DataProvider? = nil

  init() {
    switch Preferences.instance.device {
    case .None:
      break
    case .HealthKit:
      dataProvider = HealthKitDataProvider()
      break
    }
  }

  func updateProfile(completion: @escaping SuccessBlock) {
    // TODO(compnerd) fetch this from our backend
    self.teamName = "Team Name"

    Facebook.getRealName { [weak self] (name) in
      guard name != nil else { return }
      self?.realName = name!

      onMain {
        completion(true)
      }
    }
  }
}

