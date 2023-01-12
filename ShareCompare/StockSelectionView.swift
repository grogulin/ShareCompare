//
//  StockSelectionView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//
import SwiftUI



struct StockSelectionView: View {
    let apiKey = "A0WDSRUSNYSK2H4M"
    
    @State private var sharesList = [ListingStatus]()
    @State private var loadingStatus = "Not running"
    @State private var searchText = ""
    @State public var portfolioList = [ListingStatus]()
    
    var searchResults: [ListingStatus] {
        if searchText.isEmpty {
            return sharesList
        } else {
            return sharesList.filter {
                $0.id.localizedCaseInsensitiveContains(searchText) || $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func loadList(apiKey: String) async {
        do {
            withAnimation {
                loadingStatus = "Loading..."
            }
            let url = URL(string: "https://www.alphavantage.co/query?function=LISTING_STATUS&apikey=\(apiKey)")!
            let userData = url.lines.compactMap(ListingStatus.init)

            for try await user in userData {
                if user.id != "symbol" {
                    sharesList.append(user)
                }
            }
            withAnimation {
                loadingStatus = "Finished"
            }
        } catch {
            // Stop adding users when an error is thrown
        }
    }

    
    var body: some View {
        NavigationStack {
            
            if loadingStatus == "Loading..." {
                LoadingIndicator(title: "Loading all available stocks...")
            } else if loadingStatus == "Finished" {
                SharesListView(sharesList: searchResults, portfolioList: $portfolioList)
                    
            }
        }.task {
            await loadList(apiKey: apiKey)
        }
        .navigationTitle("Stocks selection")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Company or Ticker")
    }
}

struct StockSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StockSelectionView()
    }
}
