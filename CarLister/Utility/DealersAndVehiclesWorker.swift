//
//  DealersAndVehiclesWorker.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

class DealersAndVehiclesWorker {
    
    struct DatasetId: Codable {
        let datasetId: String
    }
    
    struct VehiclesIdList: Codable {
        let vehicleIds: [Int]
    }
    
    private static let urlBaseAPI = "https://vautointerview.azurewebsites.net/api/"
    
    func getDatasetId(onSuccess: @escaping ([Dealership]) -> Void, errorHandler: @escaping () -> Void) {
        
        let urlString = DealersAndVehiclesWorker.urlBaseAPI + "datasetId"
        guard let dataURL = URL(string: urlString) else {
            errorHandler()
            return
        }
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: dataURL)
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard  error == nil else {
                errorHandler()
                return
            }
            
            guard let responseData = data else {
                errorHandler()
                return
            }
            
            guard let datasetData : DatasetId = try? JSONDecoder().decode(DatasetId.self, from: responseData) else {
                errorHandler()
                return
            }
            
            onSuccess()
        }
        
        task.resume()
    }
    
    func getVechicleList(dataSetId:String, onSuccess: @escaping ([Vechicle]) -> Void, errorHandler: @escaping () -> Void) {
        
        let urlString = DealersAndVehiclesWorker.urlBaseAPI + dataSetId + "/vehicles"
        guard let dataURL = URL(string: urlString) else {
            errorHandler()
            return
        }
        
        let session = URLSession.shared
        let urlRequest = URLRequest(url: dataURL)
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard  error == nil else {
                errorHandler()
                return
            }
            
            guard let responseData = data else {
                errorHandler()
                return
            }
            
            guard let datasetData : VehiclesIdList = try? JSONDecoder().decode(VehiclesIdList.self, from:
                responseData) else {
                errorHandler()
                return
            }
            onSuccess()
        }
        task.resume()
    }
    
    func fetchVechicleData(from vehicileIdList: VehiclesIdList, datasetId: String) {
        let vechicleDownloadGroup = DispatchGroup()
        let baseVechicleApi = DealersAndVehiclesWorker.urlBaseAPI + datasetId
            + "/vehicles/"
        
        var blocks: [DispatchWorkItem] = []
        var vechicles: [Vechicle] = []
        var errorIdList: [Int] = []
        for vehicleId in vehicileIdList.vehicleIds {
            let vechicleApi = baseVechicleApi + "\(vehicleId)"
            guard let apiUrl = URL(string: vechicleApi) else {
                continue
            }
            let urlRequest = URLRequest(url: apiUrl)
            
            vechicleDownloadGroup.enter()
            let block = DispatchWorkItem( flags: .inheritQoS, block: {
                
                self.fetchVechicleData(for: urlRequest, onSuccess: {vechicleData in
                    let vechicle = Vechicle(vechicleData: vechicleData)
                    vechicles.append(vechicle)
                    vechicleDownloadGroup.leave()
                }, errorHandler: {
                    errorIdList.append(vehicleId)
                    vechicleDownloadGroup.leave()
                    })
                
            })
            
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
        vechicleDownloadGroup.notify(queue: DispatchQueue.main) {
            
        }
    }
    
    
    func fetchVechicleData(for vechicleDataRequest:URLRequest, onSuccess: @escaping (VehicleData) -> Void, errorHandler: @escaping () -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: vechicleDataRequest) {
            (data, response, error) in
            
            guard  error == nil,
              let responseData = data else {
                    errorHandler()
                    return
            }
            
            guard let vehicleData = try? JSONDecoder().decode(VehicleData.self, from: responseData) else {
                errorHandler()
                return
            }
            
            onSuccess(vehicleData)
        }
        
        task.resume()
    }

}
