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
    
    func test9() {
        do {
            let nextDate = try SwifCron("*/2 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:42:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test10() {
        do {
            let nextDate = try SwifCron("*/3 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:42:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test11() {
        do {
            let nextDate = try SwifCron("*/4 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:44:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test12() {
        do {
            let nextDate = try SwifCron("*/5 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:45:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test13() {
        do {
            let nextDate = try SwifCron("*/60 * * * *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 21:00:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test14() {
        do {
            let nextDate = try SwifCron("* * * */2 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 20:42:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test15() {
        do {
            let nextDate = try SwifCron("* */2 * * *").next(from: Date(timeIntervalSince1970: 1551906000)) // 2019-03-06 21:00:00 +0000
            XCTAssertEqual(String(describing: nextDate), "2019-03-06 22:00:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    // is it correct test? if yes, then lib should be fixed
//    func test15_1() {
//        do {
//            let nextDate = try SwifCron("* */3 * * *").next(from: Date(timeIntervalSince1970: 1551906000)) // 2019-03-06 21:00:00 +0000
//            XCTAssertEqual(String(describing: nextDate), "2019-03-07 00:00:00 +0000")
//        } catch {
//            XCTFail(String(describing: error))
//        }
//    }
    
    func test16() {
        do {
            let nextDate = try SwifCron("* * * */3 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-04-01 00:00:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test17() {
        do {
            let nextDate = try SwifCron("* * * */12 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2020-01-01 00:00:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test18() {
        do {
            let nextDate = try SwifCron("1 * * */12 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2020-01-01 00:01:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test19() {
        do {
            let nextDate = try SwifCron("1 1 * */12 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2020-01-01 01:01:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test20() {
        do {
            let nextDate = try SwifCron("1 1 2 */12 *").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2020-01-02 01:01:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test21() {
        do {
            let nextDate = try SwifCron("1 1 2 */12 6").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-09 01:01:00 +0000")
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func test22() {
        do {
            let nextDate = try SwifCron("* * * * 6").next(from: testDate)
            XCTAssertEqual(String(describing: nextDate), "2019-03-09 00:00:00 +0000")
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
        ("test9", test9),
        ("test10", test10),
        ("test11", test11),
        ("test12", test12),
        ("test13", test13),
        ("test14", test14),
        ("test15", test15),
        ("test16", test16),
        ("test17", test17),
        ("test18", test18),
        ("test19", test19),
        ("test20", test20),
        ("test21", test21),
        ("test22", test22),
    ]
}
