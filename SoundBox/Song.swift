//
//  Song.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 07/05/2023.
//

import UIKit
public class Song {
    private var id:Int
    private var name:String
    private var filePath:String
    private var thumbnail:String
    private var singer:String
    private var listens:Int
    
    init(id: Int, name: String, filePath: String, thumbnail: String, singer: String, listens: Int) {
        self.id = id
        self.name = name
        self.filePath = filePath
        self.thumbnail = thumbnail
        self.singer = singer
        self.listens = listens
    }
    
    init() {
        self.id = -1
        self.name = "name"
        self.filePath = "filePath"
        self.thumbnail = "thumbnail"
        self.singer = "singer"
        self.listens = -1
    }
    
    public func getID()->Int{
        return id
    }
    public func getName()->String{
        return name
    }
    public func getFilePath()->String{
        return filePath
    }
    public func getThumbnail()->String{
        return thumbnail
    }
    public func getSinger()->String{
        return singer
    }
    public func getListens()->Int{
        return listens
    }
   
}
