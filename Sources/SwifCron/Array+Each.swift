//
//  Array+Each.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

extension Array where Element == Int {
    func each(_ nth: Int) -> [Int] {
        return enumerated().compactMap { $0.offset % nth == 0 ? $0.element : nil }
    }
}
