//
//  DealersAndVehiclesWorker.swift
//  CarLister
//
//  Created by Tyler Hays on 4/22/19.
//  Copyright © 2019 Tyler Hays. All rights reserved.
//

import UIKit

protocol  DealersAndVehiclesWorkerDelegate {
    func dealersAndVehiclesWorkerComplete(_ worker:DealersAndVehiclesWorker,
                                          dataResponse: DealerVehicleCallResponse )
    func dealersAndVehiclesWorker(_ worker:DealersAndVehiclesWorker, updateMessage:String)
}

struct DealerVehicleCallResponse {
    let dealerships: [Dealership]?
    let vehicleIdsFailedToLoad: [Int]?
    let dealershipsIdFailedToLoad: [Int]?
    let responseStatus: DealersVehiclesResponseStatus
    
    init(dealership: [Dealership]? = nil,
         vehicleIdsFailedToLoad: [Int]? = nil,
         dealershipsIdFailedToLoad: [Int]? = nil,
         responseStatus: DealersVehiclesResponseStatus) {
        self.dealerships = dealership
        self.vehicleIdsFailedToLoad = vehicleIdsFailedToLoad
        self.dealershipsIdFailedToLoad = dealershipsIdFailedToLoad
        self.responseStatus = responseStatus
    }
}

enum DealersVehiclesResponseStatus {
    case successfull, error, errorOnSomeRecords
}

class DealersAndVehiclesWorker {
    
    var workerDelegate: DealersAndVehiclesWorkerDelegate?
    
    struct DatasetId: Codable {
        let datasetId: String
    }
    
    struct VehiclesIdList: Codable {
        let vehicleIds: [Int]
    }
    
    init(workerDelegate: DealersAndVehiclesWorkerDelegate) {
        self.workerDelegate = workerDelegate
    }
   
    private static let urlBaseAPI = "https://vautointerview.azurewebsites.net/api/"
    
    func fetchData() {
        getDatasetId(onSuccess: {datasetId in
            self.loadVechicleAndDealershipData(datasetId: datasetId.datasetId)
        }, errorHandler: {
           self.completedWithFailureError()
        })
    }
    
    private func loadVechicleAndDealershipData(datasetId: String) {
        self.getVechicleList(dataSetId: datasetId, onSuccess: {
            vechicles, vechicleErrorIds  in
            self.processAndLoadDealerShips(from: vechicles,
                                           datasetId: datasetId,
                                           completation: { dealerships, dealerIdErrors  in
                                            
                                            self.completedGatherData(dealerships: dealerships,
                                                                     vechicleIdErrors: vechicleErrorIds,
                                                                     dealershipErrorId: dealerIdErrors)
                
            })
            
        },
                             errorHandler: {
                                self.completedWithFailureError()
        })
    }
    
    private func getDatasetId(onSuccess: @escaping (DatasetId) -> Void, errorHandler: @escaping () -> Void) {
        
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
    
    private func getVechicleList(dataSetId:String, onSuccess: @escaping ([Vechicle], _ errorIds:[Int]) -> Void, errorHandler: @escaping () -> Void) {
        self.workerDelegate?.dealersAndVehiclesWorker(self, updateMessage: "Gather Vechicle Ids")
        
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
                onSuccess(vechicles, errorIds)
            }
            )
        }
        task.resume()
    }
    
    private func fetchVechicleData(from vehicileIdList: VehiclesIdList, datasetId: String, completation:@escaping ([Vechicle], _ errorVechicleIds: [Int]) -> Void ) {
        
        self.workerDelegate?.dealersAndVehiclesWorker(self, updateMessage: "Getting Vechicle Data")
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
            let sortedVechicles = vechicles.sorted{$0.vechicleId > $1.vechicleId}
            completation(sortedVechicles, errorIdList)
        }
    }
    
    
    private func fetchVechicleData(for vechicleDataRequest:URLRequest, onSuccess: @escaping (VehicleData) -> Void, errorHandler: @escaping () -> Void) {
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
    
    
    private func processAndLoadDealerShips(from vechicles: [Vechicle], datasetId: String, completation:@escaping (([Dealership], _ loadErrorId: [Int]) -> Void))  {
        
        self.workerDelegate?.dealersAndVehiclesWorker(self, updateMessage: "Getting Dealership data")
        let downloadGroup = DispatchGroup()
        let baseGetDealerApi = DealersAndVehiclesWorker.urlBaseAPI + datasetId
            + "/dealers/"
        let dealerIdSet = Set(vechicles.map {$0.dealershipId})
        var errorIdList: [Int] = []
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
                    let dealerVechicles = vechicles.filter({return $0.dealershipId == dealerId})
                    
                    let dealership = Dealership.init(dealerData: dealershipData, vechicles:dealerVechicles)
                    dealerships.append(dealership)
                    downloadGroup.leave()
                }, onError: {
                    errorIdList.append(dealerId)
                    downloadGroup.leave()
                })
            })
            
            blocks.append(block)
            DispatchQueue.main.async(execute: block)
        }
        
          downloadGroup.notify(queue: DispatchQueue.main) {
            let sortedDealers = dealerships.sorted{ $0.dealerId > $1.dealerId }
             completation(sortedDealers, errorIdList)
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
    
    private func completedGatherData(dealerships:[Dealership], vechicleIdErrors:[Int], dealershipErrorId:[Int]) {
        let responseStatus: DealersVehiclesResponseStatus
        if (vechicleIdErrors.isEmpty && dealershipErrorId.isEmpty){
            responseStatus = .successfull
        } else {
            responseStatus = .errorOnSomeRecords
        }
        let responseData = DealerVehicleCallResponse(dealership: dealerships,
                                                     vehicleIdsFailedToLoad: vechicleIdErrors,
                                                     dealershipsIdFailedToLoad: dealershipErrorId,
                                                     responseStatus: responseStatus)
        self.workerDelegate?.dealersAndVehiclesWorkerComplete(self, dataResponse: responseData)
    }
    
    private func completedWithFailureError() {
        let responseData = DealerVehicleCallResponse(responseStatus: .error)
        self.workerDelegate?.dealersAndVehiclesWorkerComplete(self, dataResponse: responseData)
    }

}
