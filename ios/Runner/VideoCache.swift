//
//  VideoCache.swift
//  Runner
//
//  Created by Ujas Majithiya on 13/06/23.
//
//
//import Foundation
//import HLSCachingReverseProxyServer
//
//
//class VideoCache {
//    let server = HLSCachingReverseProxyServer()
//    
//    init() {
//        server.start(port: 8080)
//    }
//    
//    func getProxyUrl(url: URL) -> URL{
//        return server.reverseProxyURL(from: url)!
//    }
//    
//}
