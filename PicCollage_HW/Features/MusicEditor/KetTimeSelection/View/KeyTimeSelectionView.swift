//
//  KeyTimeSelectionView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct KeyTimeSelectionView: View {
    // MARK: Properties - Data from parent
    let keyTimePercentage: [CGFloat]
    let durationRatio: CGFloat
    let sectionTimeline: String
    let currentTimeline: String
    let sectionPercentage: String
    let currentPercentage: String

    // MARK: Binding - Two-way data binding
    @Binding var startTimeRatio: CGFloat    // start / totalDuration
    @Binding var allowUpdate: Bool
    
    // MARK: UI Properties
    let circleRadius: CGFloat = 25
    var barHeight: CGFloat {
        circleRadius * 2 * 0.8
    }

    // MARK: Body
    var body: some View {
        VStack {
            keyTimeTextView
            keyTimeBarView
            timelineTextView
        }
        .background(Color.myDarkGray)
    }
}

// MARK: Preview
#Preview {
    KeyTimeSelectionView(
        keyTimePercentage: [0.2, 0.5, 0.6, 0.9],
        durationRatio: 0.125,  // 10/80 = 0.125
        sectionTimeline: "Selected: 0:00 - 0:10",
        currentTimeline: "Current: 0:00",
        sectionPercentage: "Section: 0.0% - 12.5%",
        currentPercentage: "Current: 0.0%",
        startTimeRatio: .constant(0.0),
        allowUpdate: .constant(true)  // Use .constant() for @Binding in preview
    )
}

// MARK: Subviews
extension KeyTimeSelectionView {
    var timelineTextView: some View {
        VStack {
            // Timeline Text
            Text("Music Timeline")
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)

            Text(sectionTimeline)
                .bold()
                .foregroundStyle(Color.white)

            Text(currentTimeline)
                .bold()
                .foregroundStyle(Color.green)
        }
    }

    var keyTimeTextView: some View {
        VStack {
            // KeyTime Text
            Text("KeyTime Selection")
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)

            Text(sectionPercentage)
                .bold()
                .foregroundStyle(Color.white)

            Text(currentPercentage)
                .bold()
                .foregroundStyle(Color.green)
        }
    }

    var keyTimeBarView: some View {
        // Keytime Button
        GeometryReader { proxy in
            // 藍色 bar 的實際寬度，因為 .padding(.horizontal, 20)
            let barWidth = proxy.size.width - 40

            ZStack {
                Rectangle()
                    .fill(Color.black)
                    .cornerRadius(50)
                    .frame(height: 40)

                Rectangle()
                    .fill(Color.myDarkGray)
                    .cornerRadius(50)
                    .frame(height: 15)
                    .padding(.horizontal, 20)

                Rectangle()
                    .fill(Color.yellow)
                    .cornerRadius(50)
                    .frame(width: barWidth * durationRatio, height: 20)
                    .offset(x: -(barWidth / 2) + (barWidth * startTimeRatio) + (durationRatio * barWidth / 2), y: 0)

                // 動態生成 KeyTime 按鈕
                keyTimeButtons(barWidth: barWidth)
            }
        }
        .frame(height: barHeight)
    }

    func keyTimeButtons(barWidth: CGFloat) -> some View {
        /*
         計算邏輯：
           1. - barWidth / 2：因為 ZStack 預設將子視圖放在中心，所以需要先向左偏移一半寬度到起始點
           2. + barWidth * keyTimePercentage[i]：根據百分比計算位置
         */

        // Generate KeyTime Buttons
        ForEach(keyTimePercentage.indices, id: \.self) { index in
            Button {
                allowUpdate = true
                // Check border
                let proposedStart = keyTimePercentage[index]
                if proposedStart + durationRatio > 1.0 {
                    startTimeRatio = 1.0 - durationRatio
                } else {
                    startTimeRatio = proposedStart
                }
            } label: {
                Circle()
                    .fill(Color.pink)
                    .frame(width: circleRadius, height: circleRadius)
            }
            .buttonStyle(.plain)
            .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[index], y: 0)
        }
    }
}
