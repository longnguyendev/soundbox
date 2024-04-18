//
//  ViewController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 06/05/2023.
//

import UIKit
import AVFoundation

class HomeController: UIViewController, UITableViewDataSource, UICollectionViewDataSource, UITextFieldDelegate {
    //MARK: properties
    @IBOutlet weak var edtSearchSong: UITextField!
    @IBOutlet weak var RecentlySong: UICollectionView!
    @IBOutlet weak var RecommendSong: UITableView!
    
    var resultSongs:[Song] = [Song]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CustomTabbarViewController.timer?.invalidate()
        CustomTabbarViewController.timer = nil
        RecommendSong.dataSource = self
        RecentlySong.dataSource = self
        edtSearchSong.delegate = self
        customSearchTextField()
        
        //tự động ẩn bàn phím khi nhấn vào màn hình
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let group = DispatchGroup()
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
        group.enter()
        CustomTabbarViewController.callAPIRecentlySong() { (success) in
            if success {
                // Xử lý dữ liệu từ API

                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            } else {
                // Xử lý lỗi từ cuộc gọi API
                print("lấy danh sách phát gần đây thất bại")
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            }
        }
        group.enter()
        CustomTabbarViewController.callAPIFavouriteSong() { (success) in
            if success {
                // Xử lý dữ liệu từ API
                
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            } else {
                // Xử lý lỗi từ cuộc gọi API
                print("lấy danh sách yêu thích thất bại")
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            // Render giao diện sau khi hoàn thành cuộc gọi API
            self.RecommendSong.reloadData()
            self.RecentlySong.reloadData()
            
        }
        
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: định nghĩa các hàm uỷ quyền của text field
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //        print("beginnnnnnnn")
        edtSearchSong.resignFirstResponder()
        if (edtSearchSong.text != "") {
            let group = DispatchGroup()
            group.enter()
            searchSong(keyWord: edtSearchSong.text!) { (success) in
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
            
            // Đợi tất cả các hoạt động trong group hoàn thành trước khi render giao diện
            group.notify(queue: DispatchQueue.main) {
                // Render giao diện sau khi hoàn thành cuộc gọi API
                self.edtSearchSong.text = ""
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "Resault Controller")
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        //        print("enddddddddd")
        
        //        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {_ in
        //            let controller = self.storyboard!.instantiateViewController(withIdentifier: "Resault Controller")
        //            self.present(controller, animated: true, completion: nil)
        //        }
        
    }
    
    //MARK: định nghĩa các hàm uỷ quyền cho UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count", CustomTabbarViewController.recentlySongs.count)
        return CustomTabbarViewController.recentlySongs.count
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Recently", for: indexPath) as! RecentlyCollectionViewCell
        
        //lấy bài hát dựa trên index của cell
        let song = CustomTabbarViewController.recentlySongs[indexPath.row]
        
        //khởi tạo url thumbnail dựa trên thumbnail của bài hát
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
        cell.btnAction.tag = indexPath.row
        cell.btnAction.addTarget(self, action: #selector(playingRecentlySong), for: .touchUpInside)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //MARK: định nghĩa các hàm uỷ quyền cho UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CustomTabbarViewController.reccommedSongs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ReccommedTableViewCell
        let song = CustomTabbarViewController.reccommedSongs[indexPath.row]
        
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
        cell.btnPlay.addTarget(self, action: #selector(playingReccommedSong), for: .touchUpInside)
        return cell
    }
    
    //MARK: hàm chơi bài hát khi được chọn
    @objc func playingReccommedSong(sender:UIButton) {
       
        if ((CustomTabbarViewController.reccommedSongs.count) > 0) {
            let index = IndexPath(row: sender.tag, section: 0)
            guard CustomTabbarViewController.reccommedSongs[index.row].getID() != -1 else {
                return
            }
            CustomTabbarViewController.currentSong = CustomTabbarViewController.reccommedSongs[index.row]
            
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
                    print("update recently")
                    
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
                    print("update reccoomed")
                    // Đánh dấu cuộc gọi API đã hoàn thành
                    group.leave()
                } else {
                    // Xử lý lỗi từ cuộc gọi API
                    
                    // Đánh dấu cuộc gọi API đã hoàn thành
                    group.leave()
                }
            }
            
            
            //khởi tạo url bài hát từ filePath
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
                        CustomTabbarViewController.player!.prepareToPlay()
                        CustomTabbarViewController.player!.play()
                        CustomTabbarViewController.isPlaying = true
                        CustomTabbarViewController.isPause = false
                        //cập nhật lại giao diện khi call xong api
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let controller = storyboard.instantiateViewController(withIdentifier: "PlayingController")
                            //giao diện phát nhạc được hiện lên khi bài hát được phát
                            self.present(controller, animated: true, completion: nil)
                            print("uopdate alll")
                            self.RecentlySong.reloadData()
                            self.RecommendSong.reloadData()
                            
                        }
                    } catch {
                        print("Playing error")
                    }
                }
            }
            task.resume()
        }
    }
    //MARK: hàm phát bài hát
    @objc func playingRecentlySong(sender:UIButton) {
      
        if ((CustomTabbarViewController.recentlySongs.count) > 0) {
            let index = IndexPath(row: sender.tag, section: 0)
            guard CustomTabbarViewController.recentlySongs[index.row].getID() != -1 else {
                return
            }
            CustomTabbarViewController.currentSong = CustomTabbarViewController.recentlySongs[index.row]
            
            if (!CustomTabbarViewController.recentlyIds.contains(String(CustomTabbarViewController.currentSong.getID()))) {
                CustomTabbarViewController.recentlyIds.append(String(CustomTabbarViewController.currentSong.getID()))
            }
            else {
                guard let index =  CustomTabbarViewController.recentlyIds.firstIndex(of: (String(CustomTabbarViewController.currentSong.getID()))) else {
                    return
                }
                CustomTabbarViewController.recentlyIds.remove(at: index)
                CustomTabbarViewController.recentlyIds.insert(String(CustomTabbarViewController.currentSong.getID()), at: 0)
            }
            
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
                            self.RecentlySong.reloadData()
                            self.RecommendSong.reloadData()
                        }
                    } catch {
                        print("Playing error")
                    }
                }
            }
            
            task.resume()
        }
    }
    
    public func customSearchTextField() {
        let placeholdertext = NSAttributedString(string: "Search Music", attributes: [NSAttributedString.Key.foregroundColor:UIColor.darkGray])
        
        edtSearchSong.attributedPlaceholder = placeholdertext
        edtSearchSong.layer.cornerRadius = 20
        edtSearchSong.layer.borderColor = UIColor.white.cgColor
        edtSearchSong.layer.borderWidth = 1
        
        let searchIcon = UIImageView()
        searchIcon.image = UIImage(named: "searchIcon")
        
        let contentView = UIView()
        contentView.addSubview(searchIcon)
        contentView.frame = CGRect(x: 0, y: 0, width: 35, height: UIImage(named: "searchIcon")!.size.height)
        searchIcon.frame  = CGRect(x: 10, y: 0, width: UIImage(named: "searchIcon")!.size.width, height: UIImage(named: "searchIcon")!.size.height)
        edtSearchSong.leftView =  contentView
        edtSearchSong.leftViewMode = .always
        edtSearchSong.clearButtonMode = .whileEditing
    }
    
    //MARK: hàm tìm kiếm bài hát
    func searchSong(keyWord q: String, completion: @escaping (Bool) -> Void)  {
        CustomTabbarViewController.resultSongs = []
        
        //xử lý dữ liệu tiếng việt dể tránh lỗi
        let keyWord = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let url = URL(string: Constant.API_URL+"/api/search/" + keyWord!) else {
            // Handle error when URL is invalid
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        URLSession.shared.dataTask(with: req, completionHandler: {
            (data, res, err) in
            guard let data = data else {
                // Handle error when data is nil
                return
            }
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else {
                    return
                }
                let  rows = json["data"] as! [AnyObject]
                for song in rows {
                    if let id = song["id"] as? Int,
                       let name = song["name"] as? String,
                       let filePath = song["file_path"] as? String,
                       let thumbnail = song["thumbnail"] as? String,
                       let singer = song["singer"] as? String,
                       let listens = song["listens"] as? Int {
                        let currentSong = Song(id: id, name: name, filePath: filePath, thumbnail: thumbnail, singer: singer, listens: listens)
                        CustomTabbarViewController.resultSongs.append(currentSong)
                
                    } else {
                        // Handle error when accessing song properties fails
                    }
                   
                }
                completion(true)
            }   catch {
                print("data err")
            }
        }).resume()
    }
    
}

