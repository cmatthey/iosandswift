import PlaygroundSupport
import Foundation

// Cite: https://developer.apple.com/documentation/foundation/url_loading_system/fetching_website_data_into_memory

/*
 1)  Import the PlaygroundSupport framework
 2)  Set the current PlaygroundPage to execute indefinitely so that it will stay active long enough for the web request to finish.
    */
PlaygroundPage.current.needsIndefiniteExecution = true
URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)

class Weather {

    func startLoad() {
        let openweathermapUrl = "http://api.openweathermap.org/data/2.5/weather?q=Palo%20Alto,us&units=imperial&APPID=4f054f30837c4448a2cf14cc0eb4c686"
        let url = URL(string: openweathermapUrl)!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                self.handleClientError(error: error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    self.handleServerError(response: response!)
                    return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.handleResponse(string: string, url: url)
                }
            }
        }
        task.resume()
    }
    
    func handleClientError(error: Error) {
        print("*in ClientError*\(error)")
    }
    
    func handleServerError(response: URLResponse) {
        print("*in ServerError*\(response)")
    }
    
    func handleResponse(string: String, url: URL) {
        let data = string.data(using: .utf8)!
        
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                if let mainObject = jsonObject["main"] as? [String: Any] {
                    print("Temperature is \(mainObject["temp"]!)°F")
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }
}

let w = Weather()
w.startLoad()
