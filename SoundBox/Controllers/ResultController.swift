//
//  ResultController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 17/05/2023.
//

import UIKit
import AVFoundation

class ResultController: UIViewController, UITableViewDataSource  {
    
    

    //MARK: properties
    
    @IBOutlet weak var listResultSong: UITableView!
    let insetsSession = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    var itemsPerRow: CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        listResultSong.dataSource = self
        
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CustomTabbarViewController.resultSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReccommedTableViewCell
        let song = CustomTabbarViewController.resultSongs[indexPath.row]
        
        
        let url = URL(string: Constant.API_URL+"/storage/thumbnails/" + song.getThumbnail())
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
                        // Cập nhật giao diện trên main thread
                        // ...
                        cell.imgSong.image = UIImage(data: data)
                    }
                }
            }
            task.resume()
        
        cell.imgSong.layer.cornerRadius = 8;
        cell.lblName.text = song.getName()
        cell.lblSinger.text = song.getSinger()
        cell.lblListens.text = "\(String(song.getListens())) / steams"
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(playingSelctedSong), for: .touchUpInside)
        return cell
    }
    
    //MARK: hàm chơi bài hát khi được chọn
    @objc func playingSelctedSong(sender:UIButton) {
        let index = IndexPath(row: sender.tag, section: 0)
        CustomTabbarViewController.currentSong = CustomTabbarViewController.resultSongs[index.row]
        if (!CustomTabbarViewController.recentlyIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
            CustomTabbarViewController.recentlyIds.insert(String(CustomTabbarViewController.currentSong.getID()), at: 0)
            MyLocalStorage.recentlyIds = CustomTabbarViewController.recentlyIds
        }
        else {
            guard let index =  CustomTabbarViewController.recentlyIds.firstIndex(of: (String(CustomTabbarViewController.currentSong.getID()))) else {
                return
            }
            CustomTabbarViewController.recentlyIds.remove(at: index)
            CustomTabbarViewController.recentlyIds.insert(String(CustomTabbarViewController.currentSong.getID()), at: 0)
            MyLocalStorage.recentlyIds = CustomTabbarViewController.recentlyIds
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
//        print(CustomTabbarViewController.currentSong.getName())
  
            let url = URL(string: Constant.API_URL+"/storage/filePaths/" + CustomTabbarViewController.currentSong.getFilePath())!
                
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
                            //giao diện phát nhạc được hiện lên khi bài hát được phát
                            DispatchQueue.main.async {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let controller = storyboard.instantiateViewController(withIdentifier: "PlayingController")
                                self.present(controller, animated: true, completion: nil)
                            }
                        } catch {
                            print("Playing error")
                        }
                    }
                }
                
                task.resume()
        }
    

}
