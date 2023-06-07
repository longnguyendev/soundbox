//
//  SplashScreenController.swift
//  SoundBox
//
//  Created by Long Nguyễn Thành on 26/05/2023.
//

import UIKit
import AVFoundation
import MediaPlayer

class SplashScreenController: UIViewController {
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var logo: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        playLocalMusic()
        let logoGif = UIImage.gifImageWithName("Sound Box")
        logo.image = logoGif
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6) {
            self.performSegue(withIdentifier: "gohome", sender: nil)
        }
        // Do any additional setup after loading the view.
    }
    
   

    func playLocalMusic() {
        guard let filePath = Bundle.main.path(forResource: "intro", ofType: "mp3") else {
            // Handle error when file path is invalid
            return
        }
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            // Handle error when initializing AVAudioPlayer fails
            print("Error: \(error.localizedDescription)")
        }
        
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait  // Thay .portrait bằng giá trị giao diện màn hình mong muốn
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
