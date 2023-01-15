//
//  CompareView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 14.01.2023.
//

import SwiftUI

struct MetaData: Codable {
    var id = UUID()
    let information: String
    let symbol: String
    let lastRefreshed: String
    let outputSize: String
    let timeZone: String
    
    private enum CodingKeys : String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case outputSize = "4. Output Size"
        case timeZone = "5. Time Zone"
    }
}

struct DayData: Codable, Identifiable {
    var id = UUID()
    let open: String
    let high: String
    let low: String
    let close: String
    let adjustedClose: String
    let volume: String
    let dividendAmount: String
    
    private enum CodingKeys : String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
        case volume = "6. volume"
        case dividendAmount = "7. dividend amount"
    }
}

struct StockData: Codable {
    let metaData: MetaData
    let timeSeriesDaily: [String: DayData]
    
    private enum CodingKeys : String, CodingKey {
        case metaData = "Meta Data"
        case timeSeriesDaily = "Time Series (Daily)"
    }
}


struct CompareView: View {
    @State private var loadingStatus = ""
    @State var stockData: StockData?
    @State var filteredStockData = [String: DayData]()
    
    let apiKey = "A0WDSRUSNYSK2H4M"
    
    
    let testJSON = """
{
    "Meta Data": {
        "1. Information": "Daily Time Series with Splits and Dividend Events",
        "2. Symbol": "AAPL",
        "3. Last Refreshed": "2023-01-13",
        "4. Output Size": "Full size",
        "5. Time Zone": "US/Eastern"
    },
    "Time Series (Daily)": {
        "2023-01-13": {
            "1. open": "130.2800",
            "2. high": "134.9200",
            "3. low": "124.1700",
            "4. close": "134.7600",
            "5. adjusted close": "134.7600",
            "6. volume": "703283811",
            "7. dividend amount": "0.0000"
        },
        "2022-12-30": {
            "1. open": "148.2100",
            "2. high": "150.9199",
            "3. low": "125.8700",
            "4. close": "129.9300",
            "5. adjusted close": "129.9300",
            "6. volume": "1675731304",
            "7. dividend amount": "0.1667"
        }
    }
}
"""

    
    func get_max_date(data: [String: DayData]) -> Double {
        let dates = data.keys.sorted(by: >)
        let lastDate = dates[0]
        print("Getting close price for \(lastDate)")
        
        guard let lastDay = data[lastDate] else {
            fatalError("Close price for \(lastDate) was not found in data")
        }
        
        guard let lastClose = Double(lastDay.close) else {
            fatalError("Can not transform \(lastDay.close) to Double")
        }
        
        print(lastClose)
        
        return lastClose
    }
    
    func get_current_price(ticker: String, apiKey: String) async {
        print("Started loading...")
        withAnimation {
            loadingStatus = "Loading"
        }
        
        let url = URL(string: "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=\(ticker)&outputsize=full&apikey=\(apiKey)")!
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                fatalError("Cannot load JSON from server")
            
            }

            let decoder = JSONDecoder()
            do {
                let stockData = try decoder.decode(StockData.self, from: data)
                DispatchQueue.main.async {
                    self.stockData = stockData
                    
                    for date in stockData.timeSeriesDaily.keys {
                        filteredStockData[date] = stockData.timeSeriesDaily[date]!
                    }
                    
                    print("Finished loading...")
                    
                    get_max_date(data: filteredStockData)
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
        
        withAnimation {
            loadingStatus = "Finished"
        }
        
    }
    var body: some View {
        VStack {
            Text("Here will be comparing view for our selected assets according to the selected horizon")
                .navigationTitle("Benchmarking")
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            
            Button("Test") {
//                guard let data = testJSON.data(using: .utf8) else {
//                    print("Failed to convert JSON to Data")
//                    return
//                }
//
//                guard let decoded = try? JSONDecoder().decode(StockData.self, from: data) else {
//                    print("Failed to decode JSON")
//                    return
//                }
                
                Task {
                    await get_current_price(ticker: "AAPL", apiKey: apiKey)
                }
                
                
                
            }
            
        }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView()
    }
}
