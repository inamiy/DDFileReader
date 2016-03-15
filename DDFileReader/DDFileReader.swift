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
public class DDFileReader
{
    public var lineDelimiter = "\n"
    public var chunkSize = 128
    
    public let filePath: NSString
    
    private let _fileHandle: NSFileHandle!
    private let _totalFileLength: CUnsignedLongLong
    private var _currentOffset: CUnsignedLongLong = 0
    
    public init?(filePath: NSString)
    {
        self.filePath = filePath
        if let fileHandle = NSFileHandle(forReadingAtPath: filePath as String) {
            self._fileHandle = fileHandle
            self._totalFileLength = self._fileHandle.seekToEndOfFile()
        }
        else {
            self._fileHandle = nil
            self._totalFileLength = 0
            
            return nil
        }
    }
    
    deinit
    {
        if let _fileHandle = self._fileHandle {
            _fileHandle.closeFile()
        }
    }
    
    public func readLine() -> NSString?
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
                
                let newLineRange = chunk.rangeOfData(newLineData!)
                
                if newLineRange.location != NSNotFound {
                    chunk = chunk.subdataWithRange(NSMakeRange(0, newLineRange.location+newLineData!.length))
                    shouldReadMore = false
                }
                currentData.appendData(chunk)
                
                self._currentOffset += CUnsignedLongLong(chunk.length)
                
            }
            
        }
        
        let line = NSString(data: currentData, encoding:NSUTF8StringEncoding)
        
        return line
    }
    
    public func readTrimmedLine() -> NSString?
    {
        let characterSet = NSCharacterSet(charactersInString: self.lineDelimiter)
        return self.readLine()?.stringByTrimmingCharactersInSet(characterSet)
    }
    
    public func enumerateLinesUsingBlock(closure: (line: NSString, stop: inout Bool) -> Void)
    {
        var line: NSString? = nil
        var stop = false
        while stop == false {
            line = self.readLine()
            if line == nil { break }
            
            closure(line: line!, stop: &stop)
        }
    }
    
    public func resetOffset()
    {
        self._currentOffset = 0
    }
}

extension NSData
{
    private func rangeOfData(dataToFind: NSData) -> NSRange
    {
        var searchIndex = 0
        var foundRange = NSRange(location: NSNotFound, length: dataToFind.length)
        
        for index in 0...length-1 {
            
            let bytes_ = UnsafeBufferPointer(start: UnsafePointer<CUnsignedChar>(self.bytes), count: self.length)
            let searchBytes_ = UnsafeBufferPointer(start: UnsafePointer<CUnsignedChar>(dataToFind.bytes), count: self.length)
            
            if bytes_[index] == searchBytes_[searchIndex] {
                if foundRange.location == NSNotFound {
                    foundRange.location = index
                }
                searchIndex += 1
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