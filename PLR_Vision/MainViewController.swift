//
//  MainViewController.swift
//  PlateLicenseRecognition
//
//  Created by NathanYu on 2018/4/7.
//  Copyright © 2018 NathanYu. All rights reserved.
//

import Cocoa
import AVFoundation

class MainViewController: NSViewController {
    
    @IBOutlet weak var leftView: NSView!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var carImageView: NSImageView!
    @IBOutlet weak var plateLabel: NSTextField!
    @IBOutlet weak var welcomeLabel: NSTextField!
    
    @IBOutlet weak var resultView: NSView!
    @IBOutlet weak var plateImageView: NSImageView!
    @IBOutlet weak var platesNumber: NSTextField!
    @IBOutlet weak var plateLicense: NSTextField!
    @IBOutlet weak var plateColor: NSTextField!
    @IBOutlet weak var char1: NSImageView!
    @IBOutlet weak var resChar1: NSTextField!
    @IBOutlet weak var similarity1: NSTextField!
    @IBOutlet weak var char2: NSImageView!
    @IBOutlet weak var char3: NSImageView!
    @IBOutlet weak var char4: NSImageView!
    @IBOutlet weak var char5: NSImageView!
    @IBOutlet weak var char6: NSImageView!
    @IBOutlet weak var char7: NSImageView!
    @IBOutlet weak var resChar2: NSTextField!
    @IBOutlet weak var resChar3: NSTextField!
    @IBOutlet weak var resChar4: NSTextField!
    @IBOutlet weak var resChar5: NSTextField!
    @IBOutlet weak var resChar6: NSTextField!
    @IBOutlet weak var resChar7: NSTextField!
    @IBOutlet weak var similarity2: NSTextField!
    @IBOutlet weak var similarity3: NSTextField!
    @IBOutlet weak var similarity4: NSTextField!
    @IBOutlet weak var similarity5: NSTextField!
    @IBOutlet weak var similarity6: NSTextField!
    @IBOutlet weak var similarity7: NSTextField!
    @IBOutlet weak var nextButton: NSButton!
    @IBOutlet weak var preButton: NSButton!
    @IBOutlet weak var audioButton: NSButton!
    
    var mainButton: CircularButton!
    var carImgPath: String!
    var soundPlayer: AVAudioPlayer?
    var currentIndex: Int!
    var plateCounts: Int!
    var platesDict: NSMutableDictionary?
    
    var videoPath: String?
    var timer: Timer?
    var finished = false
    var isVideoMode = false
    
