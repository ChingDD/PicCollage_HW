//
//  PlaybackManager.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/03.
//

import Foundation

protocol PlaybackManagerDelegate: AnyObject {
    func playbackManagerDidUpdateTime(by interval: TimeInterval)
}

class PlaybackManager {
    weak var delegate: PlaybackManagerDelegate?
    private var timer: Timer?
    private let updateInterval: TimeInterval

    var isPlaying: Bool {
        return timer != nil
    }

    init(updateInterval: TimeInterval = 0.01) {
        self.updateInterval = updateInterval
    }

    func play() {
        guard timer == nil else { return }

        let newTimer = Timer(timeInterval: updateInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.delegate?.playbackManagerDidUpdateTime(by: self.updateInterval)
        }

        // Add timer to RunLoop with common mode to allow it to run during scrolling
        RunLoop.current.add(newTimer, forMode: .common)
        timer = newTimer
        timer?.fire()
    }

    func pause() {
        timer?.invalidate()
        timer = nil
    }

    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }

    deinit {
        pause()
    }

    // MARK: - Future Extensions
    // func loadAudio(url: URL)
    // func seek(to time: TimeInterval)
    // func setPlaybackRate(_ rate: Float)
}
