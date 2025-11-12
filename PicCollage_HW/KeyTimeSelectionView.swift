//
//  KeyTimeSelectionView.swift
//  PicCollage_HW
//
//  Created by 林仲景 on 2025/11/11.
//

import SwiftUI

struct KeyTimeSelectionView: View {
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
            ZStack {
                Rectangle()
                    .fill(Color.yellow)
                    .cornerRadius(50)
                    .frame(height: 70)
                
                Rectangle()
                    .fill(Color.cyan)
                    .cornerRadius(50)
                    .frame(height: 35)
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

#Preview {
    KeyTimeSelectionView()
}
