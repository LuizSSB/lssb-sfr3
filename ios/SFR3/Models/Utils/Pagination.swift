//
//  Pagination.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

struct Pagination: Equatable, Hashable {
    var offset: Int
    var limit: Int?
    
    var lastIndex: Int? {
        if let limit {
            return offset + limit
        }
        return nil
    }
    
    var next: Self {
        return .init(
            offset: offset + (limit ?? 0),
            limit: limit
        )
    }
    
    static func first(limit: Int? = 0) -> Self {
        return .init(offset: 0, limit: limit)
    }
    
    struct Page<TEntry: Equatable & Hashable>: Equatable, Hashable {
        let entries: [TEntry]
        let pagination: Pagination
        
        var reachedEnd: Bool {
            if let limit = pagination.limit {
                return limit > entries.count
            }
            return false
        }
    }
}
