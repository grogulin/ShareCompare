//
//  ContentView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//

import SwiftUI



struct ContentView: View {
    
//    @State private var sharesList = [ListingStatus]()
    @State private var period = 1
    
    var portfolio: [StockShare]
    var periods = [1,2,5,10]
    
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
                NavigationLink {
                    CompareView()
                } label: {
                    Text("Benchmark your portfolio")
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("ShareCompare")
        }
        .toolbar(.hidden)
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
