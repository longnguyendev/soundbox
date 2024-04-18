//
//  MyLocalStorage.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 30/03/2024.
//

import Foundation
 
public class MyLocalStorage {
    private static var favoriteIdsKey: String = "favoriteIds"
    
    private static var recentlyIdsKey: String = "recentlyIds"
    
    public static var favoriteIds: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: favoriteIdsKey)
            UserDefaults.standard.synchronize() // Đảm bảo rằng dữ liệu được lưu ngay lập tức
        }
        get {
            return UserDefaults.standard.array(forKey: favoriteIdsKey) as? [String] ?? []
        }
    }
    
    public static var recentlyIds: [String] {
        set {
            UserDefaults.standard.set(newValue, forKey: recentlyIdsKey)
            UserDefaults.standard.synchronize() // Đảm bảo rằng dữ liệu được lưu ngay lập tức
        }
        get {
            return UserDefaults.standard.array(forKey: recentlyIdsKey) as? [String] ?? []
        }
    }
}
