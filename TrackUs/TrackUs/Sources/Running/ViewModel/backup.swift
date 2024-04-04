//func play() {
//    self.startDate = Date()
//    self.isPause = false
//    self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
//        guard let self = self else { return }
//        seconds += 1
//    })
//    
//    guard let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning),
//    let activityEnergyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
//    else {
//        return
//    }
//    
//    // 거리변화 감지시 호출됨
//    observeQuery = HKObserverQuery(sampleType: distanceType, predicate: nil) { (query, completionHandler, error) in
//        if let error = error {
//            debugPrint(#function + " HKObserverQuery " + error.localizedDescription)
//        }
//    
//       let predicate = HKQuery.predicateForSamples(withStart: self.startDate, end: Date(), options: .strictEndDate)
//       
//       
//       let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .mostRecent) { (query, result, error) in
//           if let error = error {
//               debugPrint(#function + " distanceWalkingRunning " + error.localizedDescription)
//           }
//           guard let result = result, let sample = result.mostRecentQuantity() else {
//               return
//           }
//           
//           DispatchQueue.main.async {
//               self.distance += sample.doubleValue(for: .meter())
//           }
//       }
//        
//        let activityEnergyQuery = HKStatisticsQuery(quantityType: activityEnergyType, quantitySamplePredicate: predicate, options: .mostRecent) { (query, result, error) in
//            if let error = error {
//                debugPrint(#function + " activeEnergyBurned " + error.localizedDescription)
//            }
//            guard let result = result, let sample = result.mostRecentQuantity() else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self.calorie += sample.doubleValue(for: .kilocalorie())
//            }
//        }
//       
//       self.healthStore.execute(distanceQuery)
//       self.healthStore.execute(activityEnergyQuery)
//       completionHandler()
//    }
//    
//    healthStore.execute(observeQuery)
//}
