//
//  SessionTracker.swift
//  Running tracker
//
//  Created by Ivan Murashov on 24.03.20.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import CoreLocation

class SessionTracker: NSObject {
    
    func startNewSession(
        locationManager: CLLocationManager,
        onProgressUpdated: () -> Void,
        onSessionFinished: () -> Void
    ) {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
}

extension SessionTracker : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
