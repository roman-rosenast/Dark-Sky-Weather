//
//  Weather.swift
//  A file for parsing JSON data from Dark Sky.
//  Code adapted from original author: Brian Advent
//
//  Created by Roman Rosenast on 10/5/19.
//  Copyright © 2019 Roman Rosenast. All rights reserved.
//
import Foundation
import CoreLocation

// Weather Model is defined here and all API calls are dealt with in this file so that WeatherTableViewController only deals directly with the information that it needs to display.
struct Weather {
    let summary:String
    let icon:String
    let day:String
    let high:Double
    let low:Double
    
    enum SerializationError:Error {
        case missing(String)
        case invalid(String, Any)
    }
    
    
    init(json:[String:Any]) throws {
        
        guard let summary = json["summary"] as? String else {throw SerializationError.missing("summary is missing")}
        
        guard let icon = json["icon"] as? String else {throw SerializationError.missing("icon is missing")}
        
        guard let high = json["temperatureMax"] as? Double else {throw SerializationError.missing("temp high is missing")}
        
        guard let low = json["temperatureMin"] as? Double else {throw SerializationError.missing("temp low is missing")}

        guard let time = json["time"] as? Double else {throw SerializationError.missing("time is missing")}
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let day = formatter.string(from: Date(timeIntervalSince1970: time))
        
        self.summary = summary
        self.icon = icon
        self.high = high
        self.low = low
        self.day = day
        
    }
    
    
    static let basePath = "https://api.darksky.net/forecast/e58d5d056efc18e0c900b516397001a8/"
    
    static func forecast (withLocation location:CLLocationCoordinate2D, completion: @escaping ([Weather]?) -> ()) {
        
        let url = basePath + "\(location.latitude),\(location.longitude)"
        let request = URLRequest(url: URL(string: url)!)
        
        let task = URLSession.shared.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            
            var forecastArray:[Weather] = []
            
            if let data = data {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        if let dailyForecasts = json["daily"] as? [String:Any] {
                            if let dailyData = dailyForecasts["data"] as? [[String:Any]] {
                                for dataPoint in dailyData {
                                    if let weatherObject = try? Weather(json: dataPoint) {
                                        forecastArray.append(weatherObject)
                                    }
                                }
                            }
                        }
                    
                    }
                }catch {
                    print(error.localizedDescription)
                }
                
                completion(forecastArray)
                
            }
            
            
        }
        
        task.resume()
        
    }
    

}
