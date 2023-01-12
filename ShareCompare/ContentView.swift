//
//  ContentView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//

import SwiftUI



struct ContentView: View {
    let apiKey = "A0WDSRUSNYSK2H4M"
    
    @State private var sharesList = [ListingStatus]()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink {
                    StockSelectionView()
                } label: {
                    Text("Select stocks")
                }
            }
            .navigationTitle("ShareCompare")
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
