//
//  GYFileManager.swift
//  FileDownLoadUploadManager
//
//  Created by chenjian on 2019/8/15.
//  Copyright © 2019 chenjian. All rights reserved.
//

import UIKit

class GYFileManager: NSObject {
    private static let instance: GYFileManager = GYFileManager(session: GYSession(), delegate: GYSessionDelegate(), rootQueue: DispatchQueue.main)
    
   public let session: GYSession
    /// Instance's `SessionDelegate`, which handles the `URLSessionDelegate` methods and `AFRequest` interaction.
    public let delegate: GYSessionDelegate
    /// Root `DispatchQueue` for all internal callbacks and state update. **MUST** be a serial queue.
    public let rootQueue: DispatchQueue
    
    class func shareInstance() -> GYFileManager {
     return instance
    }
    
    public init(session: GYSession,
                   delegate: GYSessionDelegate,
                   rootQueue: DispatchQueue,
                   startRequestsImmediately: Bool = true,
                   requestQueue: DispatchQueue? = nil,
                   serializationQueue: DispatchQueue? = nil) {
           self.session = session
           self.delegate = delegate
           self.rootQueue = rootQueue
       }
    
    func upload(file: URL, progressBlock: ((CGFloat) -> Void)?, completeBlock: (Error?, String?)) {
        
    }
    
    func upload(datas: [Data], completeBlock: (Error?, [String]?)) {
        
    }
    
    func download(fileUrl: URL, progressBlock: ((CGFloat) -> Void)?, completeBlock: (Error?, String?)) {
        
    }
}
