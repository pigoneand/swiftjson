//
//  json_lexer.swift
//  swiftjson
//
//  Created by pigoneand on 16/4/30.
//  Copyright © 2016年 pigoneand. All rights reserved.
//

import Foundation

/**
 * Json 的词法Token, 每个token为json的基本词法单位，注意到一个有效的json可以用 [Token] 来描述。
 * 例如： { "name": "pigoneand" } = [ BEGIN_OBJECT, STRING, NAME_SEPARATOR, STRING, END_OBJECT ]
 * ref http://www.ietf.org/rfc/rfc4627.txt
 */
enum JsonLexToken
{
    case BEGIN_ARRAY        // [
    case END_ARRAY          // ]
    case BEGIN_OBJECT       // {
    case END_OBJECT         // }
    case NAME_SEPARATOR     // :
    case VALUE_SEPARATOR    // ,
    
    /*
     string = quotation-mark *char quotation-mark
 
     char = unescaped /
     escape (
     %x22 /          ; "    quotation mark  U+0022
     %x5C /          ; \    reverse solidus U+005C
     %x2F /          ; /    solidus         U+002F
     %x62 /          ; b    backspace       U+0008
     %x66 /          ; f    form feed       U+000C
     %x6E /          ; n    line feed       U+000A
     %x72 /          ; r    carriage return U+000D
     %x74 /          ; t    tab             U+0009
     %x75 4HEXDIG )  ; uXXXX                U+XXXX
 
     escape = %x5C              ; \
 
     quotation-mark = %x22      ; "
 
     unescaped = %x20-21 / %x23-5B / %x5D-10FFFF
     */
    case STRING(String)
    
    /*
    number = [ minus ] int [ frac ] [ exp ]
    decimal-point = %x2E       ; .
    digit1-9 = %x31-39         ; 1-9
    e = %x65 / %x45            ; e E
    exp = e [ minus / plus ] 1*DIGIT
    frac = decimal-point 1*DIGIT
    int = zero / ( digit1-9 *DIGIT )
    minus = %x2D               ; -
    plus = %x2B                ; +
    zero = %x30                ; 0
     */
    case NUMBER(NSNumber)
 
    case FALSE
    case TRUE
    case NULL
    
    // error
    case ERROR(String)
}

extension JsonLexToken : Equatable {}

func ==(lhs: JsonLexToken, rhs: JsonLexToken) -> Bool {
    switch (lhs, rhs) {
    case (let .NUMBER(n1), let .NUMBER(n2)):
        return n1 == n2;
        
    case (let .STRING(s1), let .STRING(s2)):
        return s1 == s2
        
    case (.TRUE, .TRUE):
        return true
    case (.FALSE, .FALSE):
        return true
    case (.NULL, .NULL):
        return true
        
    default:
        return false
    }
}

// 定义JsonLexTokenGenerator 类型，表示将一个String转换为JsonLexToken的函数
// 输入为(String, Int) String 表示输入的字符串， Int表示下一个可读字符的offset
// 输出为(JsonLexToken?, Int) 后者表示读取了token之后，下一个可读字符的offset
typealias JsonLexTokenGenerator = (String, Int) -> (JsonLexToken?, Int)

func NilTokenGenerator(s: String, offset: Int) -> (JsonLexToken?, Int)
{
    let emptyCharacters: Set<Character> = ["\r", "\n", " ", "\t"];
    return emptyCharacters.contains(s[s.startIndex.advancedBy(offset)])
        ? (nil, offset + 1) : (nil, offset);
}

func ConstWordTokenGenerator(s: String, offset: Int) -> (JsonLexToken?, Int)
{
    let constWordAndTokens: [(String, JsonLexToken)] =
    [
        ("null", JsonLexToken.NULL),
        ("true", JsonLexToken.TRUE),
        ("false", JsonLexToken.FALSE),
        ("[", JsonLexToken.BEGIN_ARRAY),
        ("]", JsonLexToken.END_ARRAY),
        ("{", JsonLexToken.BEGIN_OBJECT),
        ("}", JsonLexToken.END_OBJECT),
        (":", JsonLexToken.VALUE_SEPARATOR),
        (",", JsonLexToken.NAME_SEPARATOR)
    ];
    
    for (word, token) in constWordAndTokens
    {
        if (s.subString(offset, length: word.length) == word)
        {
            return (token, offset + word.length);
        }
    }
    return (nil, offset);
}

