//
//  KeyTimeSelectionView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct KeyTimeSelectionView: View {
    // MARK: Property
    var keyTimePercentage: [CGFloat] = [0.2, 0.5, 0.6 ,0.9]
    let circleRadius: CGFloat = 25
    var timeRatio: CGFloat = 0.2  // selected sec / total sec
    @State private var startTimeRatio: CGFloat = 0.0  // 時間區間的起始點（0.0 到 1.0）
    var barHeight: CGFloat {
        circleRadius * 2 * 0.8
    }

    // MARK: Body
    var body: some View {
        VStack {
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
                    
                    /*
                     計算邏輯：
                       - -barWidth / 2：因為 ZStack 預設將子視圖放在中心，所以需要先向左偏移一半寬度到起始點
                       - + 20：加上左邊的 padding
                       - + barWidth * keyTimePercentage[i]：根據百分比計算位置
                     */
                    Button {
                        print("圓形按鈕被點擊了")
                        // 檢查是否超出右邊界
                        let proposedStart = keyTimePercentage[0]
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
                    .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[0], y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                        // 檢查是否超出右邊界
                        let proposedStart = keyTimePercentage[1]
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
                    .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[1], y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                        // 檢查是否超出右邊界
                        let proposedStart = keyTimePercentage[2]
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
                    .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[2], y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                        // 檢查是否超出右邊界
                        let proposedStart = keyTimePercentage[3]
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
                    .offset(x: -barWidth / 2 + barWidth * keyTimePercentage[3], y: 0)
                }
            }
            .frame(height: barHeight)

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
