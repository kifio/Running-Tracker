//
//  StartSessionUseCase.swift
//  Running tracker
//
//  Created by Ivan Murashov on 25.03.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import CoreLocation

class StartSessionUseCase: NSObject {
    
    private let locationManager = CLLocationManager()
    private let sessionTracker = SessionTracker()
    
    func startSession(onLocationDenied: () -> Void,
                      onSessionStarted: () -> Void,
                      onProgressUpdated: () -> Void,
                      onSessionFinished: () -> Void
    ) {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied, .restricted:
            onLocationDenied()
            return
        case .authorizedAlways, .authorizedWhenInUse:
            self.sessionTracker.startNewSession(
                onProgressUpdated,
                onSessionFinished
            )
            onSessionStarted()
            break
        }
    }    
}
