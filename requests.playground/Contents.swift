import Foundation

// MARK: - Task 1

final class AsteroidsByNASA {

    static func requestCount(urlString: String = AsteroidsByNASA.createTodayURLString()) {
        guard let url = URL(string: urlString) else {
            print(" * INVALID URL STRING")
            return
        }
        print(" * REQUESTING: \(urlString.prefix(30))...")
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let requestError = error {
                print(" * ERROR: \(requestError.localizedDescription)")
            }
            
            if let response = response as? HTTPURLResponse {
                print(" * RESPONSE CODE: \(response.statusCode)")
            }
            if let result = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                        if let count = json["element_count"] as? Int {
                            print(" * RESULT: Today \(AsteroidsByNASA.createFormattedDate()) we have \(count) asteroids around Earth.")
                        } else {
                            print(" * RESULT DECODING ERROR: VALUES NOT FOUND")
                        }
                    }
                } catch let serializeError {
                    print(" * RESULT DECODING ERROR: \(serializeError.localizedDescription)")
                }
            }
        }).resume()
    }
    
    static func createFormattedDate() -> String {
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: today)
    }
    
    static func createTodayURLString() -> String {
        let base = "https://api.nasa.gov/neo/rest/v1/feed?"
        
        let todayString = AsteroidsByNASA.createFormattedDate()
        let todayInterval = "start_date=\(todayString)&end_date=\(todayString)"
        
        let apiKey = "&api_key=GmAVhaVjomPSpV89qdgfaVvmnQhCRsn8VrhUVexa"
        
        return base + todayInterval + apiKey
    }
}

AsteroidsByNASA.requestCount()

// MARK: - Task 2