    lazy var videoViewController: VideoViewController = {
        // storyboard加载视图控制器
        let vc = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "VideoViewController")) as! VideoViewController
        return vc
    }()
    
    // MARK: -
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
                
    }
    
    
    func setupUI() {
        
        leftView.wantsLayer = true
        leftView.layer?.backgroundColor = NSColor(red: 44 / 255, green: 43  / 255, blue: 51 / 255, alpha: 1).cgColor
        
        mainView.wantsLayer = true
        mainView.layer?.backgroundColor = NSColor(red: 97/255, green: 97/255, blue: 110/255, alpha: 1).cgColor
        
        tableView.backgroundColor = NSColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.action = #selector(cellClicked)
        
        // 注册nib
        tableView.register(NSNib(nibNamed: NSNib.Name("CustomCell"), bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCellID"))
        
        mainButton = CircularButton()
        mainButton.button.delegate = self
        mainButton.frame = NSMakeRect(365, 5, 90, 90)
        mainButton.state = .select
        mainView.addSubview(mainButton)
       
        let image = NSImage(named: NSImage.Name(rawValue: "mainlogo"))
        carImageView.image = image
        
        resultView.alphaValue = 0
        
        // 选中首行
        let firstIndex = IndexSet(integer: 0)
        tableView.selectRowIndexes(firstIndex, byExtendingSelection: false)
    }
    
   @objc func mainBtnPressed() {
        switch mainButton.state {
        case .select:
            chooseImageFromFiles()
        case .scan:
            recognizeImage()
        case .stop:
            break
    
        }
    }
    
    @IBAction func analyseVideo(_ sender: NSButton) {
      
    }
    
    @objc func updataVideoFrame() {
       
    }
    
    // 播放当前显示的车牌号码
    @IBAction func audioButtonPressed(_ sender: NSButton) {
        if soundPlayer?.isPlaying == false {
            let license = self.plateLicense.stringValue as NSString
            
            // 后台播放音乐
            DispatchQueue.global().async {
                
                self.playPlateSound(license: license)
            }
        }
    }
    
    
    // 显示下一个车牌信息
    @IBAction func nextButtonPressed(_ sender: NSButton) {
        // 显示识别出的车牌个数
        let newVal = self.currentIndex + 1
        self.currentIndex = newVal
        if self.currentIndex == self.plateCounts {
            self.nextButton.isEnabled = false
        }
        self.preButton.isEnabled = true
        self.platesNumber.stringValue = "\(newVal)/\(self.plateCounts!)"
        
        // 显示下个识别车牌号
        if let dict = platesDict {
            let licenseArray = dict["license"] as! NSMutableArray
            self.plateLicense.stringValue = (licenseArray[newVal - 1] as! NSString) as String
            
            // 播放下一个识别出的车牌号
            DispatchQueue.global().async {
                self.playPlateSound(license: licenseArray[newVal - 1] as! NSString)
            }
            
            // 显示下个车牌颜色
            let colorArray = dict["color"] as! NSMutableArray
            self.plateColor.stringValue = (colorArray[newVal - 1] as! NSString) as String
            
            // 显示下个车牌分割图片
            if let image = NSImage(byReferencingFile: "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/plate\(newVal - 1).jpg") {
                self.plateImageView.image = image
            }
            
            // 显示下个车牌中字符识别结果及相似度
            let dictArry = dict["detail"] as! NSMutableArray
            let firstArray = dictArry[newVal - 1] as! NSMutableArray
            for i in 0...6 {
                let path = "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/\(newVal - 1)char_\(i).jpg"
                if let image = NSImage(byReferencingFile: path) {
                    
                    let infoDict = firstArray[i] as! NSMutableDictionary
                    let predict = (infoDict.allKeys[0] as! NSString) as String
                    let pre_sim = (infoDict[predict] as! Float) * 100;
                    
                    switch i {
                    case 0:
                        self.char1.image = image
                        self.resChar1.stringValue = predict
                        
                        if pre_sim >= 99.995 {
                            self.similarity1.stringValue = "100%"
                        } else {
                            self.similarity1.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                        
                    case 1:
                        self.char2.image = image
                        self.resChar2.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity2.stringValue = "100%"
                        } else {
                            self.similarity2.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 2:
                        self.char3.image = image
                        self.resChar3.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity3.stringValue = "100%"
                        } else {
                            self.similarity3.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 3:
                        self.char4.image = image
                        self.resChar4.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity4.stringValue = "100%"
                        } else {
                            self.similarity4.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 4:
                        self.char5.image = image
                        self.resChar5.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity5.stringValue = "100%"
                        } else {
                            self.similarity5.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 5:
                        self.char6.image = image
                        self.resChar6.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity6.stringValue = "100%"
                        } else {
                            self.similarity6.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 6:
                        self.char7.image = image
                        self.resChar7.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity7.stringValue = "100%"
                        } else {
                            self.similarity7.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    default:
                        break;
                    }
                }
            }
            
            self.mainButton.state = .select
            self.plateLabel.stringValue = ""
        }
        
        
    }
    
    // 显示上一个车牌信息
    @IBAction func preButtonPressed(_ sender: NSButton) {
        
        // 显示识别出的车牌个数
        let newVal = self.currentIndex - 1
        self.currentIndex = newVal
        if self.currentIndex == 1 {
            self.preButton.isEnabled = false
        }
        self.nextButton.isEnabled = true
        self.platesNumber.stringValue = "\(newVal)/\(self.plateCounts!)"
        
        // 显示上一个识别车牌号
        if let dict = platesDict {
            let licenseArray = dict["license"] as! NSMutableArray
            self.plateLicense.stringValue = (licenseArray[newVal - 1] as! NSString) as String
            
            // 播放上一个识别出的车牌号
            DispatchQueue.global().async {
                self.playPlateSound(license: licenseArray[newVal - 1] as! NSString)
            }
            
            // 显示上一个车牌颜色
            let colorArray = dict["color"] as! NSMutableArray
            self.plateColor.stringValue = (colorArray[newVal - 1] as! NSString) as String
            
            // 显示上一个车牌分割图片
            if let image = NSImage(byReferencingFile: "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/plate\(newVal - 1).jpg") {
                self.plateImageView.image = image
            }
            
            // 显示上一个车牌中字符识别结果及相似度
            let dictArry = dict["detail"] as! NSMutableArray
            let firstArray = dictArry[newVal - 1] as! NSMutableArray
            for i in 0...6 {
                let path = "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/\(newVal - 1)char_\(i).jpg"
                if let image = NSImage(byReferencingFile: path) {
                    
                    let infoDict = firstArray[i] as! NSMutableDictionary
                    let predict = (infoDict.allKeys[0] as! NSString) as String
                    let pre_sim = (infoDict[predict] as! Float) * 100;
                    
                    switch i {
                    case 0:
                        self.char1.image = image
                        self.resChar1.stringValue = predict
                        
                        if pre_sim >= 99.995 {
                            self.similarity1.stringValue = "100%"
                        } else {
                            self.similarity1.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                        
                    case 1:
                        self.char2.image = image
                        self.resChar2.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity2.stringValue = "100%"
                        } else {
                            self.similarity2.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 2:
                        self.char3.image = image
                        self.resChar3.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity3.stringValue = "100%"
                        } else {
                            self.similarity3.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 3:
                        self.char4.image = image
                        self.resChar4.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity4.stringValue = "100%"
                        } else {
                            self.similarity4.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 4:
                        self.char5.image = image
                        self.resChar5.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity5.stringValue = "100%"
                        } else {
                            self.similarity5.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 5:
                        self.char6.image = image
                        self.resChar6.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity6.stringValue = "100%"
                        } else {
                            self.similarity6.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 6:
                        self.char7.image = image
                        self.resChar7.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity7.stringValue = "100%"
                        } else {
                            self.similarity7.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    default:
                        break;
                    }
                }
            }
            
            self.mainButton.state = .select
            self.plateLabel.stringValue = ""
        }
        
        
    }
    
    @objc func cellClicked() {
        print("cell \(tableView.selectedRow) clicked!")
        
        if tableView.selectedRow == 1 && isVideoMode == false {    // 视频识别
           
            self.mainView.addSubview(self.videoViewController.view)
             isVideoMode = true
            
        } else if tableView.selectedRow == 0 && isVideoMode == true {   // 图片识别
            
            self.videoViewController.view.removeFromSuperview()
            isVideoMode = false
        }
    }
}

// MARK: - NSTableView dataSource
extension MainViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
}

// MARK: - NSTableView delegate
extension MainViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CustomCellID"), owner: nil) as! CustomCellView

        if row == 0 {
            cell.textLabel.stringValue = "图片识别"
            let img = NSImage(named: NSImage.Name(rawValue: "choseScan"))
            cell.iconView.image = img
        } else if row == 1 {
            cell.textLabel.stringValue = "视频识别"
            let img = NSImage(named: NSImage.Name(rawValue: "smartScan"))
            cell.iconView.image = img
        }
        return cell
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        var rowView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "rowview"), owner: nil) as? CustomRowView
        if rowView == nil {
            rowView = CustomRowView()
            rowView!.identifier = NSUserInterfaceItemIdentifier(rawValue: "rowview")
        }
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("clicked!.....")
    }
    

    
}

