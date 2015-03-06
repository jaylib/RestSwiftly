//
//  Protocols.swift
//  RestSwiftly
//
//  Created by Josef Materi on 01.03.15.
//  Copyright (c) 2015 iPOL GmbH. All rights reserved.
//

import UIKit
import Moya
import ObjectMapper

public protocol FetchResultMapping : MoyaTarget {
    var fetchResult: Mappable  { get }
    var rootElement: String? { get }
}

public protocol FetchResult { }