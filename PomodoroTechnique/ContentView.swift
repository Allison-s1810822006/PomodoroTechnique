//
//  ContentView.swift
//  PomodoroTechnique
//
//  Created by user26 on 2025/7/29.
//
import SwiftUI

struct ContentView: View {
    
    @State private var isRunning = false
    @State private var isShowing = false
    //    @State private var selectedMinute = 0
    //    @State private var selectedSecond = 0
    //    @State private var timeRemaining = 0
    //    @State private var timer: Timer?
    //    @State private var angle: Double = 0.0
    //    @State private var text: String = ""
    
    //    var minutes: Double {
    //        25 * angle
    //    }
    
    var body: some View {
        VStack {
                Button {
                    isShowing = true
                } label: {
                    Text("貓咪正在呼嚕... > ")
                        .font(.system(size: 24, weight: .bold, design: .default))
                }
            }
            .sheet(isPresented: $isShowing) {
                Text("選擇搗蛋模式💀")
                    .presentationDetents([.medium, .fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
        //放貓咪圖片
        VStack {
            Image(systemName: "cat.fill")
                .font(.system(size: 88))
                .foregroundColor(.black)
                .padding()
        }
            
            
            //            Text("\(minutes) minutes")
            //            Slider(value: $angle, in: 0...1)
            //                .onChange(of: angle) { oldValue, newValue in
            //                    text = String(newValue)
            //                }
            //
            //            TextField("Placeholder", text: $text)
            //                .onChange(of: text) { oldValue, newValue in
            //                    angle = Double(newValue) ?? 0
            //                }
            //            VStack {
            //                Button {
            //                    isShowing = true
            //                } label: {
            //                    Text("設定時間")
            //                }
            //            }
            //            //sheet較常使用
            //            .sheet(isPresented: $isShowing) {
            //                Text("Detail")
            //                    .presentationDetents([.medium, .fraction(0.33)])
            //                    .presentationDragIndicator(.visible)
            //
            //            }
            //
            //
            //            HStack {
            //                    Picker("分鐘", selection: $minutes) {
            //                        ForEach(0..<60) { Text("\($0) 分") }
            //                    }
            //                    .pickerStyle(.wheel)
            //                    .frame(width: 100)
            //
            //                    Picker("秒數", selection: $seconds) {
            //                        ForEach(0..<60) { Text("\($0) 秒") }
            //                    }
            //                    .pickerStyle(.wheel)
            //                    .frame(width: 100)
            //                }
            //            }
            
            //            Text("00：00")
            //                .font(.system(size: 48, weight: .bold, design: .default))
            //                .foregroundColor(.gray)
            //                .padding()
            //                .background(Color.white.opacity(0.2))
            //                .cornerRadius(24)
            
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
    #Preview {
        ContentView()
    }
