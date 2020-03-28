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
    
    private var duration: Int = 0
    private var session: Session?
    private var onProgressUpdated: (([CLLocationCoordinate2D]) -> Void)?

    func startNewSession(
        sessionId: Int,
        locationManager: CLLocationManager,
        onTimeUpdated: @escaping (Int) -> Void,
        onProgressUpdated: @escaping ([CLLocationCoordinate2D]) -> Void
    ) {
        self.session = Session(id: sessionId)
        self.onProgressUpdated = onProgressUpdated
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            if self?.session == nil {
                timer.invalidate()
            } else {
                self?.duration += 1
                onTimeUpdated(self?.duration ?? 0)
            }
        }
    }
    
    func hasActiveSession() -> Bool {
        self.session != nil
    }
    
    func finishSession(locationManager: CLLocationManager) -> Session? {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        self.duration = 0
        let session = self.session
        self.session = nil
        return session
    }
}

extension SessionTracker : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.global(qos: .utility).async {
            locations.forEach {
                self.session?.addPoint(point: $0)
            }
            if let session = self.session {
                self.onProgressUpdated?(session.getPoints())
            }
        }
    }
}
