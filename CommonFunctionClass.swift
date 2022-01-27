//
//  CommonFunction.swift
//  LightWalker
//
//  Created by Yoshinori Okamura on 2015/01/05.
//  Copyright (c) 2015年 Yoshinori Okamura. All rights reserved.
//

import UIKit
import Foundation
import SystemConfiguration

class CommonFunction : NSObject {
    /**
     * ログで出すクラス名
     * NSLOGは ろぐ 辞書登録済
     * AppDelegateは でり で辞書登録済
     * 下記 ClassNameプロパティの記述は必須
     */
    //let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!

    /**
     * AppDelegateの記述省略。何故かprivateしかスコープがない。
     * 
     */
    //let appDelegate : AppDelegate! = (UIApplication.sharedApplication().delegate as AppDelegate)
    

    /**
     * リアルタイムデータのデータベースファイル名
     * 
     */
    let cullentDB : String = "/current.sqlite" as String

    /**
     * 日付時刻フォーマットの定義
     */
    let dateFormatter = NSDateFormatter()

    /**
     * 文字列の変換コード配列
     */
    let EncodeLine_args = [
        NSUTF8StringEncoding,
        NSShiftJISStringEncoding,
        NSISO2022JPStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSASCIIStringEncoding,
        NSUnicodeStringEncoding
    ]

    /**
     * Array_Favorite向けの配列
     */
    var favorite_idArray : [Int] = []
    var favorite_titleArray : [String] = []
    var favorite_uriArray   : [String] = []
    var favorite_kubunArray   : [Int] = []

//-----------------------------< ここから関数 >---------------------------------------------

    /**
     * 
     * パスがFileかURLかを判断
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func MakeFileFLG(UrlStr : String) -> Bool {
        return (String(UrlStr).rangeOfString("^((http)s?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)",options: NSStringCompareOptions.RegularExpressionSearch) != nil) ? false : true
    }

    /**
     * 
     * 時刻を数字に変換
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func JikokutoInt(Time : String) -> Int {
        return Time.rangeOfString(":") != nil ? Time.componentsSeparatedByString(":")[0].toInt()!*60+Time.componentsSeparatedByString(":")[1].toInt()! : 0
    }

    /**
     * 
     * ベースURLを算出
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func BaseUrlEcho(UtrStr : String) -> String {
        var work = MakeFileFLG(UtrStr) ? UtrStr.stringByReplacingOccurrencesOfString("file:/", withString: "", options: nil, range: nil).componentsSeparatedByString("/") : UtrStr.componentsSeparatedByString("/")
        work.removeLast()
        return String(join("/", work)) + "/"
    }

    /**
     * 
     * Doubleを文字列に変換
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func DoubletoString2(DBL : Double) -> String {
        let SeiSu = String(format: "%f",DBL).componentsSeparatedByString(".")[0]
        let Len = String(format: "%f",DBL).componentsSeparatedByString(".")[1]
        //return String(format: "%@.%@%@",SeiSu,"\(Len[advance(Len.startIndex, 0)])","\(Len[advance(Len.startIndex, 1)])")
        return String(format: "%@.%@",SeiSu,"\(Len[advance(Len.startIndex, 0)])")
    }
    /**
     * 
     * 数字を時刻に変換
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func IntToJikoku(Input : Int) -> String {
        var Fun = Input % 60
        return String(format: "%02d:%02d",(Input-Fun) / 60,Fun )
    }

    /**
     * 
     * バイトを適切にまとめる(KBとかMBとか)
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func KMByteStrings(Bytes : UInt64) -> String {
        var intByte : Int = 0
        var strByte : String?
        if(Bytes < 1024) {
            intByte = 1;
            strByte = "";
        } else if(Bytes >= 1024 && Bytes < 1048576){
            intByte = 1024;
            strByte = "K";
        } else {
            intByte = 1048576;
            strByte = "M";
        }
        return String(format: "%ld.%@%@",Int(Bytes) / intByte,(String(format: "%03ld",Int(Bytes) % intByte) as NSString).substringToIndex(2),strByte!)
    }
    /**
     * 
     * 現在の日時をゲットする
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func NowDateTimeGet()-> String {
        //----------------------------------------------------------
        // フォーマッターの定義
        //----------------------------------------------------------
        SetDateFormatter()
        return dateFormatter.stringFromDate(NSDate())
    }

    /**
     * 
     * 概要:切り捨てを行い結果を返す
     * 
     * @param value:切り捨て対象の値 figures:何桁目を切り捨てるかを指定
     * @return String
     * @exception <pre>正の値:少数点以下の値を切り捨てる
                       負の値:整数部分の値を切り捨てる</pre>
     * @see
     * @since
     * @deprecated
     */
    func ponvireFloor(value:Double, figures:Int) -> Double {
        let tmp:Double = pow(10.0, Double(figures))
        return value > 0.0 ? floor(value * tmp) / tmp : ceil(value * tmp) / tmp
    }

