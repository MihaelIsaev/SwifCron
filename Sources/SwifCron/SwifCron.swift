//
//  SwifCron.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

import Foundation

public struct SwifCron {
    /// Internal expression mode
    enum ExpressionMode {
        case anyDayOfWeek, exactDayOfWeekButAnyDom, mixed
    }
    let mode: ExpressionMode
    let anyMinute: Bool
    let anyHour: Bool
    
    /// Parsed parts of cron expression
    let minutes, hours, daysOfMonth, months, daysOfWeek: [Int]
    
    /**
     Supports only digit values yet
     - parameters:
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
        let parts = expression.components(separatedBy: " ")
        guard parts.count == 5 else {
            throw SwifCronError(reason: "Cron string should contain 5 parts separated by space")
        }
        
        if parts[4] == "*" {
            mode = .anyDayOfWeek
        } else if parts[2] == "*" && parts[3] == "*" && parts[4] != "*" {
            mode = .exactDayOfWeekButAnyDom
        } else {
            mode = .mixed
        }
        
        anyMinute = parts[0] == "*"
        anyHour = parts[1] == "*"
        
        // Cron expression parsed values
        minutes = try ExpressionParser.parse(part: parts[0], .minutes)
        hours = try ExpressionParser.parse(part: parts[1], .hours)
        daysOfMonth = try ExpressionParser.parse(part: parts[2], .daysOfMonth)
        months = try ExpressionParser.parse(part: parts[3], .months)
        daysOfWeek = try ExpressionParser.parse(part: parts[4], .daysOfWeek)
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
    public func next(from date: Date = Date()) throws -> Date {
        // Calendar with UTC-0 time zone
        var calendar = Calendar(identifier: .gregorian)
        guard let timeZone = TimeZone(secondsFromGMT: 0) else {
            throw SwifCronError(reason: "Unable to get UTC+0 time zone")
        }
        calendar.timeZone = timeZone
        
        // Value for `from` date
        let currentMinute = calendar.component(.minute, from: date)
        let currentHour = calendar.component(.hour, from: date)
        let currentDayOfMonth = calendar.component(.day, from: date)
        let currentMonth = calendar.component(.month, from: date)
        let currentDayOfWeek = calendar.component(.weekday, from: date) - 1
        let currentYear = calendar.component(.year, from: date)
        
        // Looking for the right next date
        var nextMinute = try Helper.findNext(current: currentMinute, from: minutes, offset: anyMinute ? 1 : 0)
        if nextMinute.value == currentMinute {
            nextMinute.value = nextMinute.value + 1
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
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
        }
        if nextMonth.value - currentMonth > 0 {
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
            nextDayOfMonth.value = daysOfMonth[0]
        }
        if nextMonth.offset > 0 {
            nextMinute.value = minutes[0]
            nextHour.value = hours[0]
            nextDayOfMonth.value = daysOfMonth[0]
            nextMonth.value = months[0]
        }
        
        switch mode {
        case .anyDayOfWeek:
            return try Helper.getNextDateByDom(minute: nextMinute.value,
                                                                  hour: nextHour.value,
                                                                  day: nextDayOfMonth.value,
                                                                  month: nextMonth.value,
                                                                  year: currentYear + nextMonth.offset,
                                                                  calendar: calendar)
        case .exactDayOfWeekButAnyDom:
            return try Helper.getNextDateByDow(currentDayOfWeek,
                                                                  available: daysOfWeek,
                                                                  dowOffset: nextHour.offset,
                                                                  hour: nextHour.value,
                                                                  minute: nextMinute.value,
                                                                  day: currentDayOfMonth,
                                                                  month: currentMonth,
                                                                  year: currentYear,
                                                                  calendar: calendar,
                                                                  cron: self)
        case .mixed:
            let nextDateByDow = try Helper.getNextDateByDow(currentDayOfWeek,
                                                                                        available: daysOfWeek,
                                                                                        dowOffset: nextHour.offset,
                                                                                        hour: nextHour.value,
                                                                                        minute: nextMinute.value,
                                                                                        day: currentDayOfMonth,
                                                                                        month: currentMonth,
                                                                                        year: currentYear,
                                                                                        calendar: calendar,
                                                                                        cron: self)
            let nextDateByDom = try Helper.getNextDateByDom(minute: nextMinute.value,
                                                                                        hour: nextHour.value,
                                                                                        day: nextDayOfMonth.value,
                                                                                        month: nextMonth.value,
                                                                                        year: currentYear + nextMonth.offset,
                                                                                        calendar: calendar)
            return nextDateByDow < nextDateByDom ? nextDateByDow : nextDateByDom
        }
    }
}
