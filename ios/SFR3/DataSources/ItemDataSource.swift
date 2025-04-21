//
//  ItemDataSource.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import Foundation
import Factory

struct ItemDataSource {
    var list = {
        (_ pagination: Pagination) async throws -> Pagination.Page<Item> in
        try? await Task.sleep(for: .seconds(2))
        
        guard !Self.database.isEmpty,
              Self.database.count > pagination.offset
        else { return .init(entries: [], pagination: pagination)}
        
        let lastIndexExclusive = min(
            Self.database.count,
            pagination.lastIndex ?? .max
        )
        
        let allEntries = Self.database
        let entries = [Item](allEntries[pagination.offset..<lastIndexExclusive])
        return .init(
            entries: entries,
            pagination: pagination
        )
    }
    
    var get = { (_ itemId: String) async throws -> Item? in
        try? await Task.sleep(for: .seconds(1))
        return Self.database.first { $0.id == itemId }
    }
    
    var upsert = { (_ item: Item) async throws in
        if let index = Self.database.firstIndex(where: { $0.id == item.id }) {
            Self.database[index] = item
        } else {
            Self.database.append(item)
            Self.database.sort {
                $0.name.caseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
    }
    
    var delete = { (_ id: String) async throws -> Item? in
        try? await Task.sleep(for: .seconds(1))
        if let index = Self.database.firstIndex(where: { $0.id == id }) {
            let item = Self.database[index]
            Self.database.remove(at: index)
            return item
        }
        return nil
    }
    
    private static var database: [Item] = [
        "12 Years a Slave",
        "Avengers: Endgame",
        "Back to the Future",
        "Black Swan",
        "Blade Runner 2049",
        "Braveheart",
        "Django Unchained",
        "Fight Club",
        "Forrest Gump",
        "Gladiator",
        "Goodfellas",
        "Inception",
        "Interstellar",
        "Joker",
        "La La Land",
        "No Country for Old Men",
        "Once Upon a Time in Hollywood",
        "Parasite",
        "Pulp Fiction",
        "Saving Private Ryan",
        "Schindler’s List",
        "Se7en",
        "Terminator 2: Judgment Day",
        "The Big Short",
        "The Dark Knight",
        "The Departed",
        "The Empire Strikes Back",
        "The Godfather",
        "The Green Mile",
        "The Lion King",
        "The Lord of the Rings: The Return of the King",
        "The Matrix",
        "The Prestige",
        "The Revenant",
        "The Shawshank Redemption",
        "The Silence of the Lambs",
        "The Social Network",
        "The Truman Show",
        "The Wolf of Wall Street",
        "Titanic",
        "Whiplash"
    ].map { Item(id: UUID().uuidString, name: $0) }
}

extension Container {
    var itemDataSource: Factory<ItemDataSource> {
        self { ItemDataSource() }
            .singleton
    }
}
