//
//  KeyTimeSelectionView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct KeyTimeSelectionView: View {
    // MARK: Property
    @State private var startTimeRatio: CGFloat = 0.0  // 時間區間的起始點（0.0 到 1.0）
    var keyTimePercentage: [CGFloat] = [0.2, 0.5, 0.6 ,0.9]
    var timeRatio: CGFloat = 0.2  // selected sec / total sec

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
        .background(Color.gray)
    }
}

struct testView: View {
    var body: some View {
        ZStack {
            Button {
                print("圓形按鈕被點擊了")
            } label: {
                Circle()
                    .fill(.red)
                    .frame(width: 50, height: 50)
                    .offset(x: 100) // 想往右移動100，但...
            }

            Button {
                print("圓形按鈕被點擊了")
            } label: {
                Circle()
                    .fill(.blue)
                    .frame(width: 50, height: 50)
                    .offset(x: 200) // 想往右移動200
            }
        }
        .border(.black)
    }
}

#Preview {
    KeyTimeSelectionView()
}

extension KeyTimeSelectionView {
    var timelineTextView: some View {
        VStack {
            // Timeline Text
            Text("Music Timeline")
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)

            Text("Selected: 0:00 - 1:00")
                .bold()
                .foregroundStyle(Color.white)

            Text("Current: 0:00")
                .bold()
                .foregroundStyle(Color.green)
        }
    }

    var keyTimeTextView: some View {
        VStack {
            // Timeline Text
            // KeyTime Text
            Text("KeyTime Selection")
                .fontWeight(.heavy)
                .foregroundStyle(Color.white)

            Text("Selection: 0% - 100%")
                .bold()
                .foregroundStyle(Color.white)

            Text("Current: 0%")
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
                    .fill(Color.cyan)
                    .cornerRadius(50)
                    .frame(height: 20)
                    .padding(.horizontal, 20)

                Rectangle()
                    .fill(Color.yellow)
                    .cornerRadius(50)
                    .frame(width: barWidth * timeRatio, height: 20)
                    .offset(x: -(barWidth / 2) + (barWidth * startTimeRatio) + (timeRatio * barWidth / 2), y: 0)

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

        // 動態生成 KeyTime 按鈕
        ForEach(keyTimePercentage.indices, id: \.self) { index in
            Button {
                print("圓形按鈕 \(index) 被點擊了")
                // 檢查是否超出右邊界
                let proposedStart = keyTimePercentage[index]
                if proposedStart + timeRatio > 1.0 {
                    // 超出邊界，讓黃色 Rectangle 的右邊緣貼齊藍色 bar 的右邊緣
                    startTimeRatio = 1.0 - timeRatio
                } else {
                    startTimeRatio = proposedStart
                }
            } label: {
                Circle()
                    .fill(Color.pink)
                    .frame(width: circleRadius, height: circleRadius)
            }
            .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[index], y: 0)
        }
    }
}
