//
//  ContentView.swift
//  PomodoroTechnique
//
//  Created by user26 on 2025/7/29.
//
import SwiftUI

struct ContentView: View {
    @State private var isRunning = false
    
    var body: some View {
        VStack {
            Text("貓咪在呼嚕... > ")
                .font(.system(size: 24, weight: .bold, design: .default))
            Image(systemName: "cat.fill")
                .font(.system(size: 88))
                .foregroundColor(.black)
                .padding()
                
            Text("00：00")
                .font(.system(size: 48, weight: .bold, design: .default))
                .foregroundColor(.gray)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(24)
            Text("休息中．．．")
                .font(.system(size: 22, design: .default))
                .padding()
            
            Button(action: {
                isRunning.toggle() // 切換狀態
                print(isRunning ? "開始" :"暫停")
            }) {
                Text(isRunning ? "開始" :"暫停")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 22) // 長寬
                    .padding()
                    .background(isRunning ? .black : .gray)
                    .cornerRadius(36)
            }
        }
    }
        //.padding()
}
#Preview {
    ContentView()
}
