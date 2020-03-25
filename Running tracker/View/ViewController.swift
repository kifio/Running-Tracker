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
}

class ViewController: UIViewController, SessionView {

    private let cornerRadius: CGFloat = 4.0
    private let shadowRadius: CGFloat = 4.0
    private let shadowOffset: CGFloat = 1.0
    private let shadowOpacity: Float = 0.5
    private let horizontalOffset: CGFloat = 4.0
    private let verticalOffset: CGFloat = 8.0
    private let mapHeight: CGFloat = 200

    private var mapContainer: UIView!
    private var mapView: MKMapView!
    private var sessionsView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        guard let navigationBar = self.navigationController?.navigationBar else {
            return
        }

        self.setupNavigationBar(navigationBar)
        self.setupMapView(navigationBar)
        self.setupTableView()
    }

    private func setupNavigationBar(_ navigationBar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = UIColor.white

        navigationBar.barStyle = .default
        navigationBar.isTranslucent = true
        navigationBar.standardAppearance = appearance

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: nil)
    }

    private func setupMapView(_ navigationBar: UINavigationBar) {

        self.mapView = MKMapView()
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
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: {
            UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
        })
    }
}
