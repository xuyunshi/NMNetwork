//
//  NMTargetType+Request.swift
//  NMNetwork
//
//  Created by xuyunshi on 2018/9/30.
//

import Moya
import SwiftyJSON

public typealias SimpleSuccessCompletion = (_ result: Data) -> Void

public extension NMTargetType {
    
    /// 便利请求方法
    /// 只会处理成功
    /// 不管失败
    ///
    /// - Parameter completion: 成功回调
    @discardableResult
    func convenientrequest(completion: @escaping SimpleSuccessCompletion) -> Cancellable {
        return request(callbackQueue: .none, autoHandleError: true, progress: .none) { (result) in
            switch result {
            case .success(let response):
                completion(response.data)
            case .failure(_):
                return
            }
        }
    }
    
    /// 统一请求方法
    ///
    /// - Parameters:
    ///   - callbackQueue: 回调线程，默认在主线程
    ///   - progress: 进程回调，默认不处理
    ///   - completion: 完成回调，必传
    ///   - autoHandleError: 自动处理错误。默认自动处理
    /// - Returns: ignore
    @discardableResult
    func request(callbackQueue: DispatchQueue? = .none,
                 autoHandleError: Bool = true,
                 progress: ProgressBlock? = .none,
                 completion: @escaping Completion) -> Cancellable {
        
        /// 插件数组
        var plugins:[PluginType] = []
        
        #if DEBUG
        plugins.append(NMNetworkLogPugin())
        #endif
        
        // 发送网络请求开始的通知
        NotificationCenter.default.post(name: .init(NMNetwork.kNetWorkBeginRequestNotification),
                                        object: nil,
                                        userInfo: ["api":self])
        
        let provider = MoyaProvider<Self>(endpointClosure: NMNetwork.defaultEndpointMapping, plugins:plugins)
        
        return provider.request(self, callbackQueue: callbackQueue,
                                progress: { (progressResponse) in
                                    
                                    // if you want do something before progress global
                                    
                                    // please add code here
                                    
                                    progress?(progressResponse)
        }) { (result) in
            // do something completion global
            switch result {
            case .success(let response):
                let base = NMBaseResponse(JSON(response.data))
                if base.success {
                    // 发送网络请求成功的通知
                    NotificationCenter.default.post(name: .init(NMNetwork.kNetWorkSuccessRequestNotification),
                                                    object: nil,
                                                    userInfo: ["api":self])
                    // 请求成功，服务器正确,完成回调，返回
                    completion(result)
                } else {
                    // 请求成功，服务器错误,根据参数决定谁来处理
                    
                    // 发送网络请求失败的通知
                    
                    let r: (()->Void) = {
                        self.request(callbackQueue: callbackQueue, autoHandleError: autoHandleError, progress: progress, completion: completion)
                    }
                    
                    NotificationCenter.default.post(name: .init(NMNetwork.kNetWorkErrorRequestNotification),
                                                    object: nil,
                                                    userInfo: ["api":self, "request":r])
                    
                    // token过期
                    if base.errorType == .tokenExpire {
                        if NMNetwork.reauthHandler != nil {
                            reauth(completion: { (success) in
                                if success {
                                    // 重新请求
                                    self.request(callbackQueue: callbackQueue,
                                                 autoHandleError: autoHandleError,
                                                 progress: progress,
                                                 completion: completion)
                                } else {
                                    // 发送需要重新登录的通知
                                    let noti = Notification(name: Notification.Name.init(NMNetwork.kAppNeedLoginNotification))
                                    NotificationCenter.default.post(noti)
                                }
                            })
                        }
                    }
                    
                    // 是否自动处理错误
                    if autoHandleError {
                        NMNetwork.autoServeErrorHandler?(result)
                    } else {
                        // 让调用者自己处理
                        completion(result)
                    }
                }
                return
            case .failure(let error):
                
                // 发送网络请求失败的通知
                let r: (()->Void) = {
                    self.request(callbackQueue: callbackQueue, autoHandleError: autoHandleError, progress: progress, completion: completion)
                }
                
                NotificationCenter.default.post(name: .init(rawValue: NMNetwork.kNetWorkErrorRequestNotification),
                                                object: nil,
                                                userInfo: ["api":self, "request":r])
                
                // 请求失败错误
                switch error {
                case .underlying(let e as NSError, _):
                    let errorDescribe = e.urlErrorDescribe
                    // 请求失败的处理，根据参数决定由谁处理
                    if autoHandleError {
                        NMNetwork.autoNetErrorHandler?(errorDescribe)
                    } else {
                        // 让调用者自己处理
                        completion(result)
                    }
                    return
                default:
                    if autoHandleError {
                        NMNetwork.autoNetErrorHandler?(error.errorDescription ?? "error")
                    } else {
                        completion(result)
                    }
                    return
                }
            }
        }
    }
}

/// 重新获取token三次
///
/// - Parameter completion: 完成回调

private func reauth(completion: @escaping (Bool)->Void) {
    if let block = NMNetwork.reauthHandler {
        block({ success in
            if success {
                // 请求次数重置
                NMNetwork.ReauthRequestTime = 0
                completion(true)
            } else {
                if NMNetwork.ReauthRequestTime >= 2 {
                    completion(false)
                } else {
                    reauth(completion: completion)
                }
            }
        })
    }
}


/// 公共错误返回结构体
struct NMBaseResponse: Codable {
    var errorMsg: String
    
    var success: Bool
    
    private var errorCode: Int
    
    var errorType: ErrorType {
        get {
            return ErrorType(rawValue: errorCode) ?? .unKnown
        }
    }
    
    init(_ json: JSON) {
        errorCode = json["errcode"].intValue
        success = json["errcode"].intValue == 0
        errorMsg = json["errmsg"].stringValue
    }
    
    enum ErrorType: Int {
        /// token过期
        case tokenExpire = 10000
        /// 未知错误
        case unKnown
    }
}

/// Error的本地化处理
extension NSError {
    var urlErrorDescribe: String {
        switch self.code {
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return "网络不给力，请稍后重试"
        case NSURLErrorTimedOut:
            return "连接服务器超时，请稍后重试"
        case NSURLErrorCannotConnectToHost, NSURLErrorRedirectToNonExistentLocation:
            return "无法连接服务器"
        case NSURLErrorBadServerResponse:
            return "服务器出错，请稍后重试"
        default:
            return "网络不给力，请稍后重试"
        }
    }
}
