//
//  NMTargetType.swift
//  NMNetwork
//
//  Created by xuyunshi on 2018/9/30.
//

import Moya

public protocol NMTargetType: TargetType{
    /// parameter
    var para: [String: Any]? { get }
    
    /// encoding
    var encoding: ParameterEncoding { get }
}

public extension TargetType where Self: NMTargetType{
    
    var sampleData: Data { return Data() }
    
    /// The headers to be used in the request.
    var headers: [String: String]? { return nil }
    
    /// The type of validation to perform on the request. Default is `.none`.
    var validationType: ValidationType { return .none }
    
    var task: Task {
        if let p = para {
            return .requestParameters(parameters: p, encoding: encoding)
        } else {
            return .requestPlain
        }
    }
}
