//
//  GYFileManager.swift
//  FileDownLoadUploadManager
//
//  Created by chenjian on 2019/8/15.
//  Copyright © 2019 chenjian. All rights reserved.
//

import UIKit

class GYFileManager: NSObject {
    private static let instance: GYFileManager = GYFileManager()
    
    class func shareInstance() -> GYFileManager {
        return instance
    }
    
    public let session: GYSession
    
    public init(_ session: GYSession) {
        self.session = session
    }
    
    public convenience override init() {
        self.init(GYSession.default)
    }
    
    func upload(file: URL, progressBlock: ((CGFloat) -> Void)?, completeBlock: (Error?, String?)) {
        
    }
    
    func upload(datas: [Data], completeBlock: (Error?, [String]?)) {
        
    }
    
    func download(fileUrl: URL, progressBlock: ((CGFloat) -> Void)?, completeBlock: (Error?, String?)) {
        
    }
}
