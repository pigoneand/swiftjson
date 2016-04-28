//
//  IsPrime.swift
//  swiftjson
//
//  Created by 朱 一和 on 16/4/28.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import Foundation

class IsPrime
{
    func isPrime(x: Int) -> Bool
    {
        guard x > 1 else {
            return false;
        }
        
        for i in 2..<x
        {
            if (x % i == 0)
            {
                return false;
            }
        }
        return true;
    }
}