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
                String($0.id + $0.name).localizedCaseInsensitiveContains(searchText)
                
            }
        }
    }
    
    func loadList(apiKey: String) async {
        do {
            withAnimation {
                loadingStatus = "Loading"
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
        VStack {
            Text("Portfolio count: \(portfolioList.count)")
            
            if loadingStatus == "Loading" {
                LoadingIndicator(title: "Loading all available stocks...")
            } else if loadingStatus == "Finished" {
//                SharesListView(sharesList: searchResults)
                shareListView(sharesList: searchResults)
                    
            }
        }.task {
            await loadList(apiKey: apiKey)
        }
        .navigationTitle("Stocks selection")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Company or Ticker")
        .toolbar {
            NavigationLink {
                SetProportionsView(portfolioList: portfolioList)
            } label: {
                Text("Continue")
            }
            
        }
    }
    
    func shareListView(sharesList: [ListingStatus]) -> some View {
        return List(sharesList) { share in
            HStack {
                VStack(alignment: .leading) {
                    Text("\(share.name)")
                        .font(.headline)
                    Text(share.id)
                    
                }
                
                Spacer()
                
                Button {
                    if portfolioList.contains(share) {
                        portfolioList.remove(at: portfolioList.firstIndex(of: share) ?? 0)
                    } else {
                        portfolioList.append(share)
                    }
                } label: {
                    Image(systemName:
                            portfolioList.contains(share) ? "star.fill" : "star"
                    )
                }
            }
            
        }
    }
}

struct StockSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        StockSelectionView()
    }
}
