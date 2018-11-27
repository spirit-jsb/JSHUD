//
//  ViewController.swift
//  JSHUD-Demo
//
//  Created by Max on 2018/11/19.
//  Copyright © 2018 Max. All rights reserved.
//

import UIKit
import JSHUD

struct JSExample {
    let title: String
    let selector: Selector
    
    init(withTitle title: String, selector: Selector) {
        self.title = title
        self.selector = selector
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, URLSessionDownloadDelegate, JSHUDDelegate {
    
    // MARK: 属性
    var examples: [[JSExample]] = [[JSExample(withTitle: "Loading Example", selector: #selector(loadingExample)),
                                    JSExample(withTitle: "Loading With label Example", selector: #selector(labelExample)),
                                    JSExample(withTitle: "Loading With details label Example", selector: #selector(detailsLabelExample))],
                                   [JSExample(withTitle: "Bar progress Example", selector: #selector(barExample)),
                                    JSExample(withTitle: "Ring progress Example", selector: #selector(ringExample)),
                                    JSExample(withTitle: "Sector progress Example", selector: #selector(sectorExample))],
                                   [JSExample(withTitle: "Bar NSProgress Example", selector: #selector(barProgressExample)),
                                    JSExample(withTitle: "Ring NSProgress Example", selector: #selector(ringProgressExample)),
                                    JSExample(withTitle: "Sector NSProgress Example", selector: #selector(sectorProgressExample))],
                                   [JSExample(withTitle: "Text Example", selector: #selector(textExample)),
                                    JSExample(withTitle: "Custom Example", selector: #selector(customExample))],
                                   [JSExample(withTitle: "Mode switching Example", selector: #selector(modeSwitchingExample)),
                                    JSExample(withTitle: "Window Example", selector: #selector(windowExample)),
                                    JSExample(withTitle: "Networking Example", selector: #selector(networkingExample)),
                                    JSExample(withTitle: "Solid Background Color", selector: #selector(solidBackgroundColor)),
                                    JSExample(withTitle: "Content Color Example", selector: #selector(contentColorExample))]]

    // MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Example
    @objc private func loadingExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func labelExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.label.text = "Loading..."
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func detailsLabelExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.label.text = "Loading..."
        hud.detailsLabel.text = "Parsing data\n(1/1)"
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func barExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .barProgress
        hud.label.text = "Loading..."
        DispatchQueue.global().async {
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func ringExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .ringProgress
        hud.label.text = "Loading..."
        hud.detailsLabel.text = "Parsing data\n(1/1)"
        DispatchQueue.global().async {
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func sectorExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .sectorProgress
        hud.label.text = "Loading..."
        DispatchQueue.global().async {
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func barProgressExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .barProgress
        hud.label.text = "Loading..."
        
        let progressObject = Progress(totalUnitCount: 100)
        hud.progressObject = progressObject
        
        DispatchQueue.global().async {
            self.doSomeWorkWithProgressObject(progressObject)
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func ringProgressExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .ringProgress
        hud.label.text = "Loading..."
        hud.detailsLabel.text = "Parsing data\n(1/1)"
        
        let progressObject = Progress(totalUnitCount: 100)
        hud.progressObject = progressObject
        
        DispatchQueue.global().async {
            self.doSomeWorkWithProgressObject(progressObject)
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func sectorProgressExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .sectorProgress
        hud.label.text = "Loading..."
        
        let progressObject = Progress(totalUnitCount: 100)
        hud.progressObject = progressObject
        
        DispatchQueue.global().async {
            self.doSomeWorkWithProgressObject(progressObject)
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func textExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .text
        hud.label.text = "Message here!"
        
        hud.offset = CGPoint(x: 0.0, y: JSHUD.JSProgressMaxOffset)
        
        hud.hideAnimated(true, afterDelay: 3.0)
    }
    
    @objc private func customExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.mode = .custom
        hud.label.text = "Success here!"
        
        let image = UIImage(named: "icon_check")?.withRenderingMode(.alwaysTemplate)
        hud.customView = UIImageView(image: image)
        
        hud.hideAnimated(true, afterDelay: 3.0)
    }
    
    @objc private func modeSwitchingExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        
        hud.tag = 1
        hud.delegate = self
        hud.label.text = "Preparing..."
        hud.minSize = CGSize(width: 150.0, height: 100.0)
        
        DispatchQueue.global().async {
            self.doSomeWorkWithMixedProgress(hud)
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func windowExample() {
        let hud = JSHUD.showHUD(addTo: self.view.window!, animated: true)
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func networkingExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.label.text = "Preparing..."
        hud.minSize = CGSize(width: 150.0, height: 100.0)
        
        self.doSomeNetworkWorkWithProgress()
    }
    
    @objc private func solidBackgroundColor() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        
        hud.backgroundView.backgroundStyle = .solidColor
        hud.backgroundView.color = UIColor.red.withAlphaComponent(0.1)
        
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    @objc private func contentColorExample() {
        let hud = JSHUD.showHUD(addTo: self.navigationController!.view, animated: true)
        hud.contentColor = UIColor(red: 0.0, green: 0.6, blue: 0.7, alpha: 1.0)
        
        hud.label.text = "Loading..."
        
        DispatchQueue.global().async {
            self.doSomeWork()
            DispatchQueue.main.async {
                hud.hideAnimated(true)
            }
        }
    }
    
    // MARK: 私有方法
    private func doSomeWork() {
        sleep(3)
    }
    
    private func doSomeWorkWithProgress() {
        var progress: Float = 0.0
        while progress < 1.0 {
            progress = progress + 0.01
            DispatchQueue.main.async {
                JSHUD.HUD(for: self.navigationController!.view)?.progress = progress
            }
            usleep(50000)
        }
    }
    
    private func doSomeWorkWithProgressObject(_ progressObject: Progress) {
        while progressObject.fractionCompleted < 1.0 {
            progressObject.becomeCurrent(withPendingUnitCount: 1)
            progressObject.resignCurrent()
            usleep(50000)
        }
    }
    
    private func doSomeWorkWithMixedProgress(_ hud: JSHUD) {
        sleep(2)
        
        DispatchQueue.main.async {
            hud.mode = .barProgress
            hud.label.text = "Loading"
        }
        
        var progress: Float = 0.0
        while progress < 1.0 {
            progress = progress + 0.01
            DispatchQueue.main.async {
                hud.progress = progress
            }
            usleep(50000)
        }
        
        DispatchQueue.main.async {
            hud.mode = .loading
            hud.label.text = "Cleaning up..."
        }
        
        sleep(2)
        
        DispatchQueue.main.sync {
            hud.mode = .custom
            hud.label.text = "Completed"
            
            let image = UIImage(named: "icon_check")?.withRenderingMode(.alwaysTemplate)
            hud.customView = UIImageView(image: image)
        }
        
        sleep(3)
    }
    
    private func doSomeNetworkWorkWithProgress() {
        let sessionConfiguration = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let url = URL(string: "https://support.apple.com/library/APPLE/APPLECARE_ALLGEOS/HT1425/sample_iPod.m4v.zip")
        let task = session.downloadTask(with: url!)
        task.resume()
    }

    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.examples[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let example = self.examples[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "JSExampleCell", for: indexPath)
        cell.textLabel?.text = example.title
        cell.textLabel?.textColor = self.view.tintColor
        cell.textLabel?.textAlignment = .center
        cell.selectedBackgroundView = UIView()
        cell.selectedBackgroundView?.backgroundColor = cell.textLabel?.textColor.withAlphaComponent(0.1)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.examples.count
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let example = self.examples[indexPath.section][indexPath.row]
        self.perform(example.selector)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: URLSessionDownloadDelegate
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        DispatchQueue.main.async {
            let hud = JSHUD.HUD(for: self.navigationController!.view)
            hud?.mode = .custom
            hud?.label.text = "Success here!"
            
            let image = UIImage(named: "icon_check")?.withRenderingMode(.alwaysTemplate)
            hud?.customView = UIImageView(image: image)
            
            hud?.hideAnimated(true, afterDelay: 3.0)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            let hud = JSHUD.HUD(for: self.navigationController!.view)
            hud?.mode = .barProgress
            hud?.progress = progress
        }
    }
    
    // MARK: JSHUDDelegate
    func hudWasHidden(_ hud: JSHUD) {
        print("HUD Tag: \(hud.tag) was Hidden")
    }
}