// MARK: - custom func
extension MainViewController {
    
    // 识别后更改界面
    func reLayoutUI(dict: NSMutableDictionary) {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 2.0
            
        }, completionHandler: {
            self.carImageView.frame.origin.x = 20
            self.carImageView.frame.origin.y = 150
            self.carImageView.frame.size.width = 570
            self.carImageView.frame.size.height = 420
            
            
            // 更换绘制过的图片
            if let image = NSImage(byReferencingFile: "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/drawcar.jpg") {
                self.carImageView.image = image
            } else {
                print("can't load drawed image!")
            }
            
            
            self.resultView.alphaValue = 1
            
            // 显示识别出的车牌个数
            let num = dict["number"] as! Int
            if num == 1 {
                self.preButton.isHidden = true
                self.nextButton.isHidden = true
                self.platesNumber.stringValue = "\(num)"
            } else {
                self.preButton.isHidden = false
                self.nextButton.isHidden = false
                self.preButton.isEnabled = false
                self.nextButton.isEnabled = true
                self.platesNumber.stringValue = "1/\(num)"
            }
            
            self.currentIndex = 1
            self.plateCounts = num
            self.platesDict = dict
            
            // 显示首个识别车牌号
            let licenseArray = dict["license"] as! NSMutableArray
            self.plateLicense.stringValue = (licenseArray[0] as! NSString) as String
            
            // 后台播放首个识别出的车牌号
            DispatchQueue.global().async {
                self.playPlateSound(license: licenseArray[0] as! NSString)
            }
            
            // 显示首个车牌颜色
            let colorArray = dict["color"] as! NSMutableArray
            self.plateColor.stringValue = (colorArray[0] as! NSString) as String
            
            // 显示首个车牌分割图片
            if let image = NSImage(byReferencingFile: "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/plate0.jpg") {
                self.plateImageView.image = image
            }
            
            // 显示首个车牌中字符识别结果及相似度
            let dictArry = dict["detail"] as! NSMutableArray
            let firstArray = dictArry[0] as! NSMutableArray
            for i in 0...6 {
                let path = "/Users/NathanYu/Desktop/PLR_Vision/PLR_Vision/resources/0char_\(i).jpg"
                if let image = NSImage(byReferencingFile: path) {
                    
                    let infoDict = firstArray[i] as! NSMutableDictionary
                    let predict = (infoDict.allKeys[0] as! NSString) as String
                    let pre_sim = (infoDict[predict] as! Float) * 100;
                    
                    switch i {
                    case 0:
                        self.char1.image = image
                        self.resChar1.stringValue = predict
                        
                        if pre_sim >= 99.995 {
                            self.similarity1.stringValue = "100%"
                        } else {
                            self.similarity1.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                        
                    case 1:
                        self.char2.image = image
                        self.resChar2.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity2.stringValue = "100%"
                        } else {
                            self.similarity2.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 2:
                        self.char3.image = image
                        self.resChar3.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity3.stringValue = "100%"
                        } else {
                            self.similarity3.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 3:
                        self.char4.image = image
                        self.resChar4.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity4.stringValue = "100%"
                        } else {
                            self.similarity4.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 4:
                        self.char5.image = image
                        self.resChar5.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity5.stringValue = "100%"
                        } else {
                            self.similarity5.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 5:
                        self.char6.image = image
                        self.resChar6.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity6.stringValue = "100%"
                        } else {
                            self.similarity6.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    case 6:
                        self.char7.image = image
                        self.resChar7.stringValue = predict
                        if pre_sim >= 99.995 {
                            self.similarity7.stringValue = "100%"
                        } else {
                            self.similarity7.stringValue = String(format: "%.2f%%", pre_sim)
                        }
                    default:
                        break;
                    }
                }
            }
            
            self.mainButton.state = .select
            self.plateLabel.stringValue = ""
        })
    }
    
    // 更换图片后恢复初始界面
    func recoveryUI() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 1.0
            self.resultView.alphaValue = 0
        }) {
            self.carImageView.frame.origin.x = 110
            self.carImageView.frame.origin.y = 138
            self.carImageView.frame.size.width = 600
            self.carImageView.frame.size.height = 450
        }
    }
    
    // 选取车辆照片
    func chooseImageFromFiles() {
        // 文件选择
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = ["jpg","png","jpeg"]
        panel.begin { (result) in
            if result == .OK {
                if let url = panel.url {
                    let image = NSImage(contentsOf: url)
                    self.carImageView.image = image
                    
                    var path = url.absoluteString
                    let range = path.startIndex...path.index(path.startIndex, offsetBy: 6)
                    path.removeSubrange(range)
                    self.carImgPath = path
                    
                    self.mainButton.state = .scan
                    
                    self.welcomeLabel.isHidden = true
                    self.plateLabel.stringValue = ""
                    
                    // 恢复初始界面
                    self.recoveryUI()
                }
            }
        }
    }
    
    // 识别选中的车辆照片
  @objc func recognizeImage() {
    
        DispatchQueue.main.async {
            self.mainButton.state = .stop
            self.plateLabel.stringValue = "识别中..."
        
            // 加载音效
            self.prepareSound()
        }
    
        // 后台执行
        DispatchQueue.global().async {
            if let dict = ImageConverter.getPlateLicense(self.carImgPath) {
                
                // 主线程更新UI
                DispatchQueue.main.async {
                    
                    // 播放成功音效
                    self.playSound()
                    
                    // 重新布局UI
                    self.reLayoutUI(dict: dict)
                }

            } else {
                
                // 主线程更新UI
                DispatchQueue.main.async {
                    // 播放失败音效
                    self.playSound()
                    
                    self.plateLabel.stringValue = "未能检测到车牌"
                    self.mainButton.state = .select
                }
                
            }
        }
    }
}

// MARK: - custom protocal
extension MainViewController: CustomBtnProtocal {
    func buttonPressed(_ button: CustomButton) {
        switch button.currentState {
        case .scan:
            recognizeImage()
        case .select:
            chooseImageFromFiles()
        case .stop:
            break
        }
    }
}

// MARK: - Sound
extension MainViewController {
    // 加载音效
    func prepareSound() {
        guard let audioFileUrl = Bundle.main.url(forResource: "scanFinished", withExtension: "aiff") else { return }
    
        do {
            soundPlayer = try AVAudioPlayer(contentsOf: audioFileUrl)
            soundPlayer?.prepareToPlay()
        } catch {
            print("Sound player not available: \(error)")
        }
    }
    
    // 播放音效
    func playSound() {
        soundPlayer?.play()
    }
    
    // 播放车牌号码
    func playPlateSound(license: NSString) {
        
        // 更改为正在播放图标
        DispatchQueue.main.async {
            self.audioButton.image = NSImage(named: NSImage.Name(rawValue: "audio_on"))
        }
        
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
        
        /// 更改为未播放图标
        DispatchQueue.main.async {
            self.audioButton.image = NSImage(named: NSImage.Name(rawValue: "audio_off"))
        }
    }
    
}


































