//
//  PlayingController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 12/05/2023.
//

import UIKit
import AVFoundation
import MediaPlayer


class PlayingController: UIViewController {
    //MARK: properties
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSinger: UILabel!
    @IBOutlet weak var imgSong: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var btnPlayView: UIButton!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var currentTime: UILabel!
    
    @IBOutlet weak var imgBack: UIImageView!
    
    @IBOutlet weak var favouriteImg: UIButton!
    @IBOutlet weak var imgForward: UIImageView!
    
    @IBAction func preSong(_ sender: Any) {
        CustomTabbarViewController.player?.currentTime = 0
    }
    @IBAction func nextSong(_ sender: Any) {
//        stopTimer()
        print("ahihihi")
        let group = DispatchGroup()
        group.enter()
        callAPINextSong() { (success) in
            if success {
                // Xử lý dữ liệu từ API
                print(CustomTabbarViewController.currentSong.getName())
                let url = URL(string: "https://soundboxfree.000webhostapp.com/storage/app/public/filePaths/" + CustomTabbarViewController.currentSong.getFilePath())!
                let session = URLSession.shared
                let task = session.dataTask(with: url) { (data, response, error) in
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = data {
                        do {
                            CustomTabbarViewController.player = try AVAudioPlayer(data: data)
                            CustomTabbarViewController.player!.play()
                            CustomTabbarViewController.isPlaying = true
                            CustomTabbarViewController.isPause = false
                            
                            //cập nhật lại giao diện
                            DispatchQueue.main.async {
                                self.stopTimer()
                                self.startTimer()
                                if (CustomTabbarViewController.favoriteIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
                                    self.favouriteImg.setImage(UIImage(named: "favoriteIsActive"), for: .normal)
                                }
                                else {
                                    self.favouriteImg.setImage(UIImage(named: "heart"), for: .normal)
                                }
                                self.btnPlayView.setImage(UIImage(named: "pause"), for: .normal)
                                self.lbltitle.text = CustomTabbarViewController.currentSong.getName() + " by " + CustomTabbarViewController.currentSong.getSinger()
                                self.lblName.text = CustomTabbarViewController.currentSong.getName()
                                self.lblSinger.text = CustomTabbarViewController.currentSong.getSinger()
                                let url = URL(string: "https://soundboxfree.000webhostapp.com/storage/app/public/thumbnails/" + CustomTabbarViewController.currentSong.getThumbnail())
                                let session = URLSession.shared
                                let task = session.dataTask(with: url!) { (data, response, error) in
                                    if let error = error {
                                        // Xử lý lỗi
                                        print("Error: \(error.localizedDescription)")
                                        return
                                    }
                                    
                                    if let data = data {
                                        // Xử lý dữ liệu nhận được
                                        DispatchQueue.main.async {
                                            self.imgSong.image = UIImage(data: data)
                                            // Cập nhật giao diện trên main thread
                                            // ...
                                            
                                        }
                                    }
                                }
                                task.resume()
                            }
                        } catch {
                            print("Playing error")
                        }
                    }
                }
                
                task.resume()
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            } else {
                // Xử lý lỗi từ cuộc gọi API
                
                // Đánh dấu cuộc gọi API đã hoàn thành
                print(CustomTabbarViewController.currentSong.getName())
                group.leave()
            }
        }
    }
    
