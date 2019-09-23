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
    
    public init(session: URLSession,
                delegate: GYSessionDelegate,
                rootQueue: DispatchQueue,
                startRequestsImmediately: Bool = true,
                requestQueue: DispatchQueue? = nil,
                serializationQueue: DispatchQueue? = nil) {
        self.session = session
        //        precondition(session.configuration.identifier == nil,
        //                     "Alamofire does not support background URLSessionConfigurations.")
        //        precondition(session.delegateQueue.underlyingQueue === rootQueue,
        //                     "Session(session:) intializer must be passed the DispatchQueue used as the delegateQueue's underlyingQueue as rootQueue.")
        
        self.session = session
        self.delegate = delegate
        self.rootQueue = rootQueue
        //        self.startRequestsImmediately = startRequestsImmediately
        //        self.requestQueue = requestQueue ?? DispatchQueue(label: "\(rootQueue.label).requestQueue", target: rootQueue)
        //        self.serializationQueue = serializationQueue ?? DispatchQueue(label: "\(rootQueue.label).serializationQueue", target: rootQueue)
        //        self.interceptor = interceptor
        //        self.serverTrustManager = serverTrustManager
        //        self.redirectHandler = redirectHandler
        //        self.cachedResponseHandler = cachedResponseHandler
        //        eventMonitor = CompositeEventMonitor(monitors: defaultEventMonitors + eventMonitors)
        //        delegate.eventMonitor = eventMonitor
        //        delegate.stateProvider = self
    }
    
    public convenience init(delegate: GYSessionDelegate = GYSessionDelegate(),
                            rootQueue: DispatchQueue = DispatchQueue(label: "org.alamofire.session.rootQueue")) {
        let configuration = URLSessionConfiguration.default
        //        configuration.headers = .default
        let delegateQueue = OperationQueue(maxConcurrentOperationCount: 1, underlyingQueue: rootQueue, name: "org.alamofire.session.sessionDelegateQueue")
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
        
        self.init(session: session,
                  delegate: delegate,
                  rootQueue: rootQueue,
                  delegateQueue: delegateQueue)
    }
}
