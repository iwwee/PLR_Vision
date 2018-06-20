//
//  AudioTool.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/6/7.
//  Copyright © 2018年 NathanYu. All rights reserved.
//

import Foundation
import AVFoundation
import AppKit


class AudioTool: NSObject {
    static var soundPlayer: AVAudioPlayer?
    
    
    class func playPlateSound(license: NSString, sender: NSButton) {
        
        DispatchQueue.global().async {
            for i in 0...6 {
                // 加载音效
                let audioName = license.substring(with: NSMakeRange(i, 1))
                guard let audioFileUrl = Bundle.main.url(forResource: audioName, withExtension: "mp3") else { return }
                
                do {
                    soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
                    soundPlayer?.prepareToPlay()
                } catch {
                    print("Sound player not available: \(error)")
                }
                
                // 播放
                soundPlayer?.play()
                
                while(soundPlayer!.isPlaying) {
                    
                }
            }
            
            DispatchQueue.main.async {
                sender.image = NSImage(named: NSImage.Name(rawValue: "audio_off"))
                sender.isEnabled = true
            }
            
        }
        
    }
}
