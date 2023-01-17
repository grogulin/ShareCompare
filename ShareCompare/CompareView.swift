//
//  CompareView.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 14.01.2023.
//

import SwiftUI
import Charts

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
    let splitCoefficient: String
    
    private enum CodingKeys : String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
        case volume = "6. volume"
        case dividendAmount = "7. dividend amount"
        case splitCoefficient = "8. split coefficient"
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

struct AssetProp: Equatable {
    let share: Double
    var result: Double
}

struct AssetResult: Identifiable {
    var id = UUID()
    let ticker: String
    let share: Double
    let result: Double
}


struct CompareView: View {
    @State private var loadingStatus = ""
    @State var stockData: StockData?
    @State var filteredStockData = [String: DayData]()
    
    
    let portfolio: [String: Double]
    let dateStartString: String
    let compareTo: String
    
    @State private var comparison = [String: AssetProp]()
    
    @State private var assetResults = [String: AssetProp]()
    var totalResult: Double {
        var result = 0.0
        print(assetResults.keys)
        
        for asset in assetResults.keys {
            result += assetResults[asset]!.result * assetResults[asset]!.share
        }
        
        return round(result*1000.0) / 1000.0
    }
    var resultsList: [AssetResult] {
        var result = [AssetResult]()
        
        for asset in assetResults.keys {
            let assetResult = round(assetResults[asset]!.result*1000.0) / 1000.0
            result.append(AssetResult(ticker: asset, share: assetResults[asset]!.share, result: assetResult))
        }
        
        result = result.sorted { $0.share > $1.share }
        
        return result
    }
    
    let apiKey = "A0WDSRUSNYSK2H4M"
 
    func getPrice (for date: String, data: [String: DayData], closePrice: Bool) -> Double {
        guard let day = data[date] else {
            fatalError("Values for \(date) were not found in data")
        }
        
        guard let doublePrice = Double(closePrice ? day.close : day.open) else {
            fatalError("Can not transform \(closePrice ? day.close : day.open) to Double")
        }
        
        guard let splitCoefficient = Double(day.splitCoefficient) else {
            fatalError("Can not transform \(day.splitCoefficient) to Double")
        }
        
        let result = doublePrice*splitCoefficient
        
        return result
    }
    
    func getLastClose(data: [String: DayData]) -> Double {
        let dates = data.keys.sorted(by: >)
        let lastDate = dates[0]
        
        let result = getPrice(for: lastDate, data: data, closePrice: true)
        
//        print("Close price for \(lastDate): \(result)")
        return result
    }
    
    func getFirstOpen(data: [String: DayData]) -> Double {
        let dates = data.keys.sorted(by: <)
        let firstDate = dates[0]
        
        let result = getPrice(for: firstDate, data: data, closePrice: false)
        
//        print("Open price for \(firstDate): \(result)")
        return result
    }
    
    func getDividendsAmount(data: [String: DayData]) -> Double {
        var result = 0.0
        
        for day in data.keys.sorted() {
            guard let divAmount = Double(data[day]!.dividendAmount) else {
                fatalError("Can not transform \(data[day]!.dividendAmount) into Double")
            }
            if divAmount > 0 {
//                print("Dividends for \(day): \(divAmount)")
                result += divAmount
            }
        }
        
//        print("Total dividends payed since \(dateStartString) is: \(result)")
        return result
    }
    
    func getSplitAmount( data: [String: DayData]) -> Double {
        var result = 1.0
        
        for day in data.keys.sorted() {
            guard let splitAmount = Double(data[day]!.splitCoefficient) else {
                fatalError("Can not transform \(data[day]!.splitCoefficient) into Double")
            }
            if splitAmount > 0 {
//                print("For \(day) split was \(splitAmount)")
                result *= splitAmount
            }
        }
        return result
    }
    