func StringTokenGenerator(s: String, offset: Int) -> (JsonLexToken?, Int)
{
    guard s[offset] == "\"" else
    {
        return (nil, offset);
    }
    
    var currentOffset = offset + 1;
    var currentString = "";
    while currentOffset < s.length
    {
        let currentChar = s[currentOffset];
        if (currentChar == "\"")
        {
            return (JsonLexToken.STRING(currentString), currentOffset + 1);
        }
        
        /*
         %x22 /          ; "    quotation mark  U+0022
         %x5C /          ; \    reverse solidus U+005C
         %x2F /          ; /    solidus         U+002F
         %x62 /          ; b    backspace       U+0008
         %x66 /          ; f    form feed       U+000C
         %x6E /          ; n    line feed       U+000A
         %x72 /          ; r    carriage return U+000D
         %x74 /          ; t    tab             U+0009
         %x75 4HEXDIG )  ; uXXXX                U+XXXX
         */
        // TODO(pigoneand): solve uXXXX issue
        let escapeCharacters: Dictionary<Character, Character> = [
            "\"": "\"", "\\": "\\", "/": "/", "b": "\u{0008}",
            "f": "\u{000C}", "n": "\n", "r": "\r", "t": "\t"
        ];
        
        if (currentChar == "\\" && currentOffset + 1 < s.length)
        {
            let nextChar = s[currentOffset + 1];
            if (escapeCharacters.keys.contains(nextChar))
            {
                currentString.append(escapeCharacters[nextChar]!);
                currentOffset += 2;
                continue;
            }
        }
        
        currentOffset += 1;
        currentString.append(currentChar);
    }
    
    return (JsonLexToken.ERROR("\" is not match at position: \(offset)"), -1);
}

/*
 number = [ minus ] int [ frac ] [ exp ]
 decimal-point = %x2E       ; .
 digit1-9 = %x31-39         ; 1-9
 e = %x65 / %x45            ; e E
 exp = e [ minus / plus ] 1*DIGIT
 frac = decimal-point 1*DIGIT
 int = zero / ( digit1-9 *DIGIT )
 minus = %x2D               ; -
 plus = %x2B                ; +
 zero = %x30                ; 0
 TODO(pigoneand): care about zero!
 */
func NumberTokenGenerator(s:String, offset: Int) -> (JsonLexToken?, Int)
{
    func readDigits(s:String, inout offset: Int) -> Int
    {
        var digitCnt = 0;
        while (offset < s.length && s[offset] >= "0" && s[offset] <= "9")
        {
            offset += 1;
            digitCnt += 1;
        }
        return digitCnt;
    }
    
    func tryReadSingleChar(s: String, c: Character, inout offset:Int)
    {
        if (offset < s.length && s[offset] == c)
        {
            offset += 1;
        }
    }
    
    var curOffset = offset;
    
    guard s[curOffset] == "-" || s[curOffset] >= "0" && s[curOffset] <= "9" else
    {
        return (nil, offset);
    }
    curOffset += 1;
    
    // read int
    readDigits(s, offset: &curOffset);
    
    // read dot (optional)
    if (curOffset < s.length && s[curOffset] == ".")
    {
        curOffset += 1;
        if (readDigits(s, offset: &curOffset) == 0)
        {
            return (JsonLexToken.ERROR("not a valid number at position: \(offset)"), -1);
        }
    }
    
    // read exp (optional)
    if (curOffset < s.length && (s[curOffset] == "e" || s[curOffset] == "E"))
    {
        curOffset += 1;
        tryReadSingleChar(s, c: "+", offset: &curOffset);
        tryReadSingleChar(s, c: "-", offset: &curOffset);
        if (readDigits(s, offset: &curOffset) == 0)
        {
            return (JsonLexToken.ERROR("not a valid number at position: \(offset)"), -1);
        }
    }
    
    return (JsonLexToken.NUMBER((s.subString(offset, length: curOffset - offset) as NSString).doubleValue), curOffset);
}

// 定义json 中 token generator 列表
let tokenGeneratorList : [JsonLexTokenGenerator] = [
    NilTokenGenerator,
    ConstWordTokenGenerator,
    StringTokenGenerator,
    NumberTokenGenerator
]

// parser, 输入一段合法或者非法的json字符串，返回token 列表，如果包含错误， JsonLexToken中会包含 ERROR
func JsonLexParser(s:String) -> [JsonLexToken]
{
    var currentOffset:Int = 0;
    var result: [JsonLexToken] = [];
    
    while (currentOffset < s.length) {
        var shouldContinue = false;
        
        for tokenGen in tokenGeneratorList {
            let (token, offset) = tokenGen(s, currentOffset);
            if (token != nil) {
                result.append(token!);
                currentOffset = offset;
                
                switch (token!) {
                case .ERROR(_):
                    shouldContinue = false;
                default:
                    shouldContinue = true;
                }
                
                break;
            }
        }
        
        if (!shouldContinue) {
            result.append(JsonLexToken.ERROR("cannot continue: \(currentOffset)"));
            break;
        }
    }
    
    return result;
}

