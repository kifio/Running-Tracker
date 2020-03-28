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
    
    func startSession(
        sessionId: Int,
        locationManager: CLLocationManager,
        onLocationStatusNotDetermined: @escaping () -> Void,
        onLocationDenied: @escaping () -> Void,
        onSessionStarted: @escaping () -> Void,
        onTimeUpdated: @escaping (Int) -> Void,
        onProgressUpdated: @escaping ([CLLocationCoordinate2D]) -> Void
    ) -> SessionTracker? {
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .notDetermined:
            onLocationStatusNotDetermined()
            return nil
        case .denied, .restricted:
            onLocationDenied()
            return nil
        case .authorizedAlways, .authorizedWhenInUse:
            let sessionTracker = SessionTracker()
            sessionTracker.startNewSession(
                sessionId: sessionId,
                locationManager: locationManager,
                onTimeUpdated: onTimeUpdated,
                onProgressUpdated: onProgressUpdated
            )
            onSessionStarted()
            return sessionTracker
        }
    }    
}
