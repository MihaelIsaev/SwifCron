//
//  DateMaker.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

import Foundation

struct Helper {
    /// Returns a next day by provided minute, hour, minutem day, month, year, calendar
    static func getNextDateByDom(second: Int, minute: Int, hour: Int, day: Int, month: Int, year: Int, calendar: Calendar) throws -> Date {
        let componentsByDom = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        guard let nextDateByDayOfMonth = calendar.date(from: componentsByDom) else {
            throw SwifCronError(reason: "Unable to generate next date from components")
        }
        return nextDateByDayOfMonth
    }
    
    /// Returns a next day by provided day of week, offset, minute, hour, minutem day, month, year, calendar
    static func getNextDateByDow(_ dow: Int, available: [Int], dowOffset: Int, second: Int, minute: Int, hour: Int, day: Int, month: Int, year: Int, calendar: Calendar, cron: SwifCron) throws -> Date {
        var minute = minute
        var hour = hour
        let dowComponents = try findComponentsByDayOfWeek(dow, available: available, dowOffset: dowOffset, currentDay: day, currentMonth: month, year: year)
        if dowComponents.day > day {
            minute = cron.minutes[0]
            hour = cron.hours[0]
        }
        let componentsByDow = DateComponents(year: year + dowComponents.yearOffset, month: dowComponents.month, day: dowComponents.day, hour: hour, minute: minute, second: 0)
        guard let date = calendar.date(from: componentsByDow) else {
            throw SwifCronError(reason: "Unable to generate next date from components")
        }
        return date
    }
    
    /// Returns is provided year is a leap year
    static func isLeapYear(_ year: Int) -> Bool {
        return ((year % 100 != 0) && (year % 4 == 0)) || year % 400 == 0
    }
    
    /// Removes non-existing month's days from array
    static func filterDaysOfMonth(month: Int, year: Int, days: [Int]) throws -> [Int] {
        switch month {
        case 2:
            let maxDay = isLeapYear(year) ? 29 : 28
            return days.filter { $0 <= maxDay }
        case 4, 6, 9, 11: return days.filter { $0 <= 30 }
        default: return days
        }
    }
    
    /// Returns a last day for month
    static func lastDayOfMonth(_ month: Int, year: Int) -> Int {
        switch month {
        case 2: return isLeapYear(year) ? 29 : 28
        case 4, 6, 9, 11: return 30
        default: return 31
        }
    }
    
    /// Returns next available value from array
    static func findNext(current: Int, from available: [Int], offset: Int) throws -> (value: Int, offset: Int) {
        if let next = available.first(where: { $0 >= current + offset }) {
            return (next, 0)
        }
        if let first = available.first {
            return (first, 1)
        }
        throw SwifCronError(reason: "Unable to generate next value")
    }
    
    /// Returns day, month, yearOffset components
    /// to build a date from provided day of week
    static func findComponentsByDayOfWeek(_ dow: Int,
                                                                available: [Int],
                                                                dowOffset: Int,
                                                                currentDay dom: Int,
                                                                currentMonth month: Int,
                                                                year: Int) throws -> (day: Int, month: Int, yearOffset: Int) {
        if available.contains(dow) && dowOffset == 0 {
            return (dom, month, 0)
        }
        let maxDom = lastDayOfMonth(month, year: year)
        let nextDow = try findNext(current: dow, from: available, offset: dowOffset)
        var offset = 0
        if (nextDow.value == dow && dowOffset == 0) || nextDow.value > dow {
            offset = nextDow.value - dow
        } else {
            offset = 7 - dow + nextDow.value
        }
        let nextDom = dom + offset
        if nextDom <= maxDom {
            return (nextDom, month, 0)
        }
        let dayInNextMonth = nextDom - maxDom
        let nextMonth = month == 12 ? 1 : month + 1
        let yearOffset = month == 12 ? 1 : 0
        return (dayInNextMonth, nextMonth, yearOffset)
    }
}
