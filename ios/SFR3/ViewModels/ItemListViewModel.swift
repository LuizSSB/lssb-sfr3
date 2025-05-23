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
        
        var itemBeingDeleted: Item?
        var deleteStatus: ActionStatus<Item, String> = .none
        
        var detail: ItemDetailViewModel?
        
        var canLoadMore: Bool {
            guard case let .success(result) = itemsFetchStatus,
                  !result.reachedEnd
            else { return true }
            
            return false
        }
        
        var isLoadingFirstBatch: Bool {
            if case .running = itemsFetchStatus,
               items == nil {
                return true
            }
            return false
        }
        
        var isLoadingMore: Bool {
            if case .running = itemsFetchStatus,
               let items, !items.isEmpty {
                return true
            }
            return false
        }
    }
    
    var state = State()
    
    @ObservationIgnored
    private var notificationCenterObserer: Any?
    
    @ObservationIgnored
    @Injected(\.itemDataSource) private var itemDataSource
    
    init() {
        notificationCenterObserer = NotificationCenter.default.addObserver {
            [weak self] (notification: ItemSavedAppNotification) in
            guard let self else { return }
            Task {
                await self.refresh()
            }
        }
    }
    
    deinit {
        guard let notificationCenterObserer else { return }
        NotificationCenter.default.removeObserver(notificationCenterObserer)
    }

    // Ideally, wouldn't need to be async, but view refreshing stuff requires it.
    func refresh() async {
        if let result = await load(pagination: .first(limit: 10)) {
            update {
                let didAlreadyHaveStuff = self.state.items != nil
                self.state.items = result.entries
                
                // HACK: after refreshing, if nothing has changed, the top items won't be rerendered, and, as such, their onAppear will not be triggered, so if all of the page's results fit into the list, it won't loadMore by itself.
                if didAlreadyHaveStuff {
                    self.loadMore()
                }
            }
        }
    }
    
    func loadMore() {
        guard case let .success(result) = state.itemsFetchStatus,
              !result.reachedEnd
        else { return }
        
        Task {
            if let result = await load(pagination: result.pagination.next) {
                self.update {
                    self.state.items = (self.state.items ?? []) + result.entries
                }
            }
        }
    }
    
    private func load(pagination: Pagination, ) async -> Pagination.Page<Item>? {
        guard state.itemsFetchStatus != .running
        else { return nil }
        
        state.itemsFetchStatus = .running
        do {
            let page = try await itemDataSource.list(pagination)
            state.itemsFetchStatus = .success(page)
            return page
        } catch {
            state.itemsFetchStatus = .failure("Couldn't load entries.")
            return nil
        }
    }
    
    func abandonLoading() {
        state.itemsFetchStatus = .none
    }
    
    func delete(item: Item) {
        guard state.deleteStatus != .running else { return }
        
        state.deleteStatus = .running
        Task {
            state.itemBeingDeleted = item
            defer {
                state.itemBeingDeleted = nil
            }
            do {
                guard let deleted = try await itemDataSource.delete(item.id)
                else {
                    state.deleteStatus = .failure("Item not found")
                    return
                }
                
                state.deleteStatus = .success(deleted)
                guard let items = state.items,
                      let indexOfDeleted = items.firstIndex(of: deleted)
                else { return } // WTF
                
                update {
                    self.state.items!.remove(at: indexOfDeleted)
                    
                    guard case let .success(result) = self.state.itemsFetchStatus
                    else { return }
                
                    self.state.itemsFetchStatus = .success(
                        .init(
                            entries: {
                                var resultEntries = result.entries
                                resultEntries.removeAll { $0.id == item.id }
                                return resultEntries
                            }(),
                            pagination: .init(
                                offset: result.pagination.offset - 1,
                                limit: result.pagination.limit
                            )
                        )
                    )
                }
            } catch {
                state.deleteStatus = .failure("Couldn't delete item \(item.name)")
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
