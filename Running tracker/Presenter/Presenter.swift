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
    
    private weak var view: SessionView?
    
    private let locationManager = CLLocationManager()
    private let storage: Storage
    private var sessionTracker: SessionTracker? = nil
    private var sessions: [Session] = [Session]()
    
    var sessionsCount: Int {
        get {
            return self.sessions.count
        }
    }
    
    init(view: SessionView) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.storage = Storage(context: appDelegate.persistentContainer.viewContext)
        self.view = view
    }
    
    func startNewSession() {
        let startSessionUseCase = StartSessionUseCase()
        self.sessionTracker = startSessionUseCase.startSession(
            sessionId: storage.getNewSessionId(),
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
                var region: MKCoordinateRegion
                if let userPosition = points.last {
                    region = MKCoordinateRegion(
                        center: userPosition,
                        latitudinalMeters: 200,
                        longitudinalMeters: 200
                    )
                } else {
                    region = MKCoordinateRegion(MKPolygon(coordinates: points, count: points.count).boundingMapRect)
                }
                DispatchQueue.main.async {
                    self?.view?.drawPolyline(
                        polyline: polyline,
                        region: region
                    )
                }
            }
        )
    }
    
    private func buildRegion(for points: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let r = MKMapRect();
        for p in points {
            r.union(
                MKMapRect(
                    x: p.latitude,
                    y: p.longitude,
                    width: 0,
                    height: 0
                )
            );
        }
        return MKCoordinateRegion.init(r);
    }
    
    func finishSession() {
        self.locationManager.delegate = self
        if let session = self.sessionTracker?.finishSession(locationManager: locationManager) {
            session.finishSession()
            self.sessions.insert(session, at: 0)
            self.view?.reloadData()
            DispatchQueue.global(qos: .utility).async {
                self.storage.save(session: session)
            }
        }
        self.sessionTracker = nil
    }
    
    func hasActiveSession() -> Bool {
        return self.sessionTracker?.hasActiveSession() == true
    }
    
    func getFinishedSessions() {
        DispatchQueue.global(qos: .utility).async {
            self.storage.fetchSessions(onFetch: { sessions in
                self.sessions.removeAll()
                self.sessions.append(contentsOf: sessions)
                DispatchQueue.main.async {
                    self.view?.reloadData()
                }
            })
        }
    }
    
    func requestLocation() {
        self.locationManager.delegate = self
        let locStatus = CLLocationManager.authorizationStatus()
        switch locStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            self.view?.requestLocationPermissions()
        }
    }
    
    func getSession(index: Int) -> Session? {
        return self.sessions[index]
    }
}

extension Presenter: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.view?.moveCameraToUserLocation(
                region: MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: 200,
                    longitudinalMeters: 200
                )
            )
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
