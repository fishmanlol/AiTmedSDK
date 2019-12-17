//
//  AiTmedError.swift
//  Prynote
//
//  Created by Yi Tong on 10/29/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//
public enum AiTmedError: Error {
    case credentialRequired
    case signinRequired
    case grpcFailed(GRPCError)
    case apiResultFailed(APIResultError)
    case unkown(String)
    
    public enum GRPCError {
        var title: String {
            
        }
        
        var detail: String {
            
        }
    }
    
    public  enum APIResultError {
        var title: String {
            
        }
        
        var detail: String {
            
        }
    }
    
    var title: String {
        return
    }
    
    var detail: String {
        
    }
}