    /**
     * 
     * 日付時刻フォーマットの定義
     * 
     * @param 
     * @return String
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func SetDateFormatter(){
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") // ロケールの設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm" // 日付フォーマットの設定
        return
    }

    /**
     * 
     * ネットワークがつながっているかどうか判定
     * 
     * @param
     * @return
     * @exception
     * @see
     * @since
     * @deprecated
     */
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection) ? true : false
    }

    /**
     * 
     * 概要:お気に入りURLを登録する(UIWebView)
     * 
     * @param value:切り捨て対象の値 figures:何桁目を切り捨てるかを指定
     * @return String
     * @see
     * @since
     * @deprecated
     */
    func DB_Favorite(UrlStr:String, Title:String) -> Bool {

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //----------------------------------------------------------
        // データベースの設定
        //----------------------------------------------------------
        let db = FMDatabase(path: appDelegate.databasePath + cullentDB)
        let RecordURL = String(UrlStr).rangeOfString("^((http)s?://[-_.!~*'()a-zA-Z0-9;/?:@&=+$,%#]+)",options: NSStringCompareOptions.RegularExpressionSearch) == nil ? String(format: "%@",UrlStr.stringByReplacingOccurrencesOfString(appDelegate.Document, withString: "", options: nil, range: nil)) : UrlStr

        //----------------------------------------------------------
        // データベースオープン
        //----------------------------------------------------------
        db.open()
        let results1 = db.executeQuery(
            String(format:"select count(favorite_kubun) from Favorite_List where favorite_uri = '%@' and favorite_kubun = 0;",RecordURL), withArgumentsInArray: nil
        )
        if results1.next() {
            if(Int(results1.intForColumn("count(favorite_kubun)")) > 0 ){
                return false
            }
        } else {
            return false
        }
        let Ret = db.executeUpdate(
        "insert into Favorite_List (favorite_title,favorite_uri,favorite_kubun) values(?,?,?);", 
        withArgumentsInArray: ["\(Title)","\(RecordURL)","0"]
        )

        //----------------------------------------------------------
        // データベースクローズ
        //----------------------------------------------------------
        results1.close()
        db.close()
        return Ret
    }

    /**
     * 
     * 概要:SSH接続履歴を登録する
     * 
     * @param UrlStr:SSHのホスト Title:SSHユーザ名
     * @return String
     * @see
     * @since
     * @deprecated
     */
    func DB_SSHConnect(UrlStr:String, Title:String) -> Bool {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //----------------------------------------------------------
        // データベースの設定
        //----------------------------------------------------------
        let db = FMDatabase(path: appDelegate.databasePath + cullentDB)

        //----------------------------------------------------------
        // データベースオープン
        //----------------------------------------------------------
        db.open()
        let results1 = db.executeQuery(
            String(format:"select count(favorite_id) from favorite_List where favorite_uri = '%@' and favorite_kubun = 1;",UrlStr), withArgumentsInArray: nil
        )
        if results1.next() {
            if(Int(results1.intForColumn("count(favorite_id)")) > 0 ){
                return false
            }
        } else {
            return false
        }

        let Ret = db.executeUpdate(
        "insert into favorite_List (favorite_title,favorite_uri,favorite_kubun) values(?,?,?);", 
        withArgumentsInArray: ["\(Title)","\(UrlStr)","1"]
        )

        //----------------------------------------------------------
        // データベースクローズ
        //----------------------------------------------------------
        results1.close()
        db.close()
        return Ret
    }

    /**
     * 
     * 概要:お気に入り一覧を表示する
     * 
     * @param 配列はCommonクラスで管理
     * @return String
     * @exception 
     * @see
     * @since
     * @deprecated
     */
    func Array_Favorite() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        //----------------------------------------------------------
        // 配列初期化
        //----------------------------------------------------------
        favorite_titleArray  = []
        favorite_uriArray    = []
        favorite_kubunArray   = []
        favorite_idArray   = []

        //----------------------------------------------------------
        // データベースの設定
        //----------------------------------------------------------
        let db = FMDatabase(path: appDelegate.databasePath + cullentDB)

        //----------------------------------------------------------
        // データベースオープン
        //----------------------------------------------------------
        db.open()

        //----------------------------------------------------------
        // お気に入りを配列に格納
        //----------------------------------------------------------
        let results1 = db.executeQuery(
            "select favorite_id,favorite_title,favorite_uri,favorite_kubun from Favorite_List order by favorite_kubun;", withArgumentsInArray: nil
        )

        while results1.next() {
            favorite_idArray.append(Int(results1.intForColumn("favorite_id")))
            favorite_titleArray.append(results1.stringForColumn("favorite_title"))
            favorite_uriArray.append(results1.stringForColumn("favorite_uri"))
            favorite_kubunArray.append(Int(results1.intForColumn("favorite_kubun")))
        }
        results1.close()

        //----------------------------------------------------------
        // データベースクローズ
        //----------------------------------------------------------
        db.close()
        return
    }

    /**
     * 
     * 概要:お気に入りを消す
     * 
     * @param 配列はCommonクラスで管理
     * @return String
     * @exception 
     * @see
     * @since
     * @deprecated
     */
    func DEL_Favorite(FavoriteID:Int) -> Bool {

        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        //----------------------------------------------------------
        // データベースの設定
        //----------------------------------------------------------
        let db = FMDatabase(path: appDelegate.databasePath + cullentDB)

        //----------------------------------------------------------
        // データベースオープン
        //----------------------------------------------------------
        db.open()
        let Ret = db.executeUpdate(
            String(format: "delete from Favorite_List where favorite_id = %d;",FavoriteID), 
            withArgumentsInArray: nil
        )

        //----------------------------------------------------------
        // データベースクローズ
        //----------------------------------------------------------
        db.close()
        return Ret
    }

}/* End Of Class */
