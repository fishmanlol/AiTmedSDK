//
//  AiTmedError.swift
//  Prynote
//
//  Created by Yi Tong on 10/29/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//
public enum AiTmedError: Error {
    case grpcFailed(GRPCError)
    case apiResultFailed(APIResultError)
    case credentialFailed(CredentialError)
    case unkown
    
    var title: String {
        switch self {
        case .credentialFailed(let error):
            return error.title
        case .grpcFailed(let error):
            return error.title
        case .apiResultFailed(let error):
            return error.title
        case .unkown:
            return "AiTmed erorr"
        }
    }
    
    var detail: String {
        switch self {
        case .credentialFailed(let error):
            return error.detail
        case .grpcFailed(let error):
            return error.detail
        case .apiResultFailed(let error):
            return error.detail
        case .unkown:
            return "unkown"
        }
    }
    
    public enum CredentialError {
        case passwordWrong
        case passwordNeeded
        case credentialNeeded
        case signInNeeded
        case JWTExpired(String)
        
        var title: String {
            return "credential error"
        }
        
        var detail: String {
            return "unkown"
        }
    }
    
    public enum GRPCError {
        case unkown
        
        var title: String {
            return "grpc error"
        }
        
        var detail: String {
            return "unkown"
        }
    }
    
    public  enum APIResultError {
        case userNotExist
        case unkown
        
        var title: String {
            return "API error"
        }
        
        var detail: String {
            return "unkonwn"
        }
    }
}
