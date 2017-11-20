//
//  JSONAnalyser.swift
//  JSONParser
//
//  Created by TaeHyeonLee on 2017. 11. 6..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

typealias JSONData = Array<Any>
typealias JSONObject = Dictionary<String, Any>

struct JSONAnalyser {
    private let grammarChecker : GrammarChecker

    init(grammarChecker: GrammarChecker) {
        self.grammarChecker = grammarChecker
    }

    func getJSONData(inputValue: String) -> JSONData {
        let elements: Array<String> = getElementsAll(from: inputValue)
        return elements.map { element in setEachType(element: element) ?? ""}
    }
    
    private func setEachType(element: String) -> Any? {
        if element.starts(with: "{") {
            return getJSONObject(elements: getObjectElements(from: element))
        } else if element.starts(with: "[") {
            return getJSONData(inputValue: element)
        } else if element.starts(with: "\"") {
            return element.replacingOccurrences(of: "\"", with: "")
        } else if let element = Int(element) {
            return element as Int
        } else if let element = Bool(element) {
            return element as Bool
        }
        return nil
    }
    
    private func getJSONObject(elements: Array<String>) -> JSONObject {
        var jsonObject : JSONObject = [:]
        for element in elements {
            let keyValue = element.split(separator: ":")
                                  .map {$0.trimmingCharacters(in: .whitespaces)}
            let key : String = String(keyValue[0]).replacingOccurrences(of: "\"", with: "")
            let value : Any = setEachType(element: String(keyValue[1])) ?? ""
            jsonObject[key] = value
        }
        return jsonObject
    }

    private func getElementsAll(from target: String) -> Array<String> {
        var result : Array<String> = []
        if target.starts(with: "{") {
            result.append(target)
        } else {
            result.append(contentsOf: getElementsFromArray(with: target))
        }
        return result
    }

    private func getElementsFromArray(with target: String) -> Array<String> {
        var elementsFromArray : Array<String> = []
        var elements : String = target.trimmingCharacters(in: ["[","]"])
        elementsFromArray.append(contentsOf: getArrayMatches(from: elements))
        elements = removeMatchedArray(target: elements)
        elementsFromArray.append(contentsOf: getObjectMatches(from: elements))
        elements = removeMatchedObject(target: elements)
        elementsFromArray.append(contentsOf: getElements(from: elements))
        return elementsFromArray
    }

}

private typealias JSONElementsPicker = JSONAnalyser

private extension JSONElementsPicker {
    
    // 배열, 객체 외의 데이터 추출
    func getElements(from target: String) -> Array<String> {
        return target.split(separator: ",").flatMap {$0.trimmingCharacters(in: .whitespaces)}
    }

    // 배열 내부의 배열 추출
    func getArrayMatches(from target: String) -> Array<String> {
        return getMatchedElements(from: target, with: grammarChecker.arrayPattern)
    }

    // 배열 내부의 객체 추출
    func getObjectMatches(from target: String) -> Array<String> {
        return getMatchedElements(from: target, with: grammarChecker.objectPattern)
    }

    // JSONObject 타입에서 요소 추출
    func getObjectElements(from target: String) -> Array<String> {
        return getMatchedElements(from: target, with: grammarChecker.nestedDictionaryPattern)
    }

    func getMatchedElements(from target: String, with pattern: String) -> Array<String> {
        let regularExpression = try! NSRegularExpression.init(pattern: pattern, options: [])
        let objectResult = regularExpression.matches(in: target, options: [], range: NSRange(location:0, length:target.count))
        let result = objectResult.map {String(target[Range($0.range, in: target)!]).trimmingCharacters(in: .whitespaces)}
        return result
    }

    func removeMatchedArray(target: String) -> String {
        return removeMatchedElements(from: target, with: grammarChecker.arrayPattern)
    }

    func removeMatchedObject(target: String) -> String {
        return removeMatchedElements(from: target, with: grammarChecker.objectPattern)
    }

    func removeMatchedElements(from target: String, with pattern: String) -> String {
        let regularExpression = try! NSRegularExpression.init(pattern: pattern, options: [])
        let result = regularExpression.stringByReplacingMatches(in: target, options: [], range: NSRange(location:0, length: target.count), withTemplate: "")
        return result
    }
    
}
