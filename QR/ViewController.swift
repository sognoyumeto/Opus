//
//  ViewController.swift
//  QR
//
//  Created by Yumeto Sasamori on 2018/08/24.
//  Copyright © 2018年 Yumeto Sasamori. All rights reserved.
//
import Foundation
import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // creating object
    private let session = AVCaptureSession()
    
    
    @IBOutlet weak var focus: UIImageView!
    @IBOutlet weak var layer: UIView!
    @IBOutlet weak var logo: UIImageView!
    
    //読み取り範囲設定view1:1と考えた比率設定
    let x: CGFloat = 0.5
    let y: CGFloat = 0.5
    let width: CGFloat = 0.5
    let height: CGFloat = 0.8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // back camera
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                mediaType: .video,
                                                                position: .back)
        
        // getting device
        let devices = discoverySession.devices
        
        //　getting first device
        if let backCamera = devices.first {
            do {
                // using backcamera for input
                let deviceInput = try AVCaptureDeviceInput(device: backCamera)
                
                if self.session.canAddInput(deviceInput) {
                    self.session.addInput(deviceInput)
                    
                    // recognition to QR code
                    let metadataOutput = AVCaptureMetadataOutput()
                    
                    if self.session.canAddOutput(metadataOutput) {
                        self.session.addOutput(metadataOutput)
                        
                        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                        metadataOutput.metadataObjectTypes = [.qr]
                        
                        //検出エリアの設定
                        metadataOutput.rectOfInterest = CGRect(x: y,y: 1-x-width,width: height,height: width)

                        // preview QRcode
                        let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
                        previewLayer.frame = self.view.bounds
                        previewLayer.videoGravity = .resizeAspectFill
                        self.view.layer.addSublayer(previewLayer)
                        
                        self.view.bringSubview(toFront: layer)
                        self.view.bringSubview(toFront: focus)
                        self.view.bringSubview(toFront: logo)
                        
                        // decode
                        self.session.startRunning()
                    }
                }
            } catch {
                print("データの取得に失敗しました: \(error)")
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRcode?
            if metadata.type != .qr { continue }
            
            // QRcode nil?
            if metadata.stringValue == nil { continue }
            
            
            // URL?
            if let url = URL(string: metadata.stringValue!) {
                //decoding done
                self.session.stopRunning()
                // open by safari
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
                break
            }
        }
        
    }
    // 縦画面固定
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面をPortraitに指定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
}
    

