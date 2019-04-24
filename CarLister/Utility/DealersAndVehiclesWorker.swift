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
    
    func loadData() {
        getDatasetId(onSuccess: {datasetId in
            self.getVechicleList(dataSetId: datasetId.datasetId, onSuccess: {
                vechicles in
                self.processAndLoadDealerShips(from: vechicles, datasetId: datasetId.datasetId, completation: { (dealerships) in
                    
                })
                
            },
                            errorHandler: {}
            )
        }, errorHandler: {})
    }
    
    func getDatasetId(onSuccess: @escaping (DatasetId) -> Void, errorHandler: @escaping () -> Void) {
        
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
            
            onSuccess(datasetData)
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
            self.fetchVechicleData(from: datasetData, datasetId: dataSetId, completation: { (vechicles, errorIds) in
                onSuccess(vechicles)
            }
            )
           // onSuccess()
        }
        task.resume()
    }
    
    func fetchVechicleData(from vehicileIdList: VehiclesIdList, datasetId: String, completation:@escaping ([Vechicle], _ errorVechicleIds: [Int]) -> Void ) {
        let downloadGroup = DispatchGroup()
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
            
            downloadGroup.enter()
            let block = DispatchWorkItem( flags: .inheritQoS, block: {
                
                self.fetchVechicleData(for: urlRequest, onSuccess: {vechicleData in
                    let vechicle = Vechicle(vechicleData: vechicleData)
                    vechicles.append(vechicle)
                    downloadGroup.leave()
                }, errorHandler: {
                    errorIdList.append(vehicleId)
                    downloadGroup.leave()
                    })
                
            })
            
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            completation(vechicles, errorIdList)
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
    
    
    func processAndLoadDealerShips(from vechicles: [Vechicle], datasetId: String, completation:@escaping (([Dealership]) -> Void))  {
        let downloadGroup = DispatchGroup()
        let baseGetDealerApi = DealersAndVehiclesWorker.urlBaseAPI + datasetId
            + "/dealers/"
        let dealerIdSet = Set(vechicles.map {$0.dealershipId})
        
        var dealerships: [Dealership] = []
        
        var blocks: [DispatchWorkItem] = []
        for dealerId in dealerIdSet {
            let dealerApi = baseGetDealerApi + "\(dealerId)"
            guard let apiUrl = URL(string: dealerApi) else {
                continue
            }
            let urlRequest = URLRequest(url: apiUrl)
            downloadGroup.enter()
            let block = DispatchWorkItem( flags: .inheritQoS, block: {
               
                self.fetchDealershipData(for: urlRequest, onSuccess: {dealershipData in
                    let dealerVechicles = vechicles.filter{return $0.dealershipId == dealerId}
                    let dealership = Dealership.init(dealerData: dealershipData, vechicles:dealerVechicles)
                    dealerships.append(dealership)
                    downloadGroup.leave()
                }, onError: {
//                    errorIdList.append(vehicleId)
                    downloadGroup.leave()
                })
                
            })
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
          downloadGroup.notify(queue: DispatchQueue.main) {
             completation(dealerships)
        }
    }
    
    
    func fetchDealershipData(for dealerDataRequest:URLRequest,
                             onSuccess:@escaping((DealershipData) -> Void),
                             onError: @escaping () -> Void) {
        let session = URLSession.shared
        let task = session.dataTask(with: dealerDataRequest) {
            (data, response, error) in
            
            guard  error == nil,
                let responseData = data else {
                    onError()
                    return
            }
            
            guard let vehicleData = try? JSONDecoder().decode(DealershipData.self, from: responseData) else {
                onError()
                return
            }
            
            onSuccess(vehicleData)
        }
        
        task.resume()
        
    }

}
