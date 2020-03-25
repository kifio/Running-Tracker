//
//  Presenter.swift
//  Running tracker
//
//  Created by Ivan Murashov on 24.03.20.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

class Presenter: NSObject {
    
    private weak var view: SessionView?
    
    init(view: SessionView) {
        self.view = view
    }
    
    func startNewSession() {
        let startSessionUseCase = StartSessionUseCase()
        startSessionUseCase.startSession(
            onLocationDenied: { [weak self] in
                self?.view?.requestLocationPermissions()
            },
            onSessionStarted: {
            
            },
            onProgressUpdated: {
            
            },
            onSessionFinished: {
            
            }
        )
    }
}
