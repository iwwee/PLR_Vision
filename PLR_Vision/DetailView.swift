//
//  DetailView.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/17.
//  Copyright © 2018年 NathanYu. All rights reserved.
//

import Cocoa

class DetailView: NSView {
    
    @IBOutlet weak var plateImageView: NSImageView!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var licenseColorLabel: NSTextField!
    @IBOutlet weak var voiceButton: NSButton!
    
    // MARK: - 字符控件绑定tag值
    // charImage: 1001, 2001....7001   charValue: 1002, 2002.....7002    sim: 1003, 2003......7003
    @IBOutlet weak var charImage1: NSImageView!
    @IBOutlet weak var charImage2: NSImageView!
    @IBOutlet weak var charImage3: NSImageView!
    @IBOutlet weak var charImage4: NSImageView!
    @IBOutlet weak var charImage5: NSImageView!
    @IBOutlet weak var charImage6: NSImageView!
    @IBOutlet weak var charImage7: NSImageView!
    
    @IBOutlet weak var charValue1: NSTextField!
    @IBOutlet weak var charValue2: NSTextField!
    @IBOutlet weak var charValue3: NSTextField!
    @IBOutlet weak var charValue4: NSTextField!
    @IBOutlet weak var charValue5: NSTextField!
    @IBOutlet weak var charValue6: NSTextField!
    @IBOutlet weak var charValue7: NSTextField!
    
    @IBOutlet weak var sim1: NSTextField!
    @IBOutlet weak var sim2: NSTextField!
    @IBOutlet weak var sim3: NSTextField!
    @IBOutlet weak var sim4: NSTextField!
    @IBOutlet weak var sim5: NSTextField!
    @IBOutlet weak var sim6: NSTextField!
    @IBOutlet weak var sim7: NSTextField!
    
    
    // MARK: - func
    
    // 更新UI
    func layoutUI(detailDict: NSMutableDictionary) {
        
        // 车牌图片
        let image = detailDict["image"] as! NSImage
        self.plateImageView.image = image
        
        // 车牌号
        let license = detailDict["license"] as! String
        self.licenseLabel.stringValue = license
        
        // 颜色
        let color = detailDict["color"] as! String
        self.licenseColorLabel.stringValue = color
        
        // 字符详情
        let dict = detailDict["detail"] as! NSMutableArray
        for i in 0...6 {

        }
        
        
        
    }
    
    //
    func updateCharInfo(charInfoDict: NSMutableDictionary, index: Int) {
        
        let baseTag = index * 1000
        
        // 根据tag值获取控件
        let charImageView = self.viewWithTag(baseTag + 1) as! NSImageView
        let charValue = self.viewWithTag(baseTag + 2) as! NSTextField
        let charSim = self.viewWithTag(baseTag + 3) as! NSTextField
        
        let predict = (charInfoDict.allKeys[0] as! NSString) as String
        let similarity = (charInfoDict[predict] as! Float) * 100
        
        charValue.stringValue = predict
        charSim.stringValue = (similarity >= 99.995) ? "100%" : String(format: "%.2f%%", similarity)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
}
