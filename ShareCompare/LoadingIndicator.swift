//
//  LoadingIndicator.swift
//  ShareCompare
//
//  Created by Ярослав Грогуль on 12.01.2023.
//

import SwiftUI

struct LoadingIndicator: View {
    @State private var angle = 180.0
    let title: String
    
    var body: some View {
        VStack {
            Image("loading")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(angle))
                .onAppear {
                    withAnimation(.linear(duration: 0.5).repeatForever(autoreverses: false)) {
                        angle += 360
                    }
                }
            Text(title)
        }
       
    }
}

struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator(title: "Loading...")
    }
}
