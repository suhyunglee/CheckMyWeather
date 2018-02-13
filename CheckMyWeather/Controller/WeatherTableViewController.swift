//
//  WeatherTableViewController.swift
//  CheckMyWeather
//
//  Created by *수형* on 2018. 2. 13..
//  Copyright © 2018년 Suhyung Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class WeatherTableViewController: UITableViewController, CLLocationManagerDelegate {
    
    // initialize locationManager to get users current location
    // weatherInformation to store all the information received from the api
    // defaultCity is set to Los Angeles
    
    let locationManager = CLLocationManager()
    var weatherInformation = [Weather]()
    let defaultCity = "Los Angeles"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // name the right bar button item to Locate and changed its color to black
        // once it is clicked, findLocation function is called
        
        let rightBarButton = UIBarButtonItem(title: "Locate", style: UIBarButtonItemStyle.plain, target: self, action: #selector(findLocation))
        self.navigationItem.rightBarButtonItem = rightBarButton
        rightBarButton.tintColor = UIColor.black
        
        // When the app is first launched, default city weather is loaded (in this case, LA)
        // since the defaultCity is a string with a placemark, change it to a coordinate
        // and pass it to the updateWeatherForLocation function to get the weather
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(defaultCity) { (placemarks, error) in
            guard let placemarks = placemarks, let defaultlocation = placemarks.first?.location
                else {
                    return
            }
            self.updateWeatherForLocation(location: defaultlocation.coordinate)
        }

    }

    // function to check if the location is updated
    // if so, call the updateWeatherForLocation function to get the weather of the current location
    // print function to check the coordinates of the current location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationCoord:CLLocationCoordinate2D = manager.location!.coordinate
        //print("locations = \(locationCoord.latitude) \(locationCoord.longitude)")
        updateWeatherForLocation(location: locationCoord)
    }

    // since I used a selector above, made it an @objc function
    // here asks the user for authorization to get the user's current location
    // and update the user's location once [Locate] button is clicked
    // added 2 privacy properties in info.plist in order to ask user or authorization
    
    @objc func findLocation() {
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    // here update the weather according to the given coordinates
    // used if let since something goes worng and I don't receive the weather data
    // User Interface always needs to be performed on the main thread
    // so use DispatchQueue async to see where you are at the moment
    // realoadData() function triggers the numberOfSections and numberOfRowsInSection function
    // to populate the user interface
    
    func updateWeatherForLocation (location: CLLocationCoordinate2D) {
        Weather.fetchWeatherData(location: location, completion: { (results: [Weather]?) in
            if let weatherData = results {
                self.weatherInformation = weatherData
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        })
    }

    // this function is used to set the title for header in a section
    // formatted the date to show the weekday, month, day, and year
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let date = Calendar.current.date(byAdding: .day, value: section, to: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd, yyyy"
        return dateFormatter.string(from: date!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // returns the number of sections
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return weatherInformation.count
    }
    
    // returns the number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // here dequeue reusable cell with the identifier cellId (same in storyboard)
    // and populate the weather information in a section
    // weather icon, high temp, low temp is set
    // and also the summary is set to an empty string when it is not clicked
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        let weatherObject = weatherInformation[indexPath.section]
        cell.textLabel?.text = "High: \(Int(weatherObject.highTemp)) °F, Low: \(Int(weatherObject.lowTemp)) °F"
        cell.detailTextLabel?.text = ""
        cell.imageView?.image = UIImage(named: weatherObject.icon)
        
        return cell
    }
    
    // this function shows the summary of the weather once the user clicks on a section
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let weatherSummary = weatherInformation[indexPath.section]
        tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = weatherSummary.summary
    }

}
