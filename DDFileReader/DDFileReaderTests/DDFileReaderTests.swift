//
//  DDFileReaderTests.swift
//  DDFileReaderTests
//
//  Created by Yasuhiro Inami on 2014/06/22.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import XCTest
import DDFileReader

class DDFileReaderTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
    }
    
    override func tearDown()
    {
        super.tearDown()
    }
    
    func testReadLine()
    {
        let reader = DDFileReader(filePath: __FILE__)!
        var line: NSString?
        
        line = reader.readLine()
        XCTAssertEqual(line!, "//\n",
            "Should be equal to 1st line of this file.")
        
        line = reader.readLine()
        XCTAssertEqual(line!, "//  DDFileReaderTests.swift\n",
            "Should be equal to 2nd line of this file.")
        
        line = reader.readLine()
        line = reader.readLine()
        line = reader.readLine()
        XCTAssertEqual(line!, "//  Created by Yasuhiro Inami on 2014/06/22.\n",
            "Should be equal to 5th line of this file.")
    }
    
    func testReadTrimmedLine()
    {
        let reader = DDFileReader(filePath: __FILE__)!
        var line: NSString?
        
        line = reader.readTrimmedLine()
        XCTAssertEqual(line!, "//",
            "Should be equal to 1st line of this file.")
        
        line = reader.readTrimmedLine()
        XCTAssertEqual(line!, "//  DDFileReaderTests.swift",
            "Should be equal to 2nd line of this file.")
        
        line = reader.readTrimmedLine()
        line = reader.readTrimmedLine()
        line = reader.readTrimmedLine()
        XCTAssertEqual(line!, "//  Created by Yasuhiro Inami on 2014/06/22.",
            "Should be equal to 5th line of this file.")
    }
    
}
