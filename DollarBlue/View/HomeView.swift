//
//  HomeView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct HomeView: View {
    //MARK: - PROPERTIES
    
    private var dataController = DolarNetworkManager()
    
    
    //MARK: - BODY
    var body: some View {
        NavigationStack {
            HStack {
                Image("ImageFranklin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 65, height: 75)
                Text("Dólare$")
                    .font(.system(size: 39))
                    .fontWeight(.bold)
                    .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                    .padding()
                Image("ImageRoca")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(x: -1, y: 1, anchor: .center)
                    .frame(width: 65, height: 78)
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 1) {
                    ForEach(dataController.cotizaciones, id: \.nombre) { dolarInfo in
                        DollarRowView(dolarInfo: dolarInfo)
                    }
                }
            }
            
            Spacer()
                .onAppear {
                    dataController.obtainAllCotizations()
                }
            if let lastUpdate = dataController.cotizaciones.last {
                UpdateInfoView(dolarInfo: lastUpdate)
                    .padding()
            }
        }
        .backgroundStyle(.dolarWhiteB)
    }
}



//MARK: - PREVIEW

#Preview {
    HomeView()
}
