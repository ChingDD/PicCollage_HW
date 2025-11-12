//
//  KeyTimeSelectionView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct KeyTimeSelectionView: View {
    var keyTimePercentage: [CGFloat] = [0.2, 0.4, 0.6 ,0.8]
    let circleRadius: CGFloat = 25

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
                // 藍色 bar 的實際寬度
                let barWidth = proxy.size.width - 40 // 因為 .padding(.horizontal, 20)

                ZStack {
                    Rectangle()
                        .fill(Color.yellow)
                        .cornerRadius(50)
                        .frame(height: 40)

                    Rectangle()
                        .fill(Color.cyan)
                        .cornerRadius(50)
                        .frame(height: 20)
                        .padding(.horizontal, 20)

                    Button {
                        print("圓形按鈕被點擊了")
                    } label: {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: circleRadius, height: circleRadius)
                    }
                    .offset(x: 20 + barWidth * keyTimePercentage[0] - (circleRadius / 2), y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                    } label: {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: circleRadius, height: circleRadius)
                    }
                    .offset(x: circleRadius + barWidth * keyTimePercentage[1] - (circleRadius / 2), y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                    } label: {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: circleRadius, height: circleRadius)
                    }
                    .offset(x: circleRadius + barWidth * keyTimePercentage[2] - (circleRadius / 2), y: 0)

                    Button {
                        print("圓形按鈕被點擊了")
                    } label: {
                        Circle()
                            .fill(Color.pink)
                            .frame(width: circleRadius, height: circleRadius)
                    }
                    .offset(x: circleRadius + barWidth * keyTimePercentage[3] - (circleRadius / 2), y: 0)
                }
            }
            
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
