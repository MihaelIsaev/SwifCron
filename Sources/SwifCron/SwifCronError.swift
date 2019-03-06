//
//  SwifCronError.swift
//  SwifCron
//
//  Created by Mihael Isaev on 06/03/2019.
//

protocol SwifCronErrorProtocol: Error {
    var reason: String { get }
}
struct SwifCronError: SwifCronErrorProtocol {
    var reason: String
}
