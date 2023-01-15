//
//  SetProportionsView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 14.01.2023.
//

import SwiftUI

struct StockShare: Identifiable, Equatable, Codable {
    var id = UUID()
    let stock: ListingStatus
    var share: Double
}

struct SetProportionsView: View {
    var portfolioList: [ListingStatus]
    @State private var stocksAndShares: [StockShare]
    @State private var test = 0.0
    @State private var shares: [String: Double] {
        didSet {
//            for stock in stocksAndShares {
//                stocksAndShares[stocksAndShares.firstIndex(of: stock) ?? 0].share = shares[stock.stock.symbol] ?? 0.0
//            }
//
//            UserDefaults.standard.object(forKey: "portfolio")
            print("##Saved!")
        }
    }
    
    init(portfolioList: [ListingStatus]) {
        self.portfolioList = portfolioList
        
        var tempStockShare = [StockShare]()
        var tempShares = [String: Double]()
        for stock in portfolioList {
            tempStockShare.append(
                StockShare(stock: stock, share: Double(1/portfolioList.count))
            )
//            shares.append(Double(100/portfolioList.count))
            tempShares[stock.symbol] = Double(1/portfolioList.count)
        }
        
        stocksAndShares = tempStockShare
        shares = tempShares
    }
    
    var body: some View {
        List(stocksAndShares) {element in
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(element.stock.name)")
                            .font(.headline)
                        Text(element.stock.id)
//                        Text("\(shares[element.stock.symbol] ?? 0.0)")

                    }
                    Spacer()
                }
                

                Divider()

                TextField("Share", value: $shares[element.stock.symbol], format: .percent)

            }
        }
        .toolbar {
            NavigationLink {
                ContentView()
                    .onAppear {
                        for stock in stocksAndShares {
                            stocksAndShares[stocksAndShares.firstIndex(of: stock) ?? 0].share = shares[stock.stock.symbol] ?? 0.0
                        }
                        
                        let data = try? JSONEncoder().encode(stocksAndShares)
                        UserDefaults.standard.set(data, forKey: "portfolio")
                        print("Saved!")
                    }
            } label: {
                Text("Finish")
            }
        }
    }
}

struct SetProportionsView_Previews: PreviewProvider {
    static var previews: some View {
        SetProportionsView(portfolioList: [ListingStatus]())
    }
}
