//
//  ViewController.swift
//  SharePlaySample
//
//  Created by Yuta Tokoro on 2021/06/22.
//

import AVKit
import GroupActivities
import UIKit

class ViewController: AVPlayerViewController {
    private var groupSession: GroupSession<MovieWatchingActivity>?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
        prepareSharePlay()
        listenForGroupSession()
    }

    private func setupPlayer() {
        guard player == nil, let movieURL = MovieWatchingActivity.movieURL else {
            return
        }

        let player = AVPlayer(url: movieURL)
        self.player = player
        player.play()
    }
    
    private func prepareSharePlay() {
        let activity = MovieWatchingActivity()
        
        Task {
            switch await activity.prepareForActivation() {
            case .activationDisabled:
                break
            case .activationPreferred:
                _ = try await activity.activate()
            case .cancelled:
                break
            default: ()
            }
        }
    }

    private func listenForGroupSession() {
        Task {
            for await session in MovieWatchingActivity.sessions() {
                groupSession = session
                player?.playbackCoordinator.coordinateWithSession(session)
                session.join()
            }
        }
    }
}

struct MovieWatchingActivity: GroupActivity {
    static let movieURL: URL? = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2019/408bmshwds7eoqow1ud/408/hls_vod_mvp.m3u8")
    static let fallbackURL: URL? = URL(string: "https://spinners.work/")

    static let activityIdentifier = "work.spinners.SharePlaySample.GroupWatching"
    
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.fallbackURL = Self.fallbackURL
        metadata.previewImage = UIImage(named: "wwdc19")?.cgImage
        metadata.title = "Sample"
        metadata.subtitle = "WWDC19 Session Video"
        return metadata
    }
}
