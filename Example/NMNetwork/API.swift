//
//  API.swift
//  NMNetwork_Example
//
//  Created by xuyunshi on 2018/10/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import NMNetwork
import Moya

enum TestAPI {
    case success
}

extension TestAPI: NMTargetType {
    var para: [String : Any]? {
        switch self {
        case .success:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
    
    var baseURL: URL {
            #if DEBUG
            return URL(string: "http://obd-api.netmi.com.cn")!
            #else
            return URL(string: "http://obd-api.netmi.com.cn")!
            #endif

    }
    
    var path: String {
        switch self {
        case .success:
            return "/base/intel-api/info"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
}
