//
//  Codable.swift
//  SFR3
//
//  Created by Luiz SSB on 20/04/25.
//

import Foundation

enum JSONCodingError: Error {
    case encoding(any Encodable),
         decoding(String)
}

extension Encodable {
    func asJSON(encoder: JSONEncoder = .init()) throws -> String {
        let jsonData = try encoder.encode(self)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8)
        else { throw JSONCodingError.encoding(self) }
        
        return jsonString
    }
}


extension Decodable {
    init(jsonString: String, decoder: JSONDecoder = .init()) throws {
        guard let jsonData = jsonString.data(using: .utf8)
        else { throw JSONCodingError.decoding(jsonString) }
        
        let decoded = try decoder.decode(Self.self, from: jsonData)
        self = decoded
    }
}
