//
//  ItemList.swift
//  SFR3
//
//  Created by Luiz SSB on 18/04/25.
//

import SwiftUI
import Factory

struct ItemListScreen: View {
    @State var viewModel: ItemListViewModel
    
    var body: some View {
        List {
            if viewModel.state.isLoadingFirstBatch {
                ProgressView()
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            
            if let items = viewModel.state.items {
                ForEach(Array(items.enumerated()), id: \.1.name) { offset, item in
                    listItem(offset, item)
                }
            } else if viewModel.state.itemsFetchStatus != .running {
                Text("Pull to refresh")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }
            
            if viewModel.state.isLoadingMore {
                Text("Loading...")
                    .fontWeight(.ultraLight)
                    .fontWidth(.expanded)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresh()
        }
        .navigationTitle("Items (or movies)")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.add()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .firstTask {
            await viewModel.refresh()
        }
        .alert(
            presenting: .constant({
                if case let .failure(error) = viewModel.state.itemsFetchStatus {
                    return error
                }
                return nil
            }()),
            title: { _ in "Failure" },
            message: { error in Text(error) },
            actions: { _ in
                Button("Dismiss") {
                    viewModel.abandonLoading()
                }
            }
        )
        .viewModelFullScreenCover($viewModel.state.detail) {
            ItemDetailScreen(viewModel: $0)
        }
    }
    
    @ViewBuilder func listItem(_ offset: Int, _ item: Item) -> some View {
        let button = Button {
            viewModel.select(item: item)
        } label: {
            HStack {
                Text(item.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if item == viewModel.state.itemBeingDeleted {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
            .onAppear {
                if offset == (viewModel.state.items?.count ?? 0) - 1 {
                    viewModel.loadMore()
                }
            }
        
        if viewModel.state.itemBeingDeleted == nil {
            button
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.delete(item: item)
                    } label: {
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                }
        } else {
            button
        }
    }
}

#Preview {
    NavigationStack {
        ItemListScreen(viewModel: .init())
    }
}
