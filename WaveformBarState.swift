//
//  WaveformBarState.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/6.
//

import Foundation

struct WaveformBarState {
    let amplitude: CGFloat      // (0-1)
    var scale: CGFloat          // For animate
    var brightness: CGFloat     // (0-1)
    init(amplitude: CGFloat, scale: CGFloat = 1.0, brightness: CGFloat = 1.0) {
        self.amplitude = amplitude
        self.scale = scale
        self.brightness = brightness
    }
}
