//
//  ViewController.swift
//  Running tracker
//
//  Created by Ivan Murashov on 23.03.20.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import MapKit

protocol SessionView : class {
    func requestLocationPermissions()
    func drawPolyline(polyline: MKGeodesicPolyline, region: MKCoordinateRegion)
    func moveCameraToUserLocation(region: MKCoordinateRegion)
}

class ViewController: UIViewController, SessionView {
    
    private let cornerRadius: CGFloat = 4.0
    private let shadowRadius: CGFloat = 4.0
    private let shadowOffset: CGFloat = 1.0
    private let shadowOpacity: Float = 0.5
    private let horizontalOffset: CGFloat = 4.0
    private let verticalOffset: CGFloat = 8.0
    private let mapHeight: CGFloat = 200
    
    private var presenter: Presenter?
    private var mapContainer: UIView!
    private var mapView: MKMapView!
    private var sessionsView: UITableView!
    
    private var startSessionItem: UIBarButtonItem!
    private var finishSessionItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = Presenter(view: self)
        self.startSessionItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.add,
            target: self,
            action: #selector(navigationItemClicked)
        )
        self.finishSessionItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.stop,
            target: self,
            action: #selector(navigationItemClicked)
        )
        
        view.backgroundColor = UIColor.white
        
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }
        
        self.setupNavigationBar(navigationBar)
        self.setupMapView(navigationBar)
        self.setupTableView()
        
        self.presenter?.requestLocation()
        self.presenter?.getFinishedSessions()
    }
    
    private func setupNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = UIColor.white
        
        navigationBar.barStyle = .default
        navigationBar.isTranslucent = true
        navigationBar.standardAppearance = appearance
        
        self.navigationItem.rightBarButtonItem = startSessionItem
    }
    
    @objc func navigationItemClicked() {
        if self.presenter?.hasActiveSession() == false {
            self.navigationItem.rightBarButtonItem = self.finishSessionItem
            self.presenter?.startNewSession()
        } else {
            self.navigationItem.rightBarButtonItem = self.startSessionItem
            self.presenter?.finishSession()
        }
    }
    
    private func setupMapView(_ navigationBar: UINavigationBar) {
        
        self.mapView = MKMapView()
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.mapView.layer.cornerRadius = cornerRadius
        self.mapView.layer.masksToBounds = true
        
        self.mapContainer = UIView()
        self.mapContainer.layer.shadowColor = UIColor.black.cgColor
        self.mapContainer.layer.shadowRadius = shadowRadius
        self.mapContainer.layer.shadowOffset = CGSize(width: shadowOffset, height: shadowOffset)
        self.mapContainer.layer.shadowOpacity = shadowOpacity
        self.mapContainer.addSubview(self.mapView)
        self.view.addSubview(mapContainer)
        
        self.mapContainer.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeAreaLayoutGuide = self.view.safeAreaLayoutGuide
        self.mapContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -horizontalOffset).isActive = true
        self.mapContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: horizontalOffset).isActive = true
        self.mapContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: verticalOffset).isActive = true
        self.mapContainer.heightAnchor.constraint(equalToConstant: mapHeight).isActive = true
        
        self.mapView.trailingAnchor.constraint(equalTo: mapContainer.trailingAnchor).isActive = true
        self.mapView.leadingAnchor.constraint(equalTo: mapContainer.leadingAnchor).isActive = true
        self.mapView.topAnchor.constraint(equalTo: mapContainer.topAnchor).isActive = true
        self.mapView.bottomAnchor.constraint(equalTo: mapContainer.bottomAnchor).isActive = true
    }
    
    private func setupTableView() {
        self.sessionsView = UITableView()
        self.sessionsView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(sessionsView)
        
        let guide = self.view.safeAreaLayoutGuide
        self.sessionsView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.sessionsView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.sessionsView.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: mapHeight).isActive = true
        self.sessionsView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func requestLocationPermissions() {
        let alert = UIAlertController(
            title: "Location Services are disabled",
            message: "Please enable Location Services in your Settings",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            UIApplication.shared.open(URL(string:UIApplication.openSettingsURLString)!)
        })
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func drawPolyline(polyline: MKGeodesicPolyline, region: MKCoordinateRegion) {
        self.mapView.addOverlay(polyline)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.mapView.setRegion(region, animated: true)
        })
    }
    
    func moveCameraToUserLocation(region: MKCoordinateRegion) {
        self.mapView.setRegion(region, animated: false)
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 3
        return renderer
    }
}
