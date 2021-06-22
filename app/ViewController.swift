//
//  ViewController.swift
//  SharePlaySample
//
//  Created by Yuta Tokoro on 2021/06/22.
//

import AVKit
import Combine
import GroupActivities
import UIKit

class ViewController: AVPlayerViewController {
    static let movieURL: URL? = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2019/408bmshwds7eoqow1ud/408/hls_vod_mvp.m3u8")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
        prepareSharePlay()
    }

    private func setupPlayer() {
        guard player == nil, let movieURL = Self.movieURL else {
            return
        }

        let player = AVPlayer(url: movieURL)
        self.player = player
        player.play()
    }
    
    private func prepareSharePlay() {
        CoordinationManager.shared.prepareToPlay()
    }
}

struct MovieWatchingActivity: GroupActivity {
    static let activityIdentifier = "work.spinners.SharePlaySample.GroupWatching"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.fallbackURL = ViewController.movieURL
        metadata.previewImage = UIImage(named: "wwdc19")?.cgImage
        metadata.title = "Sample"
        metadata.subtitle = "WWDC19 Session Video"
        return metadata
    }
}

final class CoordinationManager {
    static let shared = CoordinationManager()
    
    private var subscriptions = Set<AnyCancellable>()
    
    func prepareToPlay() {
        let activity = MovieWatchingActivity()
        
        async {
            switch await activity.prepareForActivation() {
            case .activationDisabled:
                break
            case .activationPreferred:
                activity.activate()
            case .cancelled:
                break
            default: ()
            }
        }
    }
}
