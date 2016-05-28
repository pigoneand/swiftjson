//
//  common_string_extension.swift
//  swiftjson
//
//  Created by 朱 一和 on 16/5/1.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import Foundation

extension String
{
    var length: Int {
        get {
            return self.characters.count;
        }
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil) ? true : false
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = startIndex.advancedBy(i)
            return self[index]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        let start = self.startIndex.advancedBy(startIndex)
        let end = self.startIndex.advancedBy(min(startIndex + length, self.length))
        return self.substringWithRange(start..<end)
    }
}