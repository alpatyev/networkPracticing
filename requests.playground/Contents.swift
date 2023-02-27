import Foundation
import CryptoKit

// MARK: - Dispatch requests

let requestGroup = DispatchGroup()

// MARK: - Task 1

final class AsteroidsByNASA {
    
    static let apiKey = "GmAVhaVjomPSpV89qdgfaVvmnQhCRsn8VrhUVexa"

    static func requestCount() {
        requestGroup.enter()
        
        guard let url = createTodayURL() else {
            print("\n * <NASA> INVALID URL STRING")
            return
        }
        print("\n * <NASA> REQUESTING: \(url.absoluteString.prefix(29))...")
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let requestError = error {
                print(" * <NASA> ERROR: \(requestError.localizedDescription)")
            }
            
            if let response = response as? HTTPURLResponse {
                print(" * <NASA> RESPONSE CODE: \(response.statusCode)")
            }
            
            if let result = data {
                do {
                    if let dictionary = try JSONSerialization.jsonObject(with: result, options: []) as? [String: Any] {
                        if let count = dictionary["element_count"] as? Int {
                            print(" * <NASA> RESULT: Today we have \(count) asteroids around Earth.")
                        } else {
                            print(" * <NASA> RESULT DECODING ERROR: VALUES NOT FOUND")
                        }
                    }
                } catch let serializeError {
                    print(" * <NASA> RESULT DECODING ERROR: \(serializeError.localizedDescription)")
                }
                
                requestGroup.wait(timeout: .now() + 1.5)
                requestGroup.leave()
            } else {
                print(" * <NASA> RESULT NOT RECIEVED")
            }
        }).resume()
    }
    
    static func createTodayURL() -> URL? {
        let todayString = Date().string(with: "yyyy-MM-dd")
        var urlBuilder = URLComponents()
        urlBuilder.scheme = "https"
        urlBuilder.host = "api.nasa.gov"
        urlBuilder.path = "/neo/rest/v1/feed"
        urlBuilder.queryItems = [URLQueryItem(name: "start_date", value: todayString),
                                 URLQueryItem(name: "end_date", value: todayString),
                                 URLQueryItem(name: "api_key", value: apiKey)]
        return urlBuilder.url
    }
}

AsteroidsByNASA.requestCount()

// MARK: - Task 2

final class MarvelComics {
    
    // MARK: - Time data
    
    private let timeStamp = Date().string(with: "yyyy.MM.dd")
    
    // MARK: - Api keys
    
    private let publicKey = "cf84e95c6735b5f2cebe6583497d937d"
    private let privateKey = "e62bc278ee244cf43225a6279cd0895ebf5c97d2"
    
    // MARK: - URLComponents
    
    private lazy var urlBuilder: URLComponents = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "gateway.marvel.com"
        components.port = 443
        components.path = "/v1/public/characters"
        return components
    }()
    
    // MARK: - Main method
        
    public func requestForCharacter(_ nameStartsWith: String) {
        requestGroup.wait()
        
        guard let url = generateURL(nameStartsWith) else {
            print("\n * <MARVEL> INVALID URL STRING")
            return
        }
        print("\n * <MARVEL> REQUESTING: \(url.absoluteString.prefix(26))...")
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let requestError = error {
                print(" * <MARVEL> ERROR: \(requestError.localizedDescription)")
            }
            
            if let response = response as? HTTPURLResponse {
                print(" * <MARVEL> RESPONSE CODE: \(response.statusCode)")
            }

            if let result = data {
                let decoder = JSONDecoder()
                
                do {
                    let decoded = try decoder.decode(MarvelData.self, from: result)
                    if decoded.data.results.count > 0 {
                        print(" * <MARVEL> RESULT: Founded \(decoded.data.results.count) characters! Here some examples: \(self.createCharactersList(decoded))")
                    } else {
                        print(" * <MARVEL> RESULT: Characters with name '\(nameStartsWith)' not founded!")
                    }
                   
                } catch let decodingError {
                    print(" * <MARVEL> RESULT DECODING ERROR: \(decodingError.localizedDescription)")
                }
            } else {
                print(" * <MARVEL> RESULT NOT RECIEVED")
            }
        }).resume()
    }
    
    // MARK: - Private methods
    
    private func generateURL(_ characterName: String) -> URL? {
        urlBuilder.queryItems = [URLQueryItem(name: "nameStartsWith", value: characterName),
                                 URLQueryItem(name: "ts", value: timeStamp),
                                 URLQueryItem(name: "apikey", value: publicKey),
                                 URLQueryItem(name: "hash", value: generateHash())]
        return urlBuilder.url
    }
    
    private func generateHash() -> String {
        let completedString = timeStamp + privateKey + publicKey
        let dataString = Data(completedString.utf8)
        let hash = Insecure.MD5.hash(data: dataString)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    private func createCharactersList(_ marvelData: MarvelData) -> String {
        let paging = "\n  "
        var number = 0
        var lines = String()
        
        for character in marvelData.data.results {
            number += 1
            lines += (paging + "\(number). \(character.name)")
            
            if character.comics.available > 0 {
                lines += (paging + "Available \(character.comics.available) comics, as an example:")
                
                let limit = 12
                let itemsCount = character.comics.items.count
                let randomLength = Int.random(in: 1..<(itemsCount < limit ? itemsCount : limit))
                let randomComicsArray = character.comics.items.shuffled()[1...randomLength]
                
                for (index, comics) in randomComicsArray.enumerated() {
                    lines += (paging + "\(repeatElement(" ", count: index).joined()) • \(comics.name)")
                }
            }
            lines += "\n"
        }
        return lines
    }
}

MarvelComics().requestForCharacter("Spider-Man")

