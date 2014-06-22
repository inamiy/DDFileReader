//
//  DDFileReader.swift
//  DDFileReader
//
//  Created by Yasuhiro Inami on 2014/06/22.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import Foundation

//
// Swift port of DDFileReader by Dave DeLong
//
// objective c - How to read data from NSFileHandle line by line? - Stack Overflow
// http://stackoverflow.com/a/3711079/666371
//
class DDFileReader
{
    var lineDelimiter = "\n"
    var chunkSize = 128
    
    let filePath: NSString!
    
    let _fileHandle: NSFileHandle
    let _totalFileLength: CUnsignedLongLong
    var _currentOffset: CUnsignedLongLong = 0
    
    init(filePath: NSString!)
    {
        self.filePath = filePath
        self._fileHandle = NSFileHandle(forReadingAtPath: filePath)
        self._totalFileLength = self._fileHandle.seekToEndOfFile()
    }
    
    deinit
    {
        self._fileHandle.closeFile()
    }
    
    func readLine() -> NSString!
    {
        if self._currentOffset >= self._totalFileLength {
            return nil
        }
        
        self._fileHandle.seekToFileOffset(self._currentOffset)
        let newLineData = self.lineDelimiter.dataUsingEncoding(NSUTF8StringEncoding)
        let currentData = NSMutableData()
        var shouldReadMore = true
        
        autoreleasepool {
            
            while shouldReadMore {
                
                if self._currentOffset >= self._totalFileLength {
                    break
                }
                
                var chunk = self._fileHandle.readDataOfLength(self.chunkSize)
                
                let newLineRange = chunk.rangeOfData(newLineData)
                
                if newLineRange.location != NSNotFound {
                    chunk = chunk.subdataWithRange(NSMakeRange(0, newLineRange.location+newLineData.length))
                    shouldReadMore = false
                }
                currentData.appendData(chunk)
                
                self._currentOffset += CUnsignedLongLong(chunk.length)
                
            }
            
        }
        
        let line = NSString(data: currentData, encoding:NSUTF8StringEncoding)
        
        return line
    }
    
    func readTrimmedLine() -> NSString!
    {
        return self.readLine().stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: self.lineDelimiter))
    }
    
    func enumerateLinesUsingBlock(closure: (NSString!, inout Bool) -> Void)
    {
        var line: NSString! = nil
        var stop = false
        while stop == false {
            line = self.readLine()
            if !line { break }
            
            closure(line, &stop)
        }
    }
    
    func resetOffset()
    {
        self._currentOffset = 0
    }
}

extension NSData
{
    func rangeOfData(dataToFind: NSData) -> NSRange
    {
        var searchIndex = 0
        var foundRange = NSRange(location: NSNotFound, length: dataToFind.length)
        
        for index in 0..length {
            
            let bytes_ = UnsafeArray(start: UnsafePointer<CUnsignedChar>(self.bytes), length: self.length)
            let searchBytes_ = UnsafeArray(start: UnsafePointer<CUnsignedChar>(dataToFind.bytes), length: self.length)
            
            if bytes_[index] == searchBytes_[searchIndex] {
                if foundRange.location == NSNotFound {
                    foundRange.location = index
                }
                searchIndex++
                if searchIndex >= dataToFind.length {
                    return foundRange
                }
            }
            else {
                searchIndex = 0
                foundRange.location = NSNotFound
            }
            
        }
        return foundRange
    }
}