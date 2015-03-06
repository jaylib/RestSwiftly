//
//  Datasource.swift
//  RestSwiftlyCocoaPods
//
//  Created by Josef Materi on 03.03.15.
//  Copyright (c) 2015 iPOL GmbH. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper
import LlamaKit

public class Datasource<T: FetchResultMapping>  {
   
    private

    var provider : MoyaProvider<T>?
    var httpHeaderFields : [String : AnyObject] = [String: AnyObject]()
    
    public

    typealias LoggingClosure = (log: String) -> ()

    let defaultParameters: [String: AnyObject]
    
    var loggingClosure : LoggingClosure?
    
    init(provider: MoyaProvider<T>, defaultParameters: [String: AnyObject] = [:]) {
        self.provider = provider
        self.defaultParameters = defaultParameters
    }
    
    convenience init(defaultParameters: [String: AnyObject] = [:], headerFields: [String : String] = [:]) {
        
        let endpointsClosure = { (target: T, method: Moya.Method, parameters: [String: AnyObject]) -> Endpoint<T> in
            return Endpoint<T>(URL: url(target), sampleResponse: .Success(200, target.sampleData), method: method, parameters: [:], parameterEncoding: .URL, httpHeaderFields:headerFields)
        }
        let provider = MoyaProvider(endpointsClosure: endpointsClosure)
        self.init(provider: provider, defaultParameters: defaultParameters)
    }
    

    
    func request(token: T, method: Moya.Method, parameters: [String: AnyObject], completion: MoyaCompletion) {
        
        var mergedParameters = self.mergeDictionary(self.defaultParameters, withDictionary: parameters)
        
        if let provider = provider {
            return provider.request(token, method: method, parameters: mergedParameters, completion: completion)
        } else {
            return completion(data: nil, statusCode: nil, response: nil, error: nil)
        }
    }
    
    internal
    
    func mapJSONToMappable(token: T, jsonObject: AnyObject!) -> Mappable? {
        if let json = jsonObject as? Dictionary<String, AnyObject> {
            let object = token.fetchResult
                return SimpleMapper().map(json: json, toObject: object)
            
        }
        return nil
    }
    
    func mergeDictionary(dictionary: [String : AnyObject]?, withDictionary: [String : AnyObject]?) -> [String : AnyObject] {
        var mergedParameters : [String: AnyObject] = [:]
        if let defaultParameters = dictionary {
            for (key:String, value:AnyObject) in defaultParameters {
                mergedParameters[key] = value
            }
        }
        if let parameters = withDictionary {
            for (key:String, value:AnyObject) in parameters {
                mergedParameters[key] = value
            }
        }
        return mergedParameters
    }
    
}

public func url(route: MoyaTarget) -> String {
    return route.baseURL.URLByAppendingPathComponent(route.path).absoluteString!
}

func authentication(#user: String, #password: String) -> [String : String] {
    
    let loginString = NSString(format: "%@:%@", user, password)
    let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
    let base64LoginString = loginData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.allZeros)
    
    return ["Authorization" : "Basic \(base64LoginString)"]
}

public func toObject<T: FetchResultMapping>(operation: () -> T)(json: AnyObject) -> Result<Mappable, NSError> {
    
    var token = operation()
    
    var jsonWithRootElement: [String : AnyObject] = Dictionary<String, AnyObject>()
    
    if let value = json as? [String : AnyObject] {
        jsonWithRootElement = value
    } else {
        if let rootElement = token.rootElement {
            jsonWithRootElement[rootElement] = json
        }
    }
    
    let object : Mappable = token.fetchResult
    
    if let mappedResult = SimpleMapper().map(json: jsonWithRootElement, toObject: object) {
        return success(mappedResult)
    } else {
        return failure("FAIL")
    }
    
}

func toJSON(response: MoyaResponse) -> Result<AnyObject, NSError> {
    var error : NSError? = NSError(domain: "", code: 0, userInfo: nil)
    var json: AnyObject?
    json = NSJSONSerialization.JSONObjectWithData(response.data, options: NSJSONReadingOptions.AllowFragments, error: &error)
    if let json = json as? [String : AnyObject] {
        return success(json)
    } else if let json = json as? [AnyObject] {
        return success(json)
    } else {
        return failure(error!)
    }
}

