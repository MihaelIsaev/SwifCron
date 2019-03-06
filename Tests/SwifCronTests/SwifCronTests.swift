import XCTest
@testable import SwifCron

final class SwifCronTests: XCTestCase {
    let testDate = Date(timeIntervalSince1970: 1551904895) // 2019-03-06 20:41:35 +0000
    
    func test1() {
        do {
            let nextDate = try SwifCron("* * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:42:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test2() {
        do {
            let nextDate = try SwifCron("5 4 11 4 3").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-13 04:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test3() {
        do {
            let nextDate = try SwifCron("5 4 11 4 5").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-08 04:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test4() {
        do {
            let nextDate = try SwifCron("5 4 11 4 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-04-11 04:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test5() {
        do {
            let nextDate = try SwifCron("5 4 11 * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-11 04:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test6() {
        do {
            let nextDate = try SwifCron("5 4 * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-07 04:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test7() {
        do {
            let nextDate = try SwifCron("5 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 21:05:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test8() {
        do {
            let nextDate = try SwifCron("0-1,3/2 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:42:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }

    static var allTests = [
        ("test1", test1),
        ("test2", test2),
        ("test3", test3),
        ("test4", test4),
        ("test5", test5),
        ("test6", test6),
        ("test7", test7),
        ("test8", test8),
    ]
}
