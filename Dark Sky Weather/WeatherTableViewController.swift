//
//  WeatherTableViewController.swift
//  Dark Sky Weather
//
//  Created by Roman Rosenast on 10/5/19.
//  Copyright © 2019 Roman Rosenast. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var Header: UINavigationItem!
    
    var locationManager = CLLocationManager()
    
//    Model interacts with VC through forecastData array.
    var forecastData = [Weather]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Default to LA weather
        updateWeatherForLocation(location: CLLocation(latitude: 34.052235, longitude: -118.2437), defaultLoc: true)
    }
    
//    Updates forecastData array using static function from Weather class then refreshes tableview to show new information.
    func updateWeatherForLocation (location: CLLocation, defaultLoc: Bool = false) {
        
        Header.title = defaultLoc ? "Los Angeles" : "Current Location"
            
        Weather.forecast(withLocation: location.coordinate, completion: { (results:[Weather]?) in
            if let weatherData = results {
                self.forecastData = weatherData
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
//    Handle user requesting to see weather report for their current location.
    @IBAction func getLocation(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
            locationManager.startUpdatingLocation()
        }
    }
    
//    Update tableview with user's inputted location.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        updateWeatherForLocation(location: userLocation! )
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let weatherObject = forecastData[indexPath.row]

        cell.textLabel?.text = "\(weatherObject.day): \(Int(weatherObject.low))° - \(Int(weatherObject.high))°"
        cell.imageView?.image = UIImage(named: weatherObject.icon)

        return cell
    }
    
//    Dynamically size tableview cells to fill screen.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let MinHeight: CGFloat = 80.0
        let tHeight = tableView.bounds.height
        
        let dynamicHeight = tHeight / CGFloat(forecastData.count+1)
        return dynamicHeight > MinHeight ? dynamicHeight : MinHeight
    }
    
//    Programatically display new page with selected day's summary.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weatherObject = forecastData[indexPath.row]
        
        let summaryVC = UIViewController()
        let summaryLabel = UILabel(frame: CGRect(x: 0, y: 0, width: summaryVC.view.bounds.width, height: summaryVC.view.bounds.height))
        summaryLabel.center = CGPoint(x: summaryVC.view.bounds.width/2, y: summaryVC.view.bounds.height/4)
        summaryLabel.textAlignment = .center
        summaryLabel.textColor = .white
        summaryLabel.text = weatherObject.summary
        
        summaryVC.view.addSubview(summaryLabel)
        
        navigationController?.pushViewController(summaryVC, animated: false)
    }
}
