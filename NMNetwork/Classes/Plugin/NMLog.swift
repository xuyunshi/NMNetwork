//
//  NMLog.swift
//  NMNetwork
//
//  Created by xuyunshi on 2018/9/30.
//

import Moya
import Result
import SwiftyJSON

class NMNetworkLogPugin: PluginType {
    
    func willSend(_ request: RequestType, target: TargetType) {
        var log = "                                *  *  *  *  *  *"
        log.append("\n")
        log.append("\n")
        log.append("request begin                                ")
        log.append("\n")
        log.append("                                -------------                                ")
        log.append("\n")
        log.append("\n")
        log.append("url: \(target.baseURL.absoluteString + target.path) ")
        log.append("\n")
        
        let task = target.task
        switch task {
        case .requestPlain:
            log.append("para: nil ")
        case .requestParameters(let parameters, let  encoding):
            log.append("                               para: \(parameters) ")
            log.append("\n")
        default:
            break
        }
        log.append("\n")
        log.append("                               -----------                                ")
        log.append("\n")
        log.append("request end                                ")
        log.append("\n")
        log.append("\n")
        log.append("                                *  *  *  *  *  *")
        log.append("\n")
        print(log)
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        var log = "                                *  *  *  *  *  *"
        log.append("\n")
        log.append("\n")
        log.append("response begin                                ")
        log.append("\n")
        log.append("                                -------------                                ")
        log.append("\n")
        log.append("\n")
        log.append("url: \(target.baseURL.absoluteString + target.path) ")
        log.append("\n")
        switch result {
        case .failure(let error):
            
            
            log.append("\n")
            log.append("                               -----------                                ")
            log.append("\n")
            log.append("response failed with \(error.localizedDescription)                             ")
            log.append("\n")
            log.append("\n")
            log.append("                                *  *  *  *  *  *")
            print(log)
        case .success(let s):
            log.append("\n")
            log.append("                               ---------------                                ")
            log.append("\n")
            log.append("response success with                            ")
            log.append("\n")
            log.append("                               ---------------                                ")
            log.append("\n")
            log.append("                               \(JSON(s.data))                            ")
            log.append("\n")
            log.append("\n")
            log.append("\n")
            log.append("                                *  *  *  *  *  *")
            log.append("\n")
            print(log)
        }
    }
}
