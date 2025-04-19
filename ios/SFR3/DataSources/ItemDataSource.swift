//
//  ItemDataSource.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

import Factory

struct ItemDataSource {
    var list = {
        (_ pagination: Pagination) async throws -> Pagination.Page<Item> in
        try? await Task.sleep(for: .seconds(2))
        return .init(
            entries: [],
            pagination: pagination
        )
    }
    
    var add = { (_ item: Item) async throws in
        try? await Task.sleep(for: .seconds(1))
    }
    
    var delete = { (_ id: String) async throws -> Item? in
        try? await Task.sleep(for: .seconds(1))
        return nil
    }
    
    var update = { (_ item: Item) async throws in
        try? await Task.sleep(for: .seconds(1))
    }
}

extension Container {
    var itemDataSource: Factory<ItemDataSource> {
        self { ItemDataSource() }
            .singleton
    }
}
