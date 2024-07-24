//
//  DollarNetworkManager.swift
//  DollarBlue
//
//  Copyright © 2024 The SY Repository. All rights reserved.
//
//  Created by Sebastián Yanni.
//

import Foundation
import Observation

@Observable class DolarNetworkManager {
    
    var cotizaciones = [DollarInfoModel]()
    
    func obtainAllCotizations() {
        
        guard let url = URL(string: "https://dolarapi.com/v1/dolares") else {
            print("Invalid URL")
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Invalid response from server")
                return
            }
            
            guard let safeData = data else {
                print("No data received from server")
                return
            }
            let decoder = JSONDecoder()
            do{
                let dolarInfo = try decoder.decode([DollarInfoModel].self, from: safeData)
                DispatchQueue.main.async {
                    self.cotizaciones = dolarInfo
                }
            }catch{
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}
