//
//  ExpressionParser.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

import Foundation

struct ExpressionParser {
    enum PartType {
        case minutes, hours, daysOfMonth, months, daysOfWeek
        
        var values: [Int] {
            switch self {
            case .minutes: return Array(0...59)
            case .hours: return Array(0...23)
            case .daysOfMonth: return Array(1...31)
            case .months: return Array(1...12)
            case .daysOfWeek: return Array(0...6)
            }
        }
    }
    
    /// Returns an array of filtered values
    /// by provided string expression
    static func parse(part expression: String, _ type: PartType) throws -> [Int] {
        let allValues = type.values
        var results: Set<Int> = []
        let characterset = CharacterSet(charactersIn: "*/,-0123456789")
        if expression.rangeOfCharacter(from: characterset.inverted) != nil {
            throw SwifCronError(reason: "string contains special characters")
        }
        let commaParts = expression.components(separatedBy: ",")
        for commaPart in commaParts {
            guard commaPart.count > 0 else { throw SwifCronError(reason: "Two commas one after another is a wrong expression") }
            /// If each
            if commaPart == "*" {
                for m in allValues {
                    results.insert(m)
                }
                continue
            }
            /// If simple number
            if let number = Int(commaPart) {
                guard allValues.contains(number) else {
                    throw SwifCronError(reason: "Value \(number) isn't allowed")
                }
                results.insert(number)
                continue
            }
            
            let slashParts = commaPart.components(separatedBy: "/")
            /// No repeating
            if slashParts.count == 1 {
                let period = try parse(period: commaPart, allowedValues: allValues)
                results = results.union(period)
                continue
            } else if slashParts.count == 2 { /// Repeating
                guard let valuesString = slashParts.first, let repeatingString = slashParts.last else {
                    throw SwifCronError(reason: "Unable to get values splitted by slash")
                }
                guard let repeating = Int(repeatingString) else {
                    throw SwifCronError(reason: "Unable to cast string to integer")
                }
                /// if starts from any
                if valuesString == "*" {
                    let vals = allValues.each(repeating)
                    results = results.union(vals)
                    continue
                }
                /// if starts from specific number
                if let number = Int(valuesString) {
                    guard allValues.contains(number) else {
                        throw SwifCronError(reason: "Value \(number) isn't allowed")
                    }
                    guard let lastNumber = allValues.last else {
                        throw SwifCronError(reason: "Unable to get last value")
                    }
                    let vals = Array(number...lastNumber).each(repeating)
                    results = results.union(vals)
                    continue
                }
                /// Concrete period
                let period = try parse(period: valuesString, allowedValues: allValues)
                let vals = period.each(repeating)
                results = results.union(vals)
                continue
            } else {
                throw SwifCronError(reason: "Should be only one slash in expression")
            }
        }
        return results.sorted()
    }
    
    /// Returns an array of values for provided period
    static func parse(period expression: String, allowedValues: [Int]) throws -> [Int] {
        let period = expression.components(separatedBy: "-")
        guard period.count == 2 else {
            throw SwifCronError(reason: "`\(expression)` is not a period")
        }
        guard let firstString = period.first, let lastString = period.last else {
            throw SwifCronError(reason: "Unable to get first and last value from a period")
        }
        guard let firstValue = Int(firstString), let lastValue = Int(lastString) else {
            throw SwifCronError(reason: "Unable to convert period values into integers")
        }
        guard allowedValues.contains(firstValue) else {
            throw SwifCronError(reason: "\(firstValue) isn't allowed value")
        }
        guard allowedValues.contains(lastValue) else {
            throw SwifCronError(reason: "\(lastValue) isn't allowed value")
        }
        return Array(firstValue...lastValue)
    }
}
