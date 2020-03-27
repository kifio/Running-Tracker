//
//  Presenter.swift
//  Running tracker
//
//  Created by Ivan Murashov on 24.03.20.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class Presenter: NSObject {
    
    private let locationManager = CLLocationManager()
    private weak var view: SessionView?
    private var sessionTracker: SessionTracker? = nil
    
    init(view: SessionView) {
        self.view = view
    }
    
    func startNewSession() {
        let startSessionUseCase = StartSessionUseCase()
        self.sessionTracker = startSessionUseCase.startSession(
            sessionId: 0,
            locationManager: self.locationManager,
            onLocationStatusNotDetermined: {
                self.locationManager.requestWhenInUseAuthorization()
            },
            onLocationDenied: { [weak self] in
                self?.view?.requestLocationPermissions()
            },
            onSessionStarted: {
            
            },
            onProgressUpdated: { [weak self] points in
                let polyline = MKGeodesicPolyline(coordinates: points, count: points.count)
                DispatchQueue.main.async {
                    self?.view?.drawPolyline(polyline: polyline)
                }
            }
        )
    }
    
    func finishSession() {
        let session = self.sessionTracker?.finishSession(locationManager: locationManager)
        // TODO: Save session
        self.sessionTracker = nil
    }
    
    func hasActiveSession() -> Bool {
        return self.sessionTracker?.hasActiveSession() == true
    }
}
