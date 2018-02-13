//
//  Weather.swift
//  CheckMyWeather
//
//  Created by *수형* on 2018. 2. 13..
//  Copyright © 2018년 Suhyung Lee. All rights reserved.
//

import CoreLocation

// first create a class with variables such as
// icon(for icon image), highTemp for highest temperature
// lowTemp for lowest temperature and summary for the summary of the daily weather

class Weather: NSObject {
    let icon: String
    let highTemp: Double
    let lowTemp: Double
    let summary: String
    
    // initialize as json Object and named them according to the api file
    // by reading the sample Dark Sky api file, figured icon represents the icon
    // temperatureMax represents the highest temperature
    // temperatureMin represents the lowest temperature
    // and summary represents the summary of a day
    
    init(json: [String: AnyObject]) throws {
        let icon = json["icon"] as! String
        let highTemp = json["temperatureMax"] as! Double
        let lowTemp = json["temperatureMin"] as! Double
        let summary = json["summary"] as! String
        
        self.icon = icon
        self.highTemp = highTemp
        self.lowTemp = lowTemp
        self.summary = summary
    }
    
    // Since I had to implement a locate bar button which finds the users current location
    // baseUrl is a string containing only the key
    // here change [yourkey] to your key
    
    static let baseUrl = "https://api.darksky.net/forecast/[yourkey]/"
    static func fetchWeatherData(location: CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()){
        
        // conbine the rest of the url by getting the latitude and the longitude
        
        let url = baseUrl + "\(location.latitude),\(location.longitude)"
        let urlRequest = URLRequest(url: URL(string: url)!)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            var weatherInfoArray:[Weather] = []
            
            // prints the error message if it is not nil
            
            if error != nil {
                print(error!)
                return
            }
            
            // here, access the json file information and set them equal to the correct variables
            // catch if there is an error
            
            do {
                if let unwrappedData = data, let json = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: AnyObject] {
                    if let dailyWeather = json["daily"] as? [String:AnyObject] {
                        if let dailyData = dailyWeather["data"] as? [[String:AnyObject]] {
                            for weatherData in dailyData {
                                if let weatherInfoObj = try? Weather(json: weatherData) {
                                    weatherInfoArray.append(weatherInfoObj)
                                }
                            }
                        }
                    }
                }
            } catch let jsonError{
                print(jsonError)
            }
            completion(weatherInfoArray)
            }.resume()
    }
}
