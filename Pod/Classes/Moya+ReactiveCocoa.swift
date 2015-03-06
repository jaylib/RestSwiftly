//
//  Moya+ReactiveCocoa.swift
//  RestSwiftlyCocoaPods
//
//  Created by Josef Materi on 04.03.15.
//  Copyright (c) 2015 iPOL GmbH. All rights reserved.
//

import Moya
import ReactiveCocoa

public class MoyaResponse: NSObject {
    public let statusCode: Int
    public let data: NSData
    public let response: NSURLResponse?
    
    public init(statusCode: Int, data: NSData, response: NSURLResponse?) {
        self.statusCode = statusCode
        self.data = data
        self.response = response
    }
}

extension MoyaResponse: Printable, DebugPrintable {
    override public var description: String {
        return "Status Code: \(statusCode), Data Length: \(data.length)"
    }
    
    override public var debugDescription: String {
        return description
    }
}

public class ReactiveMoyaProvider<T where T: MoyaTarget>: MoyaProvider<T> {
    
    public var inflightRequests = Dictionary<Endpoint<T>, Signal<MoyaResponse, NSError>>()
    
    public init(endpointsClosure: MoyaEndpointsClosure) {
        super.init(endpointsClosure: endpointsClosure)
    }

    // Designated request method
    
    public func request(token: T, method: Moya.Method, parameters: [String: AnyObject]) -> Signal<MoyaResponse, NSError> {
        
        let endpoint = self.endpoint(token, method: method, parameters: parameters)

        if let existingSignal = self.inflightRequests[endpoint] {
            return existingSignal
        }
        
        var signal: Signal<MoyaResponse, NSError> = Signal { [weak self] observer in
            
            self?.request(token, method: method, parameters: parameters) { (data, statusCode, response, error) -> () in
                if let error = error {
                    if let statusCode = statusCode {
                        sendError(observer, NSError(domain: error.domain, code: statusCode, userInfo: error.userInfo))
                    } else {
                        sendError(observer, error)
                    }
                } else {
                    if let data = data {
                        sendNext(observer, MoyaResponse(statusCode: statusCode!, data: data, response: response))
                    }
                    sendCompleted(observer)
                }
            }
            
            return ActionDisposable() {
                self?.inflightRequests[endpoint] = nil
            }
        }
        
        self.inflightRequests[endpoint] = signal
        
        return signal
    }
    
    public func request(token: T, parameters: [String: AnyObject]) -> Signal<MoyaResponse, NSError> {
        return request(token, method: Moya.DefaultMethod(), parameters: parameters)
    }
    
    public func request(token: T, method: Moya.Method) -> Signal<MoyaResponse, NSError>  {
        return request(token, method: method, parameters: Moya.DefaultParameters())
    }
    
    public func request(token: T) -> Signal<MoyaResponse, NSError>  {
        return request(token, method: Moya.DefaultMethod())
    }
}



