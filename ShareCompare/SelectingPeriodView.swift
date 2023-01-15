////
////  SelectingPeriodView.swift
////  ShareCompare
////
////  Created by Ярослав Грогуль on 14.01.2023.
////
//
//import SwiftUI
//
//struct SelectingPeriodView: View {
//    
//    var portfolio: [StockShare]
//    
//    init() {
//        guard let savedPortfolio = UserDefaults.standard.data(forKey: "portfolio") else {
//            self.portfolio = [StockShare]()
//            return
//        }
//        
//        guard let decoded = try? JSONDecoder().decode([StockShare].self, from: savedPortfolio) else {
//            self.portfolio = [StockShare]()
//            return
//        }
//        
//        self.portfolio = decoded
//    }
//    
//    var body: some View {
//        List {
//            ForEach(portfolio) { stock in
////                <#body#>
//            }
//        }
//    }
//}
//
//struct SelectingPeriodView_Previews: PreviewProvider {
//    static var previews: some View {
//        SelectingPeriodView()
//    }
//}
