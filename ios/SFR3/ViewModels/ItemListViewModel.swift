//
//  ItemListViewModel.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

@Observable class ItemListViewModel: ViewModel {
    struct State: ViewModelState {
        var items: [Item]?
        var itemsFetchStatus: ActionStatus<Pagination.Page<Item>, String> = .none
        var deleteStatus: ActionStatus<Item, String> = .none
        
        var detail: ItemDetailViewModel?
        
        var canLoadMore: Bool {
            guard case let .success(result) = itemsFetchStatus,
                  !result.reachedEnd
            else { return true }
            
            return false
        }
    }
    
    var state = State()
    
    @ObservationIgnored
    @Injected(\.itemDataSource) private var itemDataSource

    // Ideally, wouldn't need to be async, but refresh view stuff requires it.
    func refresh() async {
        if let result = await load(pagination: .first(limit: 10)) {
            state.items = result.entries
        }
    }
    
    func loadMore() {
        guard state.canLoadMore else { return }
        Task {
            if let result = await load(pagination: .first(limit: 10)) {
                self.state.items = (self.state.items ?? []) + result.entries
            }
        }
    }
    
    private func load(pagination: Pagination, ) async -> Pagination.Page<Item>? {
        guard state.itemsFetchStatus != .running
        else { return nil }
        
        state.itemsFetchStatus = .running
        do {
            let page = try await itemDataSource.list(.first(limit: 10))
            state.itemsFetchStatus = .success(page)
            return page
        } catch {
            state.itemsFetchStatus = .failure("FUU")
            return nil
        }
    }
    
    func delete(item: Item) {
        guard state.deleteStatus != .running else { return }
        
        state.itemsFetchStatus = .running
        Task {
            do {
                if let deleted = try await itemDataSource.delete(item.name) {
                    state.deleteStatus = .success(deleted)
                    if let items = state.items {
                        guard let indexOfDeleted = items.firstIndex(of: deleted)
                        else {
                            print("WTF")
                            return
                        }
                        
                        var items = items
                        items.remove(at: indexOfDeleted)
                        state.items = items
                    }
                } else {
                    state.deleteStatus = .failure("not found")
                }
            } catch {
                state.deleteStatus = .failure("asda")
            }
        }
    }
    
    func add() {
        state.detail = .init()
    }
    
    func select(item: Item) {
        guard state.deleteStatus != .running else { return }
        
        state.detail = .init(item: item)
    }
}

extension Container {
    var itemListViewModel: Factory<ItemListViewModel> {
        self { ItemListViewModel() }
    }
}
