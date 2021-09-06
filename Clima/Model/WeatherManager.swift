import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWihError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=adb2e9bb504941cac388b747ed3bd061"
    
    var delegate: WeatherManagerDelegate?
    
    func fecthWeather(latitude:CLLocationDegrees, longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    func fetchWeather(cityName: String){
        let urlString: String
        if(cityName.contains(" ")){
            let cityNameWithSpace = (cityName as NSString).replacingOccurrences(of: " ", with: "+")
            urlString = "\(weatherURL)&q=\(cityNameWithSpace)"
        }else{
            urlString = "\(weatherURL)&q=\(cityName)"
        }
        performRequest(with: urlString)
        print(urlString)
    }
    
    func performRequest(with urlString:String) {
        //criando a url
        if let url = URL(string: urlString) {
            //criando a URLSession
            let session = URLSession(configuration: .default)
            // tando a session a tarefa
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil{
                    self.delegate?.didFailWihError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            // iniciando a tarefa
            task.resume()
        }
    }
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let name = decodeData.name
            let temp = decodeData.main.temp
            let id = decodeData.weather[0].id
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print(weather.temperatureString)
            return weather
            
        } catch {
            self.delegate?.didFailWihError(error: error)
            return nil
        }
    }    
}
