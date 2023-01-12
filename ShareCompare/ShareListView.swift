//
//  ListLoading.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//

import SwiftUI


struct ListingStatus: Codable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let exchange: String
    let assetType: String
    let ipoDate: String
    let delistingDate: String
    let status: String
    
    init?(csv: String) {
        let fields = csv.components(separatedBy: ",")
        guard fields.count == 7 else { return nil }
        self.id = fields[0]
        self.symbol = fields[0]
        self.name = fields[1]
        self.exchange = fields[2]
        self.assetType = fields[3]
        self.ipoDate = fields[4]
        self.delistingDate = fields[5]
        self.status = fields[6]
    }
}

struct SharesListView: View {
    var sharesList: [ListingStatus]
    @Binding public var portfolioList: [ListingStatus]
    
    
    var body: some View {
        
        List(sharesList) { share in
            HStack {
                VStack(alignment: .leading) {
                    Text("\(share.name)")
                        .font(.headline)
                    Text(share.id)
                    
                }
                
                Spacer()
                
                Button {
                    portfolioList.append(share)
                } label: {
                    Image(systemName: "star")
                }
            }
            
        }
    }
}

//
//struct SharesListView_Previews: PreviewProvider {
//    static var listing = [ListingStatus]()
//    static var previews: some View {
//        SharesListView(sharesList: [ListingStatus](), portfolioList: )
//    }
//}
