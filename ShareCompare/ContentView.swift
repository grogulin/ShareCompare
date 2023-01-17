//
//  ContentView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//

import SwiftUI



struct ContentView: View {
    
//    @State private var sharesList = [ListingStatus]()
    @State private var period = 5
    @State private var compareTo = "SPY"
    
    var portfolio: [StockShare]
    var periods = [1,2,5,10]
    var compareVariants = ["SPY", "QQQ", "FBND"]
    var portfolioProps: [String: Double] {
        var result = [String: Double]()
        for portfolio in portfolio {
            result[portfolio.stock.symbol] = portfolio.share
        }
        
        return result
    }
    var dateStart: String {
        let dateNow = Date.now
        
        var dateComponent = DateComponents()
        dateComponent.year = -period
        
        let futureDate = Calendar.current.date(byAdding: dateComponent, to: dateNow)!
        
        let formatter = DateFormatter()
        formatter.dateFormat = "y-MM-dd"
        
        let result = formatter.string(from: futureDate)
        
        return result
    }
    
    init() {
        guard let savedPortfolio = UserDefaults.standard.data(forKey: "portfolio") else {
            self.portfolio = [StockShare]()
            return
        }
        
        guard let decoded = try? JSONDecoder().decode([StockShare].self, from: savedPortfolio) else {
            self.portfolio = [StockShare]()
            return
        }
        
        self.portfolio = decoded
        
        
    }
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    StockSelectionView()
                } label: {
                    Text("Select stocks")
                }
                HStack {
                    Picker("Select a period", selection: $period) {
                        ForEach(periods, id: \.self) {
                            Text($0 == 1 ? "1 year" : "\($0) years")
                        }
                    }
                }
                HStack {
                    Picker("Select ETF for comparison", selection: $compareTo) {
                        ForEach(compareVariants, id: \.self) { variant in
                            Text(variant)
                        }
                    }
                }
                NavigationLink {
                    CompareView(portfolio: portfolioProps, dateStartString: dateStart, compareTo: compareTo)
                } label: {
                    Text("Benchmark your portfolio")
                        .foregroundColor(.blue)
                }
                Button("Test assets") {
                    print(portfolioProps)
                }
                Button("Test date") {
                    print(dateStart)
                }
            }
            .navigationTitle("ShareCompare")
            .onAppear()
        }
        .toolbar(.hidden)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
