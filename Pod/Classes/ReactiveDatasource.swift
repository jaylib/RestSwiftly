//
//  Datasource+Signal.swift
//  RestSwiftlyCocoaPods
//
//  Created by Josef Materi on 03.03.15.
//  Copyright (c) 2015 iPOL GmbH. All rights reserved.
//

import UIKit
import ReactiveCocoa
import LlamaKit
import Moya
import ObjectMapper
import ExSwift

public class ReactiveDatasource<T: FetchResultMapping> : Datasource<T>  {
    
    private var provider : ReactiveMoyaProvider<T>
    
    init(provider: ReactiveMoyaProvider<T>, defaultParameters: [String : AnyObject] = [:]) {
        self.provider = provider
        super.init(provider: provider, defaultParameters: defaultParameters)
    }
    
    convenience init(defaultParameters: [String: AnyObject] = [:], headerFields: [String : String] = [:]) {
        
        let endpointsClosure = { (target: T, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<T> in
            return Endpoint<T>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: parameters, parameterEncoding: .URL, httpHeaderFields:headerFields)
        }
        let provider = ReactiveMoyaProvider(endpointsClosure: endpointsClosure)
        self.init(provider: provider, defaultParameters: defaultParameters)
    }
    
    
    // Mark: Designated Request Method
    func request(token: T, method: Moya.Method, parameters: [String : AnyObject]) -> Signal<Mappable, NSError> {
        let mergedParameters =  defaultParameters | parameters
        return self.provider.request(token, method: method, parameters: mergedParameters) |> mapJSON |> mapModels { return token }
    }
    
    func fetch(token: T, parameters: [String: AnyObject] = [:]) -> Signal<Mappable, NSError> {
        return self.request(token, method: .GET, parameters: parameters)
    }
    
    public func test(token: T, method: Moya.Method, parameters: [String : AnyObject]) -> Signal<Mappable, NSError>  {
        let mergedParameters =  defaultParameters | parameters
        return self.provider.request(token, method: method, parameters: mergedParameters) |> mapJSON |> mapModels { return token }
    }
    
}

public func mapModels<T: FetchResultMapping>(operation: () -> T)(signal: Signal<AnyObject, NSError>) -> Signal<Mappable, NSError> {
    return signal |> tryMap(toObject(operation))
}

public func mapJSON(signal: Signal<MoyaResponse, NSError>) -> Signal<AnyObject, NSError> {
    return signal |> tryMap(toJSON)
}

