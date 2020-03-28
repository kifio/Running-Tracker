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
    let index: Int
    let lat: Double
    let lon: Double
}

class Session {
    
    let id: Int
    let startTime: Date
    var points: [LocationPoint]
    var finishTime: Date
    
    init(id: Int) {
        self.id = id
        self.startTime = Date()
        self.finishTime = startTime
        self.points = [LocationPoint]()
    }
    
    init(id: Int, startTime: Date, finishTime: Date, points: [LocationPoint]) {
        self.id = id
        self.startTime = startTime
        self.finishTime = finishTime
        self.points = points
    }
    
    func addPoint(point: CLLocation) {
        self.points.append(
            LocationPoint(
                sessionId: id,
                index: self.points.count,
                lat: point.coordinate.latitude,
                lon: point.coordinate.longitude
            )
        )
    }
    
    func finishSession() {
        self.finishTime = Date()
    }
    
    func getDuration(formatter: DateComponentsFormatter) -> String? {
        //        let formatter = DateComponentsFormatter()
        //        formatter.unitsStyle = .full
        //        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
        //        formatter.maximumUnitCount = 2
        return formatter.string(from: self.startTime, to: self.finishTime)
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
