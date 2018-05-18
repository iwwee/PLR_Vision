//
//  VideoViewController.swift
//  PLR_Vision
//
//  Created by NathanYu on 2018/5/7.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa

class VideoViewController: NSViewController {
    @IBOutlet weak var countLabel: NSTextField!
    
    @IBOutlet weak var videoWindow: NSImageView!
    
    @IBOutlet weak var platesInfoList: NSTableView!
    
    @IBOutlet weak var plateImageList: NSScrollView!
    
    var selectButton: CircularButton!
    var videoPath: String!
    var timer: Timer!
    var finished = false
    
    var platesInfoArray: NSMutableArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    func setupUI() {
        
        self.view.wantsLayer =  true
        self.view.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
        
        selectButton = CircularButton()
        selectButton.button.delegate = self
        selectButton.frame = NSMakeRect(365, 5, 90, 90)
        selectButton.state = .select
        self.view.addSubview(selectButton)
        
        plateImageList.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1)
        platesInfoList.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 0.7)
        platesInfoList.register(NSNib(nibNamed: NSNib.Name(rawValue: "PlateCell"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PlateCellID"))
        platesInfoList.action = #selector(cellClicked)
        
    }
    
}

// MARK: - tableView delegate
extension VideoViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var license = "未检测到车牌"
        var color: String!
        if let dict = platesInfoArray?[row] as? NSMutableDictionary {
            color = dict["color"] as! String
            license = "\(color!): "
            license += dict["license"] as! String
        }
        
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "PlateCellID"), owner: nil) as! PlateCell
        
        if color != nil {
            cell.updateUI(color: color, license: license)
        }

        return cell
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rowview"), owner: nil) as? CustomRowView
        if rowView == nil {
            rowView = CustomRowView()
            rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: "rowview")
        }
        return rowView
    }
    
}

// MARK: - tableView dataSource
extension VideoViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (platesInfoArray == nil) ? 0 : platesInfoArray!.count
    }
}

extension VideoViewController: CustomBtnProtocal {
    func buttonPressed(_ button: CustomButton) {
        switch button.currentState {
        case .scan:
           analyseVideo()
        case .select:
            chooseVideoFromFiles()
        case .stop:
            break
        }
    }
}

extension VideoViewController {
    
    
    // 转到识别详情页面
    @objc func cellClicked() {
        
        print("cell \(platesInfoList.selectedRow) clicked! ")
        
        print("cell frame: \(platesInfoList.frameOfCell(atColumn: 0, row: platesInfoList.selectedRow))")
        
    }
    
    // 视频文件选择
    func chooseVideoFromFiles() {
        // 视频文件选择
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["avi"]
        panel.begin { (result) in
            if result == .OK {
                if let url = panel.url {
                    
                    var path = url.absoluteString
                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                    path.removeSubrange(range)
                    
                    self.videoPath = path
                    self.selectButton.state = .scan
                }
            }
        }
    }
    
    // 视频流分析
    func analyseVideo() {
        if let path = videoPath {
            
            // 后台处理视频
            DispatchQueue.global().async {
                ImageConverter.startAnalyseVideo(path)
                self.finished = true
            }
            
            updataVideoFrame()
            timer = Timer.scheduledTimer(timeInterval: 1/30, target: self, selector: #selector(updataVideoFrame), userInfo: nil, repeats: true)
            timer?.fire()
        }
    }
    
    // 更新视频帧
    @objc func updataVideoFrame() {
        if let dict = ImageConverter.getVideoFrame() {
            let state = dict["finish"] as! Bool
            if state == true {
                if self.finished == true {
                    timer?.invalidate()
                    self.selectButton.state = .select
                }
            } else {
                self.videoWindow.image = dict["frame"] as! NSImage
                self.platesInfoArray = dict["info"] as? NSMutableArray
                self.platesInfoList.reloadData()
                let count = self.platesInfoArray?.count ?? 0
                self.countLabel.stringValue = "识别车牌数: \(count)"
            }
        }
    }
}
















