//
//  NMNetwork.swift
//  NMNetwork
//
//  Created by xuyunshi on 2018/9/30.
//

import Moya
import Result

public typealias ReauthCompletion = (Bool)->Void

public class NMNetwork {
    /// 已经重新请求token的次数
    static var ReauthRequestTime: Int = 0
    /// 开始网络请求的通知名
    static let kNetWorkBeginRequestNotification = "kNetWorkBeginRequestNotification"
    /// 结束网络请求的通知名
    static let kNetWorkSuccessRequestNotification = "kNetWorkSuccessRequestNotification"
    /// 错误网络请求的通知名
    static let kNetWorkErrorRequestNotification = "kNetWorkErrorRequestNotification"
    /// 需要重新登录的通知名
    static let kAppNeedLoginNotification = "kAppNeedLoginNotification"
    
    /// 服务器错误的自动处理
    /// 如果希望自动处理请重写
    open static var autoServeErrorHandler: ((Result<Moya.Response, MoyaError>) -> Void)? = nil
    
    /// 网络请求失败的自动处理
    /// 如果希望自动处理请重写
    open static var autoNetErrorHandler: ((String) -> Void)? = nil
    
    /// 重新连接的代码块
    /// 如果希望自动重连，在这里重写
    open static var reauthHandler: ((ReauthCompletion)->Void)? = nil
    
    /// 默认的Endpoint
    ///
    /// - Parameter target: TargerType
    /// - Returns: Endpoint
    open class func defaultEndpointMapping(for target: NMTargetType) -> Endpoint {
        let task = target.task
//        if AccountManager.shared.isLogin {
//            let token = AccountManager.shared.token!
//            let tokenPara = ["token":token]
//            switch task {
//            case .requestPlain:
//                task = .requestParameters(parameters: tokenPara, encoding: JSONEncoding.default)
//            case .requestData(_):
//                break
//            case .requestJSONEncodable(_):
//                break
//            case .requestCustomJSONEncodable(_, let encoder):
//                break
//            case .requestParameters(let parameters, let encoding):
//                var newPara = parameters
//                newPara["token"] = token
//                task = .requestParameters(parameters: newPara, encoding: encoding)
//            case .requestCompositeData(let bodyData, let urlParameters):
//                break
//            case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
//                break
//            case .uploadFile(_):
//                break
//            case .uploadMultipart(_):
//                break
//            case .uploadCompositeMultipart(_, let urlParameters):
//                break
//            case .downloadDestination(_):
//                break
//            case .downloadParameters(let parameters, let encoding, let destination):
//                break
//            }
//        }
        
        return Endpoint(
            url: target.url.absoluteString,
            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
            method: target.method,
            task: task,
            httpHeaderFields: target.headers
        )
    }
}

extension NMTargetType {
    fileprivate var url: URL {
        get {
            if path.isEmpty {
                return baseURL
            } else {
                return baseURL.appendingPathComponent(path)
            }
        }
    }
}


