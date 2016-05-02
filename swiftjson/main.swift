//
//  main.swift
//  swiftjson
//
//  Created by 朱 一和 on 16/4/28.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import Foundation

print("Hello, World!")

let s = "\n";

for var i = s.characters.startIndex; i < s.characters.endIndex; i = i.successor()
{
    print("ith character: \(i)")
    print(s[i]);
}