//
//  Session.swift
//  Running tracker
//
//  Created by Ivan Murashov on 26.03.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import CoreLocation

struct LocationPoint {
    let sessionId: Int
    let lat: Double
    let lon: Double
}

class Session {
    
    let id: Int
    private let startTime: TimeInterval
    private var points: [LocationPoint]
    private var finishtime: TimeInterval
    
    init(id: Int) {
        self.id = id
        self.startTime = NSDate().timeIntervalSince1970
        self.finishtime = startTime
        self.points = [LocationPoint]()
    }
    
    func addPoint(point: CLLocation) {
        self.points.append(
            LocationPoint(
                sessionId: id,
                lat: point.coordinate.latitude,
                lon: point.coordinate.longitude
            )
        )
    }
    
    func finishSession() {
        self.finishtime = NSDate().timeIntervalSince1970
    }
    
    func getDuration() -> TimeInterval {
        return self.finishtime - self.startTime
    }
    
    func getPoints() -> [CLLocationCoordinate2D] {
        return points.map {
            CLLocationCoordinate2D(
                latitude: $0.lat,
                longitude: $0.lon
            )
        }
    }
}
