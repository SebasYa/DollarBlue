//
//  CalculatorView.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//


import SwiftUI

struct CalculationView: View {
    //MARK: -   PROPERTIES
    
    private var dataController = DolarNetworkManager()
    
    @State  var isCalcPesos : Bool = true
    @State var montoIngresadoString: String = ""
    @State var montoIngresado: Double = 0
    
    //MARK: - BODY
    var body: some View {
        NavigationStack{
            ZStack {
                Spacer()
                Text("Calculadora")
                    .font(.system(size: 39))
                    .fontWeight(.bold)
                    .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
            }
            .padding(.bottom,5)
            
            
            VStack {
                Text("Convertir a...")
                    .font(.title2)
                    .foregroundStyle(Color("ColorGreenD"))
                    .padding()
                
                GroupBox {
                    HStack {
                        Text("Dólares")
                            .foregroundColor(isCalcPesos ? .white : .black)
                            .padding(.leading, 5)
                        
                        Spacer()
                        
                        Text("Pesos")
                            .foregroundColor(.white)
                            .padding(.trailing, 10)
                    }
                    .padding()
                    .background(
                        ZStack {
                            Capsule()
                                .fill(Color("CapsuleColor"))
                                .frame(height: 60)
                            HStack {
                                if isCalcPesos {
                                    Spacer()
                                }
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(isCalcPesos ? Color("RearBlueColor") : Color.green)
                                    .frame(width: 100, height: 50)
                                if !isCalcPesos {
                                    Spacer()
                                }
                            }
                        }
                    )
                    .onTapGesture {
                        withAnimation {
                            isCalcPesos.toggle()
                        }
                    }
                    .cornerRadius(25)
                    .padding()
                
                    CurrencyTextField(
                        text: $montoIngresadoString,
                        value: $montoIngresado,
                        placeholder: isCalcPesos ?
                        "Ingrese la Cantidad de Dolares" : "Ingrese la Cantidad de Pesos"
                                     )
                    .frame(height: 19)
                    .font(.title3)
                    .foregroundStyle(.linearGradient(colors: [.green, Color("DolarBWColor")], startPoint: .top, endPoint: .bottom))
                    
                }
                .padding(.top, -26)
            }
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 1) {
                    ForEach(dataController.cotizaciones, id: \.nombre) { dolarInfo in
                        CalcRowView(dolarInfo: dolarInfo,  montoIngresado: $montoIngresado, isCalcPesos: $isCalcPesos)
                    }
                }
            }
            Spacer()
                .onAppear {
                    Task{
                        dataController.obtainAllCotizations()
                    }
                }
        }
        .backgroundStyle(.dolarWhiteB)
    }
}


func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}


//MARK: - PREVIEW
#Preview {
    CalculationView()
}
