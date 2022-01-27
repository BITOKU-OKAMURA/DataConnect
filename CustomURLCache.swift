//
//  CustomURLCache.swift
//  DataConnect
//
//  Created by Yoshinori Okamura on 2015/06/15.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//
import UIKit
import Darwin
import Foundation
class CustomURLCache : NSURLCache {

    /**
     * アドレス文字列
     * 
     */
    var BaseURL : String?

    /**
     * 前回リクエストしたURLを記載(Referer用)
     * 
     */
    var RefererAdress : String?

    /**
     * ユーザエージェント
     * 
     */
    var UserAgent : String?
        
        
    var MIMEType : String!

    override func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse? {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        //-----------------------------------------------------------------------------
        // 変数の定義
        //-----------------------------------------------------------------------------
        let UrlStr = request.URL.absoluteString!.componentsSeparatedByString("?")[0]
        let FileFLG = (String(UrlStr).rangeOfString("^((http)s?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)",options: NSStringCompareOptions.RegularExpressionSearch) != nil) ? false : true
        let Domain = FileFLG ? "" : UrlStr.componentsSeparatedByString("://")[1].componentsSeparatedByString("/")[0]
        let SaveFileName = UrlStr.stringByReplacingOccurrencesOfString("/", withString: " ", options: nil, range: nil)
        let PathExtension = UrlStr.pathExtension
        let tmpPath = String(format: "%@/%@",NSTemporaryDirectory() + "DConeect",SaveFileName)
        let LocalCache = String(format: "%@/%@",(UIApplication.sharedApplication().delegate as AppDelegate).CachePath,UrlStr)
        var filedata : NSData?
        var response : NSURLResponse?

        //-----------------------------------------------------------------------------
        // BaseURLが定義されていない場合は普通に処理
        //-----------------------------------------------------------------------------
        if(BaseURL == nil ||  countElements(BaseURL!) < 1 || FileFLG == true || PathExtension == ""){
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            return super.cachedResponseForRequest(request)
        }

        //-----------------------------------------------------------------------------
        // CSSの処理
        //-----------------------------------------------------------------------------
        if(PathExtension.hasPrefix("css") || PathExtension.hasPrefix("js")){
            MIMEType = PathExtension == "css" ? "text/css" : "text/javascript"

            //-----------------------------------------------------------------------------
            // 一括保存用CSS検索ロジック
            //-----------------------------------------------------------------------------
            if(BaseURL!.hasPrefix("http") == false){
                let SearchPath = String(format: "%@%@",UrlStr.componentsSeparatedByString("://")[1].componentsSeparatedByString(PathExtension.hasPrefix("css") ? ".css" : ".js")[0],PathExtension.hasPrefix("css") ? ".css" : ".js")
                var i : Int = 0
                var SoutaiPath = "./"
                while (i < 7){
                    let WgetCSSPath = String(format: "%@/%@%@",BaseURL!,SoutaiPath,SearchPath)
                    if(NSFileManager.defaultManager().fileExistsAtPath(WgetCSSPath, isDirectory: nil)){
                        filedata = NSData(contentsOfFile: WgetCSSPath)
                        response = NSURLResponse(URL: request.URL,
                            MIMEType: MIMEType,
                            expectedContentLength: filedata!.length,
                            textEncodingName: nil)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        return NSCachedURLResponse(response: response!, data: filedata!)
                    }
                    SoutaiPath = SoutaiPath + "../"
                    i++
                }
            }

            if(NSFileManager.defaultManager().fileExistsAtPath(tmpPath, isDirectory: nil)){
                filedata = NSData(contentsOfFile: tmpPath)
                response = NSURLResponse(URL: request.URL,
                MIMEType: MIMEType,
                expectedContentLength: filedata!.length,
                textEncodingName: nil)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return NSCachedURLResponse(response: response!, data: filedata!)
            } else {
                AsiDownLoadSaveFile(UrlStr ,tmpPath:tmpPath)
                if(PathExtension == "js"){
                    filedata = NSData(data: UIImagePNGRepresentation(UIImage(named:"space.png")))
                    response = NSURLResponse(URL: request.URL,
                    MIMEType: MIMEType,
                    expectedContentLength: filedata!.length,
                    textEncodingName: nil)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    return NSCachedURLResponse(response: response!, data: filedata!)
                } else {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    return super.cachedResponseForRequest(request)
                }
            }
        } 

        //-----------------------------------------------------------------------------
        // 画像の処理
        //-----------------------------------------------------------------------------
        if PathExtension == "jpg" || PathExtension == "png" || PathExtension == "jpeg" {
            
            MIMEType = PathExtension == "png" ? "image/png" : "image/jpeg"
            
            //-----------------------------------------------------------------------------
            // 一括保存用画像検索ロジック
            //-----------------------------------------------------------------------------
            if(BaseURL!.hasPrefix("http") == false){
                let SearchPath = String(format: "%@%@",UrlStr.componentsSeparatedByString("://")[1].componentsSeparatedByString(PathExtension.hasPrefix("png") ? ".png" : ".jpg")[0],PathExtension.hasPrefix("png") ? ".png" : ".jpg")
                var i : Int = 0
                var SoutaiPath = "./"
                while (i < 7){
                    let WgetCSSPath = String(format: "%@/%@%@",BaseURL!,SoutaiPath,SearchPath)
                    if(NSFileManager.defaultManager().fileExistsAtPath(WgetCSSPath, isDirectory: nil)){
                        filedata = NSData(contentsOfFile: WgetCSSPath)
                        response = NSURLResponse(URL: request.URL,
                        MIMEType: MIMEType,
                        expectedContentLength: filedata!.length,
                        textEncodingName: nil)
                        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                        return NSCachedURLResponse(response: response!, data: filedata!)
                    }
                    SoutaiPath = SoutaiPath + "../"
                    i++
                }
            }
            if(NSFileManager.defaultManager().fileExistsAtPath(tmpPath, isDirectory: nil)){
                filedata = NSData(contentsOfFile: tmpPath)
                response = NSURLResponse(URL: request.URL,
                MIMEType: MIMEType,
                expectedContentLength: filedata!.length,
                textEncodingName: nil)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return NSCachedURLResponse(response: response!, data: filedata!)
            } else {
                AsiDownLoadSaveFile(UrlStr ,tmpPath:tmpPath)
                filedata = NSData(data: UIImagePNGRepresentation(UIImage(named:"space.png")))
                response = NSURLResponse(URL: request.URL,
                MIMEType: MIMEType,
                expectedContentLength: filedata!.length,
                textEncodingName: nil)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return NSCachedURLResponse(response: response!, data: filedata!)
            }
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        return super.cachedResponseForRequest(request)
    }

    /**
    *
    * バックグラウンドでファイルを一時領域へ保存
    *
    * @param
    * @return
    * @exception
    * @see
    * @since
    * @deprecated
    */
    func AsiDownLoadSaveFile(UrlStr: NSString , tmpPath:NSString) {
        NSOperationQueue().addOperation(NSBlockOperation(block: {
            let asiRequest = ASIHTTPRequest.requestWithURL(NSURL(string: UrlStr) ,
                username : "" , password:  "" ,  referer: self.BaseURL ,
                userAgent:self.UserAgent) as ASIHTTPRequest
            asiRequest.delegate = self
            asiRequest.startSynchronous()
            if(asiRequest.responseStatusCode < 400 && asiRequest.responseStatusCode > 199){
                NSFileManager.defaultManager().removeItemAtPath(tmpPath, error:nil)
                NSFileManager.defaultManager().createFileAtPath(tmpPath,contents:asiRequest.responseData(), attributes:nil)
            }
        }))
    }

}
