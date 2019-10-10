//
//  GYSession.swift
//  FileDownLoadUploadManager
//
//  Created by chenjian on 2019/9/19.
//  Copyright © 2019 chenjian. All rights reserved.
//

import UIKit

open class GYSession: NSObject {
    public static let `default` = GYSession()
    
    public let session: URLSession
    public let delegate: GYSessionDelegate
    public let rootQueue: DispatchQueue
    public let requestQueue: DispatchQueue
    public let serializationQueue: DispatchQueue
    public let interceptor: RequestInterceptor?
    public let startRequestsImmediately: Bool = true
    
    var requestTaskMap = RequestTaskMap()
    /// Set of currently active `Request`s.
    var activeRequests: Set<Request> = []
    
    public init(session: URLSession,
                delegate: GYSessionDelegate,
                rootQueue: DispatchQueue,
                startRequestsImmediately: Bool = true,
                interceptor: RequestInterceptor? = nil,
                requestQueue: DispatchQueue? = nil,
                serializationQueue: DispatchQueue? = nil) {
        self.session = session
        self.delegate = delegate
        self.rootQueue = rootQueue
        self.requestQueue = requestQueue ?? DispatchQueue(label: "\(rootQueue.label).requestQueue", target: rootQueue)
        self.serializationQueue = serializationQueue ?? DispatchQueue(label: "\(rootQueue.label).serializationQueue", target: rootQueue)
        self.interceptor = interceptor
    }
    
    public convenience init(delegate: GYSessionDelegate = GYSessionDelegate(),
                            rootQueue: DispatchQueue = DispatchQueue(label: "org.gy.session.rootQueue"),
                            requestQueue: DispatchQueue? = nil,
                            serializationQueue: DispatchQueue? = nil,
                             interceptor: RequestInterceptor? = nil) {
        let configuration = URLSessionConfiguration.default
        let delegateQueue = OperationQueue()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.underlyingQueue = rootQueue
        delegateQueue.name = "org.gy.session.sessionDelegateQueue"
        let session = URLSession(configuration: configuration, delegate: delegate, delegateQueue: delegateQueue)
        
        self.init(session: session,
                  delegate: delegate,
                  rootQueue: rootQueue,
                  interceptor: interceptor,
                  requestQueue: requestQueue,
                  serializationQueue: serializationQueue
                  )
    }
    // MARK: - UploadRequest

        struct ParameterlessRequestConvertible: URLRequestConvertible {
            let url: URLConvertible
            let method: HTTPMethod
            let headers: HTTPHeaders?

            func asURLRequest() throws -> URLRequest {
                return try URLRequest(url: url, method: method, headers: headers)
            }
        }

        struct Upload: UploadConvertible {
            let request: URLRequestConvertible
            let uploadable: UploadableConvertible

            func createUploadable() throws -> UploadRequest.Uploadable {
                return try uploadable.createUploadable()
            }

            func asURLRequest() throws -> URLRequest {
                return try request.asURLRequest()
            }
        }

        // MARK: Data

        /// Creates an `UploadRequest` for the given `Data`, `URLRequest` components, and `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - data:        The `Data` to upload.
        ///   - convertible: `URLConvertible` value to be used as the `URLRequest`'s `URL`.
        ///   - method:      `HTTPMethod` for the `URLRequest`. `.post` by default.
        ///   - headers:     `HTTPHeaders` value to be added to the `URLRequest`. `nil` by default.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `DataRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ data: Data,
                         to convertible: URLConvertible,
                         method: HTTPMethod = .post,
                         headers: HTTPHeaders? = nil,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            let convertible = ParameterlessRequestConvertible(url: convertible, method: method, headers: headers)

