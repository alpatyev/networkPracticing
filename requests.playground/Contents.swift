import Foundation
import CryptoKit

// MARK: - Dispatch requests

let requestGroup = DispatchGroup()

// MARK: - Task 1

final class AsteroidsByNASA {

    static func requestCount(urlString: String = AsteroidsByNASA.createTodayURLString()) {
        requestGroup.enter()
        
        guard let url = URL(string: urlString) else {
            print("\n * <NASA> INVALID URL STRING")
            return
        }
        print("\n * <NASA> REQUESTING: \(urlString.prefix(29))...")
        
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
                            print(" * <NASA> RESULT: Today \(Date().string(with: "yyyy-MM-dd")) we have \(count) asteroids around Earth.")
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
    
    static func createTodayURLString() -> String {
        let base = "https://api.nasa.gov/neo/rest/v1/feed?"
        let todayString = Date().string(with: "yyyy-MM-dd")
        let todayInterval = "start_date=\(todayString)&end_date=\(todayString)"
        let apiKey = "&api_key=GmAVhaVjomPSpV89qdgfaVvmnQhCRsn8VrhUVexa"
        return base + todayInterval + apiKey
    }
}

AsteroidsByNASA.requestCount()

// MARK: - Task 2

final class MarvelComics {
    
    // MARK: - Decoding keys
    
    private let timeStamp = Date().string(with: "yyyy.MM.dd")
    private let publicKey: String
    private let privateKey: String
    private let baseURL: String
    
    // MARK: - Common init
    
    init(publicKey: String = "cf84e95c6735b5f2cebe6583497d937d",
         privateKey: String = "e62bc278ee244cf43225a6279cd0895ebf5c97d2",
         baseURL: String = "https://gateway.marvel.com:443/v1/public/characters?") {
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.baseURL = baseURL
    }
    
    // MARK: - Main method
        
    public func requestForCharacter(_ nameStartsWith: String) {
        requestGroup.wait()
        
        let urlString = generateURL(nameStartsWith)
        guard let url = URL(string: urlString) else {
            print("\n * <MARVEL> INVALID URL STRING")
            return
        }
        print("\n * <MARVEL> REQUESTING: \(urlString.prefix(26))...")
        
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
    
    private func generateURL(_ characterName: String) -> String {
        let nameParameter = "nameStartsWith=" + characterName
        let timeStampParameter = "&ts=" + timeStamp
        let apiKeyParameter = "&apikey=" + publicKey
        let hashParameter = "&hash=" + generateHash()
        return baseURL + nameParameter + timeStampParameter + apiKeyParameter + hashParameter
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
