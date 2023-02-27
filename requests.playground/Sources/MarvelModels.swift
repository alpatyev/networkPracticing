import Foundation

// MARK: - Recieved type

public struct MarvelData: Decodable {
    public let data: CharactersData
}

// MARK: - All founded characters

public struct CharactersData: Decodable {
    public let results: [MarvelCharacter]
}

// MARK: - Character
public struct MarvelCharacter: Decodable {
    public let name: String
    public let comics: ComicsData
}

// MARK: - Comics

public struct ComicsData: Decodable {
    public let available: Int
    public let items: [Comics]
}

public struct Comics: Decodable {
    public let name: String
}
