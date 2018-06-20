//
//  LoadingWindowController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/10.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class LoadingWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let window = window {
            window.backgroundColor = NSColor.clear
    
            // 窗口居中显示
            window.setFrame(NSMakeRect(0, 0, 428, 600), display: true)
            window.center()
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+4) {
            // storyboard加载视图控制器
            let mainWindow = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "MainViewController")) as! WindowController
            
            // 以主窗口显示
            mainWindow.window?.makeKeyAndOrderFront(nil)
            //  退出目前窗口
            self.window?.orderOut(nil)

        }
       
    }
}

























