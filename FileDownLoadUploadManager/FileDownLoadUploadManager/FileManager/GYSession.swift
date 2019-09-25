//
//  GYSession.swift
//  FileDownLoadUploadManager
//
//  Created by chenjian on 2019/9/19.
//  Copyright © 2019 chenjian. All rights reserved.
//

import UIKit

class GYSession: NSObject {
    public static let `default` = GYSession()
    
    public let session: URLSession
    public let delegate: GYSessionDelegate
    public let rootQueue: DispatchQueue
    public let requestQueue: DispatchQueue
    public let serializationQueue: DispatchQueue
    
    var requestTaskMap = RequestTaskMap()
    /// Set of currently active `Request`s.
    var activeRequests: Set<Request> = []
    
    public init(session: URLSession,
                delegate: GYSessionDelegate,
                rootQueue: DispatchQueue,
                startRequestsImmediately: Bool = true,
                requestQueue: DispatchQueue? = nil,
                serializationQueue: DispatchQueue? = nil) {
        self.session = session
        self.delegate = delegate
        self.rootQueue = rootQueue
        self.requestQueue = requestQueue ?? DispatchQueue(label: "\(rootQueue.label).requestQueue", target: rootQueue)
        self.serializationQueue = serializationQueue ?? DispatchQueue(label: "\(rootQueue.label).serializationQueue", target: rootQueue)
    }
    
    public convenience init(delegate: GYSessionDelegate = GYSessionDelegate(),
                            rootQueue: DispatchQueue = DispatchQueue(label: "org.gy.session.rootQueue"),
                            requestQueue: DispatchQueue? = nil,
                            serializationQueue: DispatchQueue? = nil) {
        let configuration = URLSessionConfiguration.default
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.underlyingQueue = rootQueue
        delegateQueue.name = "org.gy.session.sessionDelegateQueue"
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
        
        self.init(session: session,
                  delegate: delegate,
                  rootQueue: rootQueue,
                  requestQueue: requestQueue,
                  serializationQueue: serializationQueue)
    }
    
    
}