    @IBOutlet weak var imgFavourite: UIButton!
    @IBAction func btnFavourite(_ sender: UIButton) {
        if (!CustomTabbarViewController.favoriteIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
            sender.setImage(UIImage(named: "favoriteIsActive"), for: .normal)
            CustomTabbarViewController.favoriteIds.append(String(CustomTabbarViewController.currentSong.getID()))
        }
        else {
            
            sender.setImage(UIImage(named: "heart"), for: .normal)
            CustomTabbarViewController.favoriteIds.remove(at: CustomTabbarViewController.favoriteIds.firstIndex(of: String(CustomTabbarViewController.currentSong.getID()))!)
        }
        
        let group = DispatchGroup()
        group.enter()
        CustomTabbarViewController.callAPIFavouriteSong() { (success) in
            if success {
                // Xử lý dữ liệu từ API
                
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            } else {
                // Xử lý lỗi từ cuộc gọi API
                
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            }
        }
        print(CustomTabbarViewController.favoriteIds)
    }
    @IBOutlet weak var actionMenu: UIStackView!
    
//    var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CustomTabbarViewController.favoriteIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
            imgFavourite.setImage(UIImage(named: "favoriteIsActive"), for: .normal)
        }
        // Do any additional setup after loading the view.
        imgSong.layer.cornerRadius = 36
        //        print(CustomTabbarViewController.currentSong.getName())
        lbltitle.text = CustomTabbarViewController.currentSong.getName() + " by " + CustomTabbarViewController.currentSong.getSinger()
        lblName.text = CustomTabbarViewController.currentSong.getName()
        lblSinger.text = CustomTabbarViewController.currentSong.getSinger()
        let url = URL(string: "https://soundboxfree.000webhostapp.com/storage/app/public/thumbnails/" + CustomTabbarViewController.currentSong.getThumbnail())
        let session = URLSession.shared
        let task = session.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                // Xử lý lỗi
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                // Xử lý dữ liệu nhận được
                DispatchQueue.main.async {
                    self.imgSong.image = UIImage(data: data)
                    // Cập nhật giao diện trên main thread
                    // ...
                    
                }
            }
        }
        task.resume()
        
        if (!CustomTabbarViewController.isPlaying && !CustomTabbarViewController.isPause) {
            btnPlayView.setImage(UIImage(named: "resume"), for: .normal)
          
        }
        else {
            stopTimer()
            startTimer()
            if (!CustomTabbarViewController.isPause) {
                btnPlayView.setImage(UIImage(named: "pause"), for: .normal)
               

            }
            else {
                btnPlayView.setImage(UIImage(named: "resume"), for: .normal)
            }
        }
    }
    
    
    @IBAction func btnPlay(_ sender: UIButton) {
        stopTimer()
        if (CustomTabbarViewController.currentSong.getID() != -1 ) {
            if (!CustomTabbarViewController.isPlaying) {
                do {
                    CustomTabbarViewController.player!.play()
                    startTimer()
                    CustomTabbarViewController.isPlaying = true
                    //cập nhật lại icon khi phát bài hát
                    sender.setImage(UIImage(named: "pause"), for: .normal)
                }
            }
            else {
                if (!CustomTabbarViewController.isPause) {
                    CustomTabbarViewController.player?.stop()
//                    stopTimer()
                    CustomTabbarViewController.isPause = true;
                    //cập nhật lại icon khi phát bài hát
                    sender.setImage(UIImage(named: "resume"), for: .normal)
                }
                else
                {
                    CustomTabbarViewController.player?.play()
                    startTimer()
                    CustomTabbarViewController.isPause = false
                    sender.setImage(UIImage(named: "pause"), for: .normal)
                }
            }
        }
        
    }
    func startTimer() {
        print("timesss")
        let totalTimeSong = CustomTabbarViewController.player!.duration
        CustomTabbarViewController.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            print("timesss++++")
            let currentTimeSong = CustomTabbarViewController.player!.currentTime
            let time = currentTimeSong / totalTimeSong
            self.progressBar.progress = Float(time)
            self.currentTime.text = self.convertSecondsToMinutesSeconds(seconds: Int(currentTimeSong))
            self.totalTime.text = self.convertSecondsToMinutesSeconds(seconds: Int(totalTimeSong - currentTimeSong))
            if (currentTimeSong <= 0) {
                self.btnPlayView.setImage(UIImage(named: "resume"), for: .normal)
                CustomTabbarViewController.isPlaying = false
                CustomTabbarViewController.isPause = false
                self.stopTimer()
            }
        }
    }
    func stopTimer() {
        print("stop")
        CustomTabbarViewController.timer?.invalidate()
        CustomTabbarViewController.timer = nil
    }
    func convertSecondsToMinutesSeconds(seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        let timeString = String(format: "%2d:%02d", minutes, remainingSeconds)
        return timeString
    }
    func iPhoneScreenSizes() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        if (width <= 600) {
//            actionMenu.frame = CGRect(x: 0, y: 0, width: 400, height: 50)
        }
        else {
            
        }
    }
    func callAPINextSong(completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://soundboxfree.000webhostapp.com/public/api/next") else {
            // Handle error when URL is invalid
            return
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: req, completionHandler: { (data, res, err) in
            guard let data = data else {
                // Handle error when data is nil
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                // Handle error when JSON serialization fails
                return
            }
            
            guard let song = json["data"] as? [String: Any] else {
                // Handle error when extracting "data" field fails
                return
            }
            
            if let id = song["id"] as? Int,
               let name = song["name"] as? String,
               let filePath = song["file_path"] as? String,
               let thumbnail = song["thumbnail"] as? String,
               let singer = song["singer"] as? String,
               let listens = song["listens"] as? Int {
                let currentSong = Song(id: id, name: name, filePath: filePath, thumbnail: thumbnail, singer: singer, listens: listens)
                CustomTabbarViewController.currentSong = currentSong
                //cập nhật lại danh sách bài hát phát gần đây sau  khi gọi xong api
                if (!CustomTabbarViewController.recentlyIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
                    CustomTabbarViewController.recentlyIds.insert(String(CustomTabbarViewController.currentSong.getID()), at: 0)
                }
                else {
                    guard let index =  CustomTabbarViewController.recentlyIds.firstIndex(of: (String(CustomTabbarViewController.currentSong.getID()))) else {
                        return
                    }
                    CustomTabbarViewController.recentlyIds.remove(at: index)
                    CustomTabbarViewController.recentlyIds.insert(String(CustomTabbarViewController.currentSong.getID()), at: 0)
                }
                
                //cập nhật lại danh sách bài hát phát gần đây sau  khi gọi xong api
                let group = DispatchGroup()
                group.enter()
                CustomTabbarViewController.callAPIRecentlySong() { (success) in
                    if success {
                        // Xử lý dữ liệu từ API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    } else {
                        // Xử lý lỗi từ cuộc gọi API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    }
                }
                group.enter()
                CustomTabbarViewController.updateListens(id: CustomTabbarViewController.currentSong.getID() ) { (success) in
                    if success {
                        // Xử lý dữ liệu từ API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    } else {
                        // Xử lý lỗi từ cuộc gọi API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    }
                }
                group.enter()
                CustomTabbarViewController.callAPIRecommedSong() { (success) in
                    if success {
                        // Xử lý dữ liệu từ API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    } else {
                        // Xử lý lỗi từ cuộc gọi API
                        
                        // Đánh dấu cuộc gọi API đã hoàn thành
                        group.leave()
                    }
                }
                completion(true)
            } else {
                // Handle error when accessing song properties fails
            }
        }).resume()
        
    }    /*
          // MARK: - Navigation
          
          // In a storyboard-based application, you will often want to do a little preparation before navigation
          override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          // Get the new view controller using segue.destination.
          // Pass the selected object to the new view controller.
          }
          */
    
}
