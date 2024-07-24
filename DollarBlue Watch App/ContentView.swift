//
//  ContentView.swift
//  DollarBlueW Watch App
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct ContentView: View {
    
    private var dataController = DolarNetworkManager()

    var body: some View {
        NavigationStack {
            List {
                ForEach(dataController.cotizaciones, id: \.nombre) { dolarInfo in
                    DollarRowView(dolarInfo: dolarInfo)
                        .listRowBackground(Color.black)
                        .ignoresSafeArea(.all)
                }
            }
            .onAppear {
                dataController.obtainAllCotizations()
            }
            .navigationTitle("DoLaRe$")
            
        }
    }
}

#Preview {
    ContentView()
}

