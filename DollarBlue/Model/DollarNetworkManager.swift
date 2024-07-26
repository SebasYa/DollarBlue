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
import Network

@Observable class DolarNetworkManager {
    
    var cotizaciones = [DollarInfoModel]()
    var errorMessage: IdentifiableString?
    
    private var monitor: NWPathMonitor?
    private var isConnected: Bool = false
    
    init() {
        monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor?.pathUpdateHandler = { path in
            self.isConnected = (path.status == .satisfied)
        }
        monitor?.start(queue: queue)
    }
    
    func obtainAllCotizations() {
        guard isConnected else {
            DispatchQueue.main.async {
                self.errorMessage = IdentifiableString(value: "No internet connection.")
            }
            return
        }
        
        guard let url = URL(string: "https://dolarapi.com/v1/dolares") else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableString(value: "Network error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableString(value: "Invalid response from server")
                }
                return
            }
            
            guard let safeData = data else {
                DispatchQueue.main.async {
                    self.errorMessage = IdentifiableString(value: "No data received from server")
                }
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

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}
