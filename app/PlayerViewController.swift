//
//  PlayerViewController.swift
//
//  Created by ToKoRo on 2021-09-02.
//

import AVKit
import UIKit

final class PlayerViewController: AVPlayerViewController {
    private static let movieURL: URL? = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2019/408bmshwds7eoqow1ud/408/hls_vod_mvp.m3u8")

    override func viewDidLoad() {
        super.viewDidLoad()

        setupPlayer()
    }

    private func setupPlayer() {
        guard player == nil, let movieURL = Self.movieURL else {
            return
        }

        let player = AVPlayer(url: movieURL)
        self.player = player
        player.play()
    }
}