            return upload(data, with: convertible,  fileManager: fileManager)
        }

        /// Creates an `UploadRequest` for the given `Data` using the `URLRequestConvertible` value and `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - data:        The `Data` to upload.
        ///   - convertible: `URLRequestConvertible` value to be used to create the `URLRequest`.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `DataRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ data: Data,
                         with convertible: URLRequestConvertible,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            return upload(.data(data), with: convertible,  fileManager: fileManager)
        }

        // MARK: File

        /// Creates an `UploadRequest` for the file at the given file `URL`, using a `URLRequest` from the provided
        /// components and `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - fileURL:     The `URL` of the file to upload.
        ///   - convertible: `URLConvertible` value to be used as the `URLRequest`'s `URL`.
        ///   - method:      `HTTPMethod` for the `URLRequest`. `.post` by default.
        ///   - headers:     `HTTPHeaders` value to be added to the `URLRequest`. `nil` by default.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `UploadRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ fileURL: URL,
                         to convertible: URLConvertible,
                         method: HTTPMethod = .post,
                         headers: HTTPHeaders? = nil,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            let convertible = ParameterlessRequestConvertible(url: convertible, method: method, headers: headers)

            return upload(fileURL, with: convertible,  fileManager: fileManager)
        }

        /// Creates an `UploadRequest` for the file at the given file `URL` using the `URLRequestConvertible` value and
        /// `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - fileURL:     The `URL` of the file to upload.
        ///   - convertible: `URLRequestConvertible` value to be used to create the `URLRequest`.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `DataRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ fileURL: URL,
                         with convertible: URLRequestConvertible,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            return upload(.file(fileURL, shouldRemove: false), with: convertible,  fileManager: fileManager)
        }

        // MARK: InputStream

        /// Creates an `UploadRequest` from the `InputStream` provided using a `URLRequest` from the provided components and
        /// `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - stream:      The `InputStream` that provides the data to upload.
        ///   - convertible: `URLConvertible` value to be used as the `URLRequest`'s `URL`.
        ///   - method:      `HTTPMethod` for the `URLRequest`. `.post` by default.
        ///   - headers:     `HTTPHeaders` value to be added to the `URLRequest`. `nil` by default.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `DataRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ stream: InputStream,
                         to convertible: URLConvertible,
                         method: HTTPMethod = .post,
                         headers: HTTPHeaders? = nil,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            let convertible = ParameterlessRequestConvertible(url: convertible, method: method, headers: headers)

            return upload(stream, with: convertible,  fileManager: fileManager)
        }

        /// Creates an `UploadRequest` from the provided `InputStream` using the `URLRequestConvertible` value and
        /// `RequestInterceptor`.
        ///
        /// - Parameters:
        ///   - stream:      The `InputStream` that provides the data to upload.
        ///   - convertible: `URLRequestConvertible` value to be used to create the `URLRequest`.
        ///   - interceptor: `RequestInterceptor` value to be used by the returned `DataRequest`. `nil` by default.
        ///   - fileManager: `FileManager` instance to be used by the returned `UploadRequest`. `.default` instance by
        ///                  default.
        ///
        /// - Returns:       The created `UploadRequest`.
        open func upload(_ stream: InputStream,
                         with convertible: URLRequestConvertible,
                         interceptor: RequestInterceptor? = nil,
                         fileManager: FileManager = .default) -> UploadRequest {
            return upload(.stream(stream), with: convertible,  fileManager: fileManager)
        }

        

        // MARK: - Internal API

        // MARK: Uploadable

        func upload(_ uploadable: UploadRequest.Uploadable,
                    with convertible: URLRequestConvertible,
                    interceptor: RequestInterceptor? = nil,
                    fileManager: FileManager) -> UploadRequest {
            let uploadable = Upload(request: convertible, uploadable: uploadable)

            return upload(uploadable,  fileManager: fileManager)
        }

        func upload(_ upload: UploadConvertible, fileManager: FileManager) -> UploadRequest {
            let request = UploadRequest(convertible: upload,
                                        underlyingQueue: rootQueue,
                                        serializationQueue: serializationQueue,
                                        interceptor: interceptor,
                                        fileManager: fileManager,
                                        delegate: self)

            perform(request)

            return request
        }

        // MARK: Perform

        /// Perform `Request`.
        ///
        /// - Note: Called during retry.
        ///
        /// - Parameter request: The `Request` to perform.
        func perform(_ request: Request) {
            switch request {
            case let r as DataRequest: perform(r)
            case let r as UploadRequest: perform(r)
            case let r as DownloadRequest: perform(r)
            default: fatalError("Attempted to perform unsupported Request subclass: \(type(of: request))")
            }
        }

        func perform(_ request: DataRequest) {
            requestQueue.async {
                guard !request.isCancelled else { return }

                self.activeRequests.insert(request)

                self.performSetupOperations(for: request, convertible: request.convertible)
            }
        }

        func perform(_ request: UploadRequest) {
            requestQueue.async {
                guard !request.isCancelled else { return }

                self.activeRequests.insert(request)

                do {
                    let uploadable = try request.upload.createUploadable()
                    self.rootQueue.async { request.didCreateUploadable(uploadable) }

                    self.performSetupOperations(for: request, convertible: request.convertible)
                } catch {
                    self.rootQueue.async { request.didFailToCreateUploadable(with: error.asAFError(or: .createUploadableFailed(error: error))) }
                }
            }
        }

        func perform(_ request: DownloadRequest) {
            requestQueue.async {
                guard !request.isCancelled else { return }

                self.activeRequests.insert(request)

                switch request.downloadable {
                case let .request(convertible):
                    self.performSetupOperations(for: request, convertible: convertible)
                case let .resumeData(resumeData):
                    self.rootQueue.async { self.didReceiveResumeData(resumeData, for: request) }
                }
            }
        }

        func performSetupOperations(for request: Request, convertible: URLRequestConvertible) {
            let initialRequest: URLRequest

            do {
                initialRequest = try convertible.asURLRequest()
                try initialRequest.validate()
            } catch {
                rootQueue.async { request.didFailToCreateURLRequest(with: error.asAFError(or: .createURLRequestFailed(error: error))) }
                return
            }

            rootQueue.async { request.didCreateInitialURLRequest(initialRequest) }

            guard !request.isCancelled else { return }

            guard let adapter = adapter(for: request) else {
                rootQueue.async { self.didCreateURLRequest(initialRequest, for: request) }
                return
            }

            adapter.adapt(initialRequest, for: self) { result in
                do {
                    let adaptedRequest = try result.get()
                    try adaptedRequest.validate()

                    self.rootQueue.async {
                        request.didAdaptInitialRequest(initialRequest, to: adaptedRequest)
                        self.didCreateURLRequest(adaptedRequest, for: request)
                    }
                } catch {
                    self.rootQueue.async { request.didFailToAdaptURLRequest(initialRequest, withError: .requestAdaptationFailed(error: error)) }
                }
            }
        }

        // MARK: - Task Handling

        func didCreateURLRequest(_ urlRequest: URLRequest, for request: Request) {
            request.didCreateURLRequest(urlRequest)

            guard !request.isCancelled else { return }

            let task = request.task(for: urlRequest, using: session)
            requestTaskMap[request] = task
            request.didCreateTask(task)

            updateStatesForTask(task, request: request)
        }

        func didReceiveResumeData(_ data: Data, for request: DownloadRequest) {
            guard !request.isCancelled else { return }

            let task = request.task(forResumeData: data, using: session)
            requestTaskMap[request] = task
            request.didCreateTask(task)

            updateStatesForTask(task, request: request)
        }

        func updateStatesForTask(_ task: URLSessionTask, request: Request) {
            request.withState { state in
                switch (startRequestsImmediately, state) {
                case (true, .initialized):
                    rootQueue.async { request.resume() }
                case (false, .initialized):
                    break
                case (_, .resumed):
                    task.resume()
                    rootQueue.async { request.didResumeTask(task) }
                case (_, .suspended):
                    task.suspend()
                    rootQueue.async { request.didSuspendTask(task) }
                case (_, .cancelled):
                    // Resume to ensure metrics are gathered.
                    task.resume()
                    task.cancel()
                    rootQueue.async { request.didCancelTask(task) }
                case (_, .finished):
                    // Do nothing
                    break
                }
            }
        }

        // MARK: - Adapters and Retriers

        func adapter(for request: Request) -> RequestAdapter? {
            if let requestInterceptor = request.interceptor, let sessionInterceptor = interceptor {
                return Interceptor(adapters: [requestInterceptor, sessionInterceptor])
            } else {
                return request.interceptor ?? interceptor
            }
        }

        func retrier(for request: Request) -> RequestRetrier? {
            if let requestInterceptor = request.interceptor, let sessionInterceptor = interceptor {
                return Interceptor(retriers: [requestInterceptor, sessionInterceptor])
            } else {
                return request.interceptor ?? interceptor
            }
        }

        // MARK: - Invalidation

        func finishRequestsForDeinit() {
            requestTaskMap.requests.forEach { $0.finish(error: AFError.sessionDeinitialized) }
        }
    }

    // MARK: - RequestDelegate

    extension GYSession: RequestDelegate {
        public var sessionConfiguration: URLSessionConfiguration {
            return session.configuration
        }

        public func cleanup(after request: Request) {
            activeRequests.remove(request)
        }

        public func retryResult(for request: Request, dueTo error: AFError, completion: @escaping (RetryResult) -> Void) {
            guard let retrier = retrier(for: request) else {
                rootQueue.async { completion(.doNotRetry) }
                return
            }

            retrier.retry(request, for: self, dueTo: error) { retryResult in
                self.rootQueue.async {
                    guard let retryResultError = retryResult.error else { completion(retryResult); return }

                    let retryError = AFError.requestRetryFailed(retryError: retryResultError, originalError: error)
                    completion(.doNotRetryWithError(retryError))
                }
            }
        }

        public func retryRequest(_ request: Request, withDelay timeDelay: TimeInterval?) {
            rootQueue.async {
                let retry: () -> Void = {
                    guard !request.isCancelled else { return }

                    request.prepareForRetry()
                    self.perform(request)
                }

                if let retryDelay = timeDelay {
                    self.rootQueue.after(retryDelay) { retry() }
                } else {
                    retry()
                }
            }
        }
    }

    // MARK: - SessionStateProvider

extension GYSession: SessionStateProvider {
    
        func request(for task: URLSessionTask) -> Request? {
            return requestTaskMap[task]
        }

        func didGatherMetricsForTask(_ task: URLSessionTask) {
            requestTaskMap.disassociateIfNecessaryAfterGatheringMetricsForTask(task)
        }

        func didCompleteTask(_ task: URLSessionTask) {
            requestTaskMap.disassociateIfNecessaryAfterCompletingTask(task)
        }

        func credential(for task: URLSessionTask, in protectionSpace: URLProtectionSpace) -> URLCredential? {
//            return requestTaskMap[task]?.credential ??
//                session.configuration.urlCredentialStorage?.defaultCredential(for: protectionSpace)
            return session.configuration.urlCredentialStorage?.defaultCredential(for: protectionSpace)
        }

        func cancelRequestsForSessionInvalidation(with error: Error?) {
            requestTaskMap.requests.forEach { $0.finish(error: AFError.sessionInvalidated(error: error)) }
        }
    }

