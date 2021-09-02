//
//  ViewController.swift
//  SharePlaySample
//
//  Created by Yuta Tokoro on 2021/06/22.
//

import AVKit
import GroupActivities
import UIKit

class ViewController: UIViewController {
    private var groupSession: GroupSession<MovieWatchingActivity>?
    private var messenger: GroupSessionMessenger?

    @IBOutlet private weak var recentMessagesLabel: UILabel?

    private lazy var playerViewController: PlayerViewController? = {
        for case let child as PlayerViewController in children {
            return child
        }
        return nil
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        prepareSharePlay()
        listenForGroupSession()
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
                handleGruopSession(session)
            }
        }
    }

    private func handleGruopSession(_ session: GroupSession<MovieWatchingActivity>) {
        groupSession = session

        playerViewController?.player?.playbackCoordinator.coordinateWithSession(session)

        let messenger = GroupSessionMessenger(session: session)
        self.messenger = messenger

        Task { [weak self] in
            for await (message, _) in messenger.messages(of: SampleMessage.self) {
                self?.handleNewMessage(message)
            }
        }

        session.join()
    }

    private func handleNewMessage(_ message: SampleMessage) {
        guard let label = recentMessagesLabel else {
            return
        }

        let before = label.text ?? ""
        label.text = before + message.text
    }

    @IBAction func sendMessageAction(button: UIButton) {
        let text = button.titleLabel?.text ?? "*"
        sendMessage(text)
    }

    private func sendMessage(_ text: String) {
        guard let messenger = messenger else {
            return
        }

        let message = SampleMessage(id: UUID(), text: text)

        Task {
            do {
                try await messenger.send(message)
            } catch {
                print(error)
            }
        }

        handleNewMessage(message)
    }
}

struct MovieWatchingActivity: GroupActivity {
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

struct SampleMessage: Codable {
    let id: UUID
    let text: String
}
