//
//  CustomTabbarViewController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 12/05/2023.
//

import UIKit
import AVFoundation

class CustomTabbarViewController: UIViewController {
    //MARK: properties
    @IBOutlet weak var bottomTabView: UIView?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet var selectedStateView: [UIView]!
    
    public static var isPlaying = false
    public static var isPause = false
    public static var player: AVAudioPlayer?
    public static var currentTabIndex:Int = 0
    public static var currentSong:Song = Song()
    
    public static var reccommedSongs = [Song]()
    public static var recentlySongs = [Song]()
    public static var favouriteSongs = [Song]()
    public static var resultSongs:[Song] = [Song]()
    
    public static var favoriteIds:[String] = MyLocalStorage.favoriteIds
    
    public static var recentlyIds:[String] = MyLocalStorage.recentlyIds
    
    public static var timer:Timer!
    
    var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        customTabBar()
        
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
                print("lấydanh sách phát gần đây thất bại")
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
                print("lấydanh sách yêu thích thất bại")
                // Đánh dấu cuộc gọi API đã hoàn thành
                group.leave()
            }
        }
    
        // Đợi tất cả các hoạt động trong group hoàn thành trước khi render giao diện
        group.notify(queue: DispatchQueue.main) {
            // Render giao diện sau khi hoàn thành cuộc gọi API
            self.hadleSelected(current: CustomTabbarViewController.currentTabIndex)
            self.getStateView(dentity: "HomeController")
            
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category.")
        }

    }
    @IBAction func tabTapped(_ sender: UIButton) {
        let tag = sender.tag
        //đánh dấu view nào đang được chọn
        hadleSelected(current: tag)
        
        //hiển thị view tương ứng với từng tag
        if tag == 0 {
            getStateView(dentity:"HomeController")
        } else  if tag == 1 {
            getStateView(dentity:"PlayingController")
        } else if tag == 2 {
            getStateView(dentity:"FavoriteController")
        }
    }
    
    //hàm dánh dấu tabbar được chọn
    public func hadleSelected(current state :Int) {
        selectedStateView.forEach{selectedView in
            selectedView.isHidden = (selectedView.tag != state)
        }
    }
    
    
    //hàm định dạng lại thanh tabbar
    private func customTabBar() {
        bottomTabView?.roundCorners([.topRight, .topLeft], radius: 40)
        bottomTabView?.layer.shadowColor = UIColor.lightGray.cgColor
        bottomTabView?.layer.shadowOffset = CGSize.zero
        bottomTabView?.layer.shadowOpacity = 0.2
        bottomTabView?.layer.shadowRadius = 10
        bottomTabView?.layer.masksToBounds = false
    }
    
    //hàm lấy view theo identifierID
    private func getStateView(dentity identity: String) {
        
        //remove các view cũ trong container view
        for child in children {
               child.willMove(toParent: nil)
               child.view.removeFromSuperview()
               child.removeFromParent()
           }
        
        
        let controller  = main.instantiateViewController(identifier: identity)
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        controller.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive  = true
        controller.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive  = true
        controller.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive  = true
        controller.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive  = true
    }
    
    //MARK: các hàm gọi API
    public static func callAPIRecommedSong(completion: @escaping (Bool) -> Void)  {
        CustomTabbarViewController.reccommedSongs = []
        guard   let url = URL(string: Constant.API_URL+"/api/reccommed") else {
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
            
            guard let rows = json["data"] as? [AnyObject] else {
                // Handle error when extracting "data" field fails
                return
            }
            
            for song in rows {
                if let id = song["id"] as? Int,
                   let name = song["name"] as? String,
                   let filePath = song["file_path"] as? String,
                   let thumbnail = song["thumbnail"] as? String,
                   let singer = song["singer"] as? String,
                   let listens = song["listens"] as? Int {
                    let currentSong = Song(id: id, name: name, filePath: filePath, thumbnail: thumbnail, singer: singer, listens: listens)
                    CustomTabbarViewController.reccommedSongs.append(currentSong)
            
                } else {
                    // Handle error when accessing song properties fails
                }
               
            }
            completion(true)
            
        }).resume()
    }
    public static func callAPIFavouriteSong(completion: @escaping (Bool) -> Void)  {
        CustomTabbarViewController.favouriteSongs = []
        guard  let url = URL(string: Constant.API_URL+"/api/favorite?ids=[\(CustomTabbarViewController.favoriteIds.joined(separator: ","))]") else {
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
            
            guard let rows = json["data"] as? [AnyObject] else {
                // Handle error when extracting "data" field fails
                return
            }
            
            for song in rows {
                if let id = song["id"] as? Int,
                   let name = song["name"] as? String,
                   let filePath = song["file_path"] as? String,
                   let thumbnail = song["thumbnail"] as? String,
                   let singer = song["singer"] as? String,
                   let listens = song["listens"] as? Int {
                    let currentSong = Song(id: id, name: name, filePath: filePath, thumbnail: thumbnail, singer: singer, listens: listens)
                    CustomTabbarViewController.favouriteSongs.append(currentSong)
            
                } else {
                    // Handle error when accessing song properties fails
                }
               
            }
            completion(true)
            
        }).resume()
    }
    public static func callAPIRecentlySong(completion: @escaping (Bool) -> Void)  {
        CustomTabbarViewController.recentlySongs = []
        guard  let url = URL(string: Constant.API_URL+"/api/recently?ids=[\(CustomTabbarViewController.recentlyIds.joined(separator: ","))]") else {
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
            
            guard let rows = json["data"] as? [AnyObject] else {
                // Handle error when extracting "data" field fails
                return
            }
            
            for song in rows {
                if let id = song["id"] as? Int,
                   let name = song["name"] as? String,
                   let filePath = song["file_path"] as? String,
                   let thumbnail = song["thumbnail"] as? String,
                   let singer = song["singer"] as? String,
                   let listens = song["listens"] as? Int {
                    let currentSong = Song(id: id, name: name, filePath: filePath, thumbnail: thumbnail, singer: singer, listens: listens)
                    CustomTabbarViewController.recentlySongs.append(currentSong)
            
                } else {
                    // Handle error when accessing song properties fails
                }
               
            }
            completion(true)
            
        }).resume()
    }
    
    public static func updateListens(id: Int,completion: @escaping (Bool) -> Void) {
        if let url = URL(string: Constant.API_URL+"/api/songs/" + String(id)) {
            let session = URLSession.shared

            let task = session.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else if let data = data {
                    // Xử lý dữ liệu nhận được ở đây
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response: \(responseString ?? "")")
                }
            }
            print("update listens")
            task.resume()
        }
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait  // Thay .portrait bằng giá trị giao diện màn hình mong muốn
    }
    
}

//MARK: custom connerRadius
extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        if #available(*) {
            var cornersMask = CACornerMask()
            if(corners.contains(.topLeft)) {
                cornersMask.insert(.layerMinXMinYCorner)
            }
            if(corners.contains(.topRight)) {
                cornersMask.insert(.layerMaxXMinYCorner)
            }
            if(corners.contains(.bottomLeft)) {
                cornersMask.insert(.layerMinXMaxYCorner)
            }
            if(corners.contains(.bottomRight)) {
                cornersMask.insert(.layerMaxXMaxYCorner)
            }
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = cornersMask
        }
        else {
            let  path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