    func getPortfolioResult() {
        Task {
            await getData(for: compareTo, apiKey: apiKey, forComparison: true)
        }
        print(assetResults.keys)
        loadingStatus = "Loading"
        
        for asset in assetResults.keys {
            Task {
                print("Starting procedure for \(asset)")
                await getData(for: asset, apiKey: apiKey, forComparison: false)
    
                
//                totalResult += assetResults[asset]!.result!*assetResults[asset]!.share
//                print("Total result: \(totalResult)")
            }
            
            
        }
        
        
        loadingStatus = "Finished"
    }
    
    
    func getData(for ticker: String, apiKey: String, forComparison: Bool) async {
//        print("Started loading...")
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
                        if date >= dateStartString {
                            filteredStockData[date] = stockData.timeSeriesDaily[date]!
                        }
                    }
                    
                    let lastClosePrice = getLastClose(data: filteredStockData)
                    let divAmount = getDividendsAmount(data: filteredStockData)
                    let startOpenPrice = getFirstOpen(data: filteredStockData)
                    let splitAmount = getSplitAmount(data: filteredStockData)
                    
//                    print("Start open price: \(startOpenPrice). Div: \(divAmount). Last close: \(lastClosePrice). Split Amount: \(splitAmount)")
                    let totalReturn: Double = (lastClosePrice+divAmount)*splitAmount/startOpenPrice
                    print("\(ticker): for the period from \(dateStartString) to \(Date()): \(totalReturn)")
                    let share = forComparison ? 1.0 : assetResults[ticker]!.share
                    
                    print("Total return for \(ticker): \(totalReturn)")
                    
                    withAnimation {
                        if forComparison {
                            let totalReturnRounded = round(totalReturn*1000)/1000
                            
                            comparison[ticker] = AssetProp(share: share, result: totalReturnRounded)
                        } else {
                            assetResults[ticker] = AssetProp(share: share, result: totalReturn)
                        }
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
        
        withAnimation {
            loadingStatus = "Finished"
        }
        
    }
    
    func getBarMark(name: String, value: Double, customColor: Color?) -> some ChartContent {
        return BarMark(
            x: .value("Asset", name),
            y: .value("gain (%)", value)
        )
        .annotation(position: .top, alignment: .center) {
            Text("\(value.formatted(.percent))")
                .font(.footnote)
        }
        .foregroundStyle(
            customColor ?? (value >= 0 ? Color.green : Color.red)
        )
    }
    
    
    
    
    var body: some View {
        VStack {
            if loadingStatus == "Loading" {
                LoadingIndicator(title: "Estimating Total Return for your portfolio...")
            } else {
                List {
                    Text("Return by asset")
                        .font(.system(.largeTitle, weight: .bold))
                    Chart {
                        getBarMark(name: compareTo, value: (comparison[compareTo, default: AssetProp(share: 1.0, result: 0.0)].result - 1.0), customColor: .orange)
                        getBarMark(name: "Total", value: (totalResult - 1.0), customColor: nil)
                        ForEach(resultsList) { result in
                            getBarMark(name: result.ticker, value: (result.result - 1.0), customColor: nil)
                        }
                    }
                    
                    Text("Return by asset and weight")
                        .font(.system(.largeTitle, weight: .bold))
                    Chart {
                        getBarMark(name: compareTo, value: (comparison[compareTo, default: AssetProp(share: 1.0, result: 0.0)].result - 1.0), customColor: .orange)
                        getBarMark(name: "Total", value: (totalResult - 1.0), customColor: nil)
                        ForEach(resultsList) { result in
                            getBarMark(name: result.ticker, value: ((result.result - 1.0) * result.share), customColor: nil)
                        }
                        
                    }
                    
                }
                
            }
            
        }
        .navigationTitle("Benchmarking")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            for ticker in portfolio.keys {
                assetResults[ticker] = AssetProp(share: portfolio[ticker]!, result: 0.0)
            }
            
            comparison[compareTo] = AssetProp(share: 1.0, result: 0.0)
            print(comparison)
            
            getPortfolioResult()
            
        }
    }
}

struct CompareView_Previews: PreviewProvider {
    static var previews: some View {
        CompareView(portfolio: ["AAPL": 1.0], dateStartString: "2022-10-30", compareTo: "QQQ")
    }
}
