//
//  StringExtensions.swift
//  RestSwiftly
//
//  Created by Josef Materi on 01.03.15.
//  Copyright (c) 2015 iPOL GmbH. All rights reserved.
//

import UIKit

public extension String {
    var URLEscapedString: String {
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLHostAllowedCharacterSet())!
    }
}

public extension String {
    public func remove_ids() -> String {
        return self.stringByReplacingOccurrencesOfString("_ids", withString: "s", options: NSStringCompareOptions.allZeros, range:nil)
    }
}