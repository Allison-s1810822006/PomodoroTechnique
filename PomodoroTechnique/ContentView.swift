import SwiftUI

// 搗蛋模式枚舉
enum MischievousMode: String, CaseIterable {
    case sleeping = "sleeping"
    case coffee = "coffee"
    case vase = "vase"
    case documents = "documents"
    case furniture = "furniture"
    case clothes = "clothes"
    case screen = "screen"
    
    var displayName: String {
        switch self {
        case .sleeping: return "貓咪正在呼嚕..."
        case .coffee: return "弄倒咖啡杯"
        case .vase: return "打破花瓶"
        case .documents: return "弄亂文件"
        case .furniture: return "抓壞家具"
        case .clothes: return "咬壞衣服"
        case .screen: return "咬壞螢幕"
        }
    }
    
    var iconName: String {
        switch self {
        case .sleeping: return "cat.fill"
        case .coffee: return "cup.and.saucer.fill"
        case .vase: return "party.popper.fill"
        case .documents: return "doc.fill"
        case .furniture: return "sofa.fill"
        case .clothes: return "tshirt.fill"
        case .screen: return "display"
        }
    }
}

struct ContentView: View {
    @State private var isRunning = false
    @State private var isShowingTaskSheet = false
    @State private var isShowingModeSheet = false
    @State private var selectedHour = 0
    @State private var selectedMinute = 25
    @State private var selectedSecond = 0
    @State private var timeRemaining = 0000 // 預設25分鐘 (25*60=1500秒)
    @State private var timer: Timer?
    @State private var currentTask = "" // 當前任務
    @State private var currentMode: MischievousMode = .sleeping // 當前搣蛋模式
    
    // 計算顯示時間的格式化字串
    var timeDisplay: String {
        let hours = timeRemaining / 3600
        let minutes = (timeRemaining % 3600) / 60
        let seconds = timeRemaining % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    // 計算總設定時間（秒）
    var totalTime: Int {
        selectedHour * 3600 + selectedMinute * 60 + selectedSecond
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 狀態按鈕 - 可以選擇搗蛋模式
            Button {
                isShowingModeSheet = true
            } label: {
                Text("狀態：\(currentMode.displayName) > ")
                    .font(.system(size: 24, weight: .bold, design: .default))
            }
            
            // 貓咪圖片 - 根據選擇的模式顯示
            VStack {
                Image(systemName: currentMode.iconName)
                    .font(.system(size: 88))
                    .foregroundColor(.black)
                    .padding()
            }
            
            // 時間顯示
            Text(timeDisplay)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(isRunning ? .primary : .gray)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(24)
            
            // 新增專注任務按鈕 - 只在非運行狀態顯示
            if !isRunning {
                Button {
                    isShowingTaskSheet = true
                } label: {
                    Text("新增專注任務")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
            }
            
            // 當前任務顯示 - 只在有任務時顯示
            if !currentTask.isEmpty {
                VStack {
                    Text("當前任務")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .padding()
                    Text(currentTask)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            
            // 狀態文字 - 只在有任務且有時間時顯示
            if !currentTask.isEmpty && timeRemaining > 0 {
                Text(isRunning ? "專注中..." : "準備開始")
                    .font(.system(size: 22, design: .default))
                    .foregroundColor(.secondary)
                    .padding()
            } else if timeRemaining == 0 && !currentTask.isEmpty {
                Text("時間到！")
                    .font(.system(size: 22, design: .default))
                    .foregroundColor(.red)
                    .padding()
            }
            
            // 開始/暫停按鈕 - 永遠顯示
            Button(action: {
                if isRunning {
                    pauseTimer()
                } else {
                    startTimer()
                }
            }) {
                Text(isRunning ? "暫停" : "開始")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 100, height: 22)
                    .padding()
                    .background(isRunning ? .orange : .green)
                    .cornerRadius(36)
            }
            .disabled((timeRemaining == 0 && !isRunning) || currentTask.isEmpty)
            
            // 重置按鈕 - 只在有任務時顯示
            if !currentTask.isEmpty {
                Button("重置") {
                    resetTimer()
                }
                .foregroundColor(.red)
                .padding(.top, 10)
            }
        }
        .padding()
        .sheet(isPresented: $isShowingTaskSheet) {
            TaskCreationSheet(
                selectedHour: $selectedHour,
                selectedMinute: $selectedMinute,
                selectedSecond: $selectedSecond,
                currentTask: $currentTask,
                onComplete: {
                    timeRemaining = totalTime
                    isShowingTaskSheet = false
                }
            )
        }
        .sheet(isPresented: $isShowingModeSheet) {
            MischievousModeSheet(
                currentMode: $currentMode,
                onComplete: {
                    isShowingModeSheet = false
                }
            )
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    // 開始計時器
    func startTimer() {
        guard timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // 時間到了
                pauseTimer()
                // 這裡可以加入通知或音效
            }
        }
    }
    
    // 暫停計時器
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    // 重置計時器
    func resetTimer() {
        pauseTimer()
        timeRemaining = totalTime
    }
}

// 搗蛋模式選擇的 Sheet 頁面
struct MischievousModeSheet: View {
    @Binding var currentMode: MischievousMode
    let onComplete: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("選擇搗蛋模式💀")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("選擇貓咪的搗蛋行為")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.bottom)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(MischievousMode.allCases.dropFirst(), id: \.self) { mode in
                        Button {
                            currentMode = mode
                        } label: {
                            VStack(spacing: 12) {
                                Image(systemName: mode.iconName)
                                    .font(.system(size: 40))
                                    .foregroundColor(currentMode == mode ? .white : .primary)
                                
                                Text(mode.displayName)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(currentMode == mode ? .white : .primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: 120, height: 100)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(currentMode == mode ? Color.blue : Color.gray.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(currentMode == mode ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onComplete()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        onComplete()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// 任務創建的 Sheet 頁面
struct TaskCreationSheet: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedSecond: Int
    @Binding var currentTask: String
    let onComplete: () -> Void
    
    @State private var taskInput = ""
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // 任務輸入區域
                VStack(alignment: .leading, spacing: 8) {
                    Text("專注項目")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("輸入要專注的項目...", text: $taskInput)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTextFieldFocused)
                        .onAppear {
                            taskInput = currentTask.isEmpty ? "" : currentTask
                        }
                }
                .padding(.horizontal)
                
                // 時間設定區域
                VStack(spacing: 10) {
                    Text("設定專注時間")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 0) {
                        // 小時選擇器
                        VStack {
                            Text("小時")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("小時", selection: $selectedHour) {
                                ForEach(0..<24) { hour in
                                    Text("\(hour)")
                                        .tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }
                        
                        // 分鐘選擇器
                        VStack {
                            Text("分鐘")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("分鐘", selection: $selectedMinute) {
                                ForEach(0..<60) { minute in
                                    Text("\(minute)")
                                        .tag(minute)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }
                        
                        // 秒數選擇器
                        VStack {
                            Text("秒數")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Picker("秒數", selection: $selectedSecond) {
                                ForEach(0..<60) { second in
                                    Text("\(second)")
                                        .tag(second)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 快速設定按鈕
                VStack(spacing: 10) {
                    Text("快速設定時間")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 15) {
                        Button("25分鐘") {
                            selectedHour = 0
                            selectedMinute = 25
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                        
                        Button("15分鐘") {
                            selectedHour = 0
                            selectedMinute = 15
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                        
                        Button("5分鐘") {
                            selectedHour = 0
                            selectedMinute = 5
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack(spacing: 15) {
                        Button("45分鐘") {
                            selectedHour = 0
                            selectedMinute = 45
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                        
                        Button("1小時") {
                            selectedHour = 1
                            selectedMinute = 0
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                        
                        Button("2小時") {
                            selectedHour = 2
                            selectedMinute = 0
                            selectedSecond = 0
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("新增專注任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onComplete()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        // 更新任務名稱
                        if !taskInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            currentTask = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        } else {
                            currentTask = "專注任務"
                        }
                        onComplete()
                    }
                    .fontWeight(.bold)
                }
                
                // 鍵盤完成按鈕
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("完成") {
                        isTextFieldFocused = false
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ContentView()
}
