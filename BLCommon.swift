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

class BLCommon : CommonFunction {
    /**
     * ログで出すクラス名
     * NSLOGは ろぐ 辞書登録済
     * AppDelegateは でり で辞書登録済
     * 下記 ClassNameプロパティの記述は必須
     */
    let ClassName = __FILE__.componentsSeparatedByString("/").last!.componentsSeparatedByString(".swift").first!

    /**
     * AppDelegateの記述省略。何故かprivateしかスコープがない。
     * 
     */
    //var appDelegate : AppDelegate!

}/* End Of Class */
