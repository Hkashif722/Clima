//
//  WeatherManager.swift
//  Clima
//
//  Created by Asif on 05/09/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModal)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=7cae135d3017d44f1fb5c0344f448761&units=metric"
    
    var delegate: WeatherManagerDelegate?
        
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherUrl)&q=\(cityName)"
        print(urlString)
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: Double, longitude: Double ) {
        let urlString = "\(weatherUrl)&lat=\(latitude)&lon=\(longitude)"
        print(urlString)
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String){
        // 1. Create URl
        if let url = URL(string: urlString){
            //2. Create URL session
            let session = URLSession(configuration: .default)
            //3. Give the session the task
            let task  = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather =  self.parseJson(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
            }
            
            //4. start task
            task.resume()
        }
    }
    
    func parseJson(_ weatherData: Data) -> WeatherModal? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            return WeatherModal(conditionId: id, cityName: name, temperature: temp)
            
        }
        catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}
