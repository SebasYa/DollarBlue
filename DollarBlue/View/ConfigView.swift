//
//  ConfigView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//
//  Created by Sebastián Yanni.
//

import SwiftUI

struct ConfigView: View {
    @Binding var isDarkMode: Bool
    
    var body: some View {
        VStack{
            Toggle("Night Mode", isOn: $isDarkMode)
                .font(.title3)
                .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                .padding(.all)
            Spacer()
        }
    }
}

#Preview {
    ConfigView(isDarkMode: .constant(false))
}
