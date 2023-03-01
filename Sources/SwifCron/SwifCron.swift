//
//  SwifCron.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

import Foundation

public struct SwifCron {
    /// String expression
    public let expression: String
    
    /// Internal expression mode
    enum ExpressionMode {
        case anyDayOfWeek, exactDayOfWeekButAnyDom, mixed
    }
    let mode: ExpressionMode
    
    let sixValues: Bool
    let anySecond: Bool
    let anyMinute: Bool
    let anyHour: Bool
    
    /// Parsed parts of cron expression
    let seconds, minutes, hours, daysOfMonth, months, daysOfWeek: [Int]
    
    /**
     Supports only digit values yet
     - parameters:
     - second: expression string, default - 0
     - minute: expression string
     - hour: expression string
     - dayOfMonth: expression string
     - month: expression string (doesn't suppoer name of month, only digits)
     - dayOfWeek: expression string (sunday is 0, doesn't support name of day, so use only digits)
     
     - supported values:
     - *: for any value
     - -: to set periods like `1-10`
     - ,: (comma) value list separator
     - /:(slash) for step values
     */
    public init(_ expression: String) throws {
        self.expression = expression
        let parts = expression.components(separatedBy: " ")
        
        // add new seconds parameter (Quartz cron) but leave backward compatibility with UNIX cron
        guard parts.count == 5 || parts.count == 6 else {
            throw SwifCronError(reason: "Cron string should contain 5 or 6 parts separated by space")
        }
        var offset = 0
        if parts.count == 6 {
            offset = 1
            sixValues = true
        } else {
            sixValues = false
        }
        
        if parts[offset + 4] == "*" {
            mode = .anyDayOfWeek
        } else if parts[offset + 2] == "*" && parts[offset + 3] == "*" && parts[offset + 4] != "*" {
            mode = .exactDayOfWeekButAnyDom
        } else {
            mode = .mixed
        }
        
        anySecond = offset == 0 ? false : parts[0] == "*"
        anyMinute = parts[offset + 0] == "*"
        anyHour = parts[offset + 1] == "*"
        
        // Cron expression parsed values
        seconds = offset == 0 ? [0] : try ExpressionParser.parse(part: parts[0], .seconds)
        minutes = try ExpressionParser.parse(part: parts[offset + 0], .minutes)
        hours = try ExpressionParser.parse(part: parts[offset + 1], .hours)
        daysOfMonth = try ExpressionParser.parse(part: parts[offset + 2], .daysOfMonth)
        months = try ExpressionParser.parse(part: parts[offset + 3], .months)
        daysOfWeek = try ExpressionParser.parse(part: parts[offset + 4], .daysOfWeek)
    }
    
    /* Returns a next date based on cron string expression
     *
     * You could use:
     * * for any value
     * use `-` to set periods like `1-10`
     * use `,`(comma) value list separator
     * use `/`(slash) for step values
     *
     * Supports only digit values yet
     **/
    public func next(from date: Date = Date(), timeZone: TimeZone? = nil) throws -> Date {
        // Calendar with UTC-0 time zone
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone ?? .gmt
        
        // Value for `from` date
        let currentSecond = calendar.component(.second, from: date)
        let currentMinute = calendar.component(.minute, from: date)
        let currentHour = calendar.component(.hour, from: date)
        let currentDayOfMonth = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentDayOfWeek = calendar.component(.weekday, from: date) - 1
        let currentYear = calendar.component(.year, from: date)
        
        // Looking for the right next date
        var nextSecond = try Helper.findNext(current: currentSecond, from: seconds, offset: sixValues ? 1 : 0)
        
        // additional check for minute. If current time is 20:10:05, next will be 20:10:06, not 20:11:06
        var nextMinute = try Helper.findNext(current: currentMinute, from: minutes, offset: anyMinute && !sixValues ? 1 : 0)

        if !sixValues || nextSecond.value == 0 {
            if nextMinute.value == currentMinute {
                if anyMinute {
                    nextMinute.value = nextMinute.value + 1
                } else {
                    nextMinute = try Helper.findNext(current: currentMinute, from: minutes, offset: 1)
                }
            }
        }

        var nextHour = try Helper.findNext(current: currentHour, from: hours, offset: nextMinute.offset)
        if nextHour.value - currentHour > 0 {
            nextMinute.value = minutes[0]
        }
        
        // Not every month contains 31 day, so we should exclude non-existing days
        let filteredDaysOfMonth = try Helper.filterDaysOfMonth(month: currentMonth, year: currentYear, days: daysOfMonth)
        
        var nextDayOfMonth = try Helper.findNext(current: currentDayOfMonth, from: filteredDaysOfMonth, offset: nextHour.offset)
        var nextMonth = try Helper.findNext(current: currentMonth, from: months, offset: nextDayOfMonth.offset)
        
        if nextDayOfMonth.value - currentDayOfMonth > 0 {
            nextSecond.value = seconds[0]
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
        }
        if nextMonth.value - currentMonth > 0 {
            nextSecond.value = seconds[0]
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
            nextDayOfMonth.value = daysOfMonth[0]
        }
        if nextMonth.offset > 0 {
            nextSecond.value = seconds[0]
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
            nextDayOfMonth.value = daysOfMonth[0]
            nextMonth.value = months[0]
        }
        
        switch mode {
        case .anyDayOfWeek:
            return try Helper.getNextDateByDom(second: nextSecond.value,
                                               minute: nextMinute.value,
                                               hour: nextHour.value,
                                               day: nextDayOfMonth.value,
                                               month: nextMonth.value,
                                               year: currentYear + nextMonth.offset,
                                               calendar: calendar)
        case .exactDayOfWeekButAnyDom:
            return try Helper.getNextDateByDow(currentDayOfWeek,
                                               available: daysOfWeek,
                                               dowOffset: nextHour.offset,
                                               second: nextSecond.value,
                                               minute: nextMinute.value,
                                               hour: nextHour.value,
                                               day: currentDayOfMonth,
                                               month: currentMonth,
                                               year: currentYear,
                                               calendar: calendar,
                                               cron: self)
        case .mixed:
            let nextDateByDow = try Helper.getNextDateByDow(currentDayOfWeek,
                                                            available: daysOfWeek,
                                                            dowOffset: nextHour.offset,
                                                            second: nextSecond.value,
                                                            minute: nextMinute.value, hour: nextHour.value,
                                                            day: currentDayOfMonth,
                                                            month: currentMonth,
                                                            year: currentYear,
                                                            calendar: calendar,
                                                            cron: self)
            let nextDateByDom = try Helper.getNextDateByDom(second: nextSecond.value,
                                                            minute: nextMinute.value,
                                                            hour: nextHour.value,
                                                            day: nextDayOfMonth.value,
                                                            month: nextMonth.value,
                                                            year: currentYear + nextMonth.offset,
                                                            calendar: calendar)
            return nextDateByDow < nextDateByDom ? nextDateByDow : nextDateByDom
        }
    }
}

extension SwifCron: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(expression)
    }
}
