//
//  FavoriteController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 12/05/2023.
//

import UIKit
import AVFoundation

class FavoriteController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: properties
    @IBOutlet weak var listSongCollection: UICollectionView!
    let insetsSession = UIEdgeInsets(top: 0, left: 21, bottom: 0, right: 21)
    var itemsPerRow: CGFloat!;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        CustomTabbarViewController.timer?.invalidate()
        CustomTabbarViewController.timer = nil
        iPhoneScreenSizes()
        listSongCollection.delegate = self
        listSongCollection.dataSource = self
    }
    
    //MARK: Định nghĩa các hàm UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CustomTabbarViewController.favouriteSongs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listSong", for: indexPath) as! ListSongCollectionViewCell
        let song = CustomTabbarViewController.favouriteSongs[indexPath.row]
        //        cell.imgSong.image = song.getImage()
        let url = URL(string: "https://soundboxfree.000webhostapp.com/storage/app/public/thumbnails/" + song.getThumbnail())
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
        cell.btnPlay.tag = indexPath.row
        cell.btnPlay.addTarget(self, action: #selector(playingReccommedSong), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpacing = CGFloat(itemsPerRow + 1) * insetsSession.left
        let availabeWidth = view.frame.width - paddingSpacing
        let width = availabeWidth / itemsPerRow
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        insetsSession
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        insetsSession.left
    }
    
    //MARK: hàm kiểm tra độ rộng của màn hình
    func iPhoneScreenSizes() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        
        if (width <= 430) {
            itemsPerRow = 3
        }
        else {
            itemsPerRow = 4
        }
    }
    
    //MARK: hàm chơi bài hát khi được chọn
    @objc func playingReccommedSong(sender:UIButton) {
        let index = IndexPath(row: sender.tag, section: 0)
        //kiểm tra
        if ((CustomTabbarViewController.favouriteSongs.count - 1) >= index.row) {
            CustomTabbarViewController.currentSong = CustomTabbarViewController.favouriteSongs[index.row]
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
            
        } else {
            listSongCollection.reloadData()
        }
    }
    
}
