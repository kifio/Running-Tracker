//
//  Storage.swift
//  Running tracker
//
//  Created by imurashov private on 28.03.20.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import CoreData

class Storage {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func save(session: Session,
              onSave: () -> (Void)) {
        let sessionEntity = NSEntityDescription.entity(forEntityName: "Sessions", in: context)
        
        let sessionObject = NSManagedObject(entity: sessionEntity!, insertInto: context)
        sessionObject.setValue(session.id, forKey: "id")
        sessionObject.setValue(session.startTime, forKey: "start_time")
        sessionObject.setValue(session.finishTime, forKey: "finish_time")
        
        do {
            try sessionObject.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
        
        let pointsEntity = NSEntityDescription.entity(forEntityName: "Points", in: context)
        
        session.points.forEach {
            let pointObject = NSManagedObject(entity: pointsEntity!, insertInto: context)
            pointObject.setValue($0.sessionId, forKey: "session_id")
            pointObject.setValue($0.lat, forKey: "lat")
            pointObject.setValue($0.lon, forKey: "lon")
            pointObject.setValue($0.index, forKey: "index")
            
            do {
                try pointObject.managedObjectContext?.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
    
    func fetchSessions(onFetch: ([Session]) -> Void) {
        var sessions = [Session]()
        var fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Sessions")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "start_time", ascending: false)]

        do {
            var result = try self.context.fetch(fetchRequest)
            for managedObject in result {
                if let id = managedObject.value(forKey: "id") as? Int,
                    let startTime = managedObject.value(forKey: "start_time")  as? Date,
                    let finishTime = managedObject.value(forKey: "finish_time")  as? Date {
                    fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Points")
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
                    fetchRequest.predicate = NSPredicate(format: "session_id == %d", id)
                    result = try self.context.fetch(fetchRequest)
                    var points = [LocationPoint]()
                    for managedObject in result {
                        if let index = managedObject.value(forKey: "index") as? Int,
                            let lat = managedObject.value(forKey: "lat") as? Double,
                            let lon = managedObject.value(forKey: "lon")  as? Double {
                            points.append(
                                LocationPoint(
                                    sessionId: id,
                                    index: index,
                                    lat: lat,
                                    lon: lon
                                )
                            )
                        }
                    }
                    sessions.append(
                        Session(id: id,
                                startTime: startTime,
                                finishTime: finishTime,
                                points: points
                        )
                    )
                }
            }
            onFetch(sessions)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            onFetch(sessions)
        }
    }
    
    func getNewSessionId() -> Int {
        do {
            return try self.context.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "Sessions"))
        } catch {
            let fetchError = error as NSError
            print(fetchError)
            return 0
        }
    }
}
