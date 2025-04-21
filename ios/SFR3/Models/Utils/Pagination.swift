//
//  Pagination.swift
//  SFR3
//
//  Created by Luiz SSB on 19/04/25.
//

struct Pagination: Equatable, Hashable {
    var offset: UInt
    var limit: UInt?
    
    var next: Self {
        return .init(
            offset: offset + (limit ?? 0),
            limit: limit
        )
    }
    
    static func first(limit: UInt? = 0) -> Self {
        return .init(offset: 0, limit: limit)
    }
    
    struct Page<TEntry: Equatable & Hashable>: Equatable, Hashable {
        let entries: [TEntry]
        let pagination: Pagination
        
        var reachedEnd: Bool {
            if let limit = pagination.limit {
                return limit >= entries.count
            }
            return false
        }
    }
}
