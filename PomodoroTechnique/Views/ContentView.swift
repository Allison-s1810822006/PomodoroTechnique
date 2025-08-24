import SwiftUI

// 動畫類型（僅保留簡單動畫用於貓咪圖片）
enum AnimationType {
    case breathing, shake, bounce, wiggle, shock, bite, rummage
}

// 貓咪動畫 Modifier（僅保留簡單動畫）
struct AnimatedCatModifier: ViewModifier {
    let isRunning: Bool
    @State private var animationState = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isRunning && animationState ? 1.10 : 0.95)
            .animation(
                isRunning ? .easeInOut(duration: 1.2).repeatForever(autoreverses: true) : .default,
                value: animationState
            )
            .onAppear {
                if isRunning {
                    animationState = true
                }
            }
            .onChange(of: isRunning) { running, _ in
                animationState = running
            }
    }
}
struct ContentView: View {
    @State private var isRunning = false
    @State private var isShowingTaskSheet = false
    @State private var isShowingRecordSheet = false
    @State private var isShowingStatsSheet = false
    @State private var selectedHour = 0
    @State private var selectedMinute = 25
    @State private var selectedSecond = 0
    @State private var timeRemaining = 0000
    @State private var timer: Timer?
    @State private var currentTask = ""
    // 新增：今日已完成任務清單
    @State private var completedTasksToday: [String] = []
    @State private var todayString: String = ContentView.getTodayString()
    @State private var focusRecords: [FocusRecord] = []
    @State private var showCancelAlert = false
    
    // 日期字串取得
    static func getTodayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }
    
    // 每次進入畫面時檢查日期，若不是今日則清空清單
    func checkAndResetIfNewDay() {
        let now = ContentView.getTodayString()
        if now != todayString {
            todayString = now
            completedTasksToday = []
        }
    }
    
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
        ZStack {
            // APP純白色背景
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 12) {
                // 新增：專注紀錄按鈕（移到最上方）
                HStack {
                    Spacer()
                    Button(action: { isShowingRecordSheet = true }) {
                        Text("專注紀錄")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                    }
                    .background(
                        Capsule()
                            .fill(Color(hex: "#558859")) // 深綠色
                    )
                    .buttonStyle(PlainButtonStyle())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "#558859"), lineWidth: 1)
                    )
                    .contentShape(Capsule())
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .buttonStyle(
                        ButtonStyleWithHighlight(
                            normalBackground: Color(hex: "#558859"),
                            highlightedBackground: Color(hex: "#558859").opacity(0.85),
                            normalForeground: .white,
                            highlightedForeground: .white,
                            cornerRadius: 8
                        )
                    )
                    
                    // 統計紀錄按鈕
                    Button(action: { isShowingStatsSheet = true }) {
                        Text("統計紀錄")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                    }
                    .background(
                        Capsule()
                            .fill(Color(hex: "#558859")) // 深綠色
                    )
                    .buttonStyle(PlainButtonStyle())
                    .overlay(
                        Capsule()
                            .stroke(Color(hex: "#558859"), lineWidth: 1)
                    )
                    .contentShape(Capsule())
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                    .buttonStyle(
                        ButtonStyleWithHighlight(
                            normalBackground: Color(hex: "#558859"),
                            highlightedBackground: Color(hex: "#558859").opacity(0.85),
                            normalForeground: .white,
                            highlightedForeground: .white,
                            cornerRadius: 8
                        )
                    )
                    Spacer()
                }
                // 新增提示文字
                Text("請專注項目任務，才能讓小貓睡飽不起床搗蛋！")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 2)
                
                // 貓咪圖片 - 改為固定圖片
                VStack {
                    Image("cat_sleeping")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 320, height: 300)
                        .padding(4)
                        .modifier(AnimatedCatModifier(
                            isRunning: isRunning
                        ))
                }
                
                // 時間顯示
                Text(timeDisplay)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(isRunning ? Color(hex: "#558859") : .gray)
                    .padding(12)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
                
                // 新增專注任務按鈕 - 只在非運行狀態顯示
                if !isRunning {
                    Button {
                        isShowingTaskSheet = true
                    } label: {
                        Text("新增專注任務")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "#558859"))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color(hex: "#558859"), lineWidth: 1)
                            )
                    }
                }
                
                // 當前任務顯示 - 只在有任務時顯示
                if !currentTask.isEmpty {
                    VStack {
                        Text("當前任務")
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .padding(.top)
                        Text(currentTask)
                            .font(.system(size: isRunning ? 24 : 18, weight: .bold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.bottom)
                    }
                    .background(
                        Group {
                            if isRunning {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(.regularMaterial)
                            } else {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.clear)
                            }
                        }
                    )
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
                
                // 開始/暫停與取消按鈕 - 永遠顯示
                HStack(spacing: 16) {
                    Button(action: {
                        if isRunning {
                            pauseTimer()
                        } else {
                            startTimer()
                        }
                    }) {
                        Text(isRunning ? "暫停" : "開始")
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(isRunning ? Color(hex: "#558859") : Color(hex: "#2a2a2a"))
                            )
                    }
                    .disabled((timeRemaining == 0 && !isRunning) || currentTask.isEmpty)
                    
                    if isRunning {
                        Button(action: {
                            showCancelAlert = true
                        }) {
                            Text("取消")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.red)
                                )
                        }
                    }
                }
                
                // 重置任務與清除項目按鈕 - 只在有任務時顯示
                if !currentTask.isEmpty {
                    HStack(spacing: 16) {
                        Button("重置任務") {
                            resetTimer()
                            startTimer() // 立即重新開始計時
                        }
                        .foregroundColor(.orange)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                        
                        Button("清除項目") {
                            pauseTimer()
                            currentTask = ""
                            timeRemaining = 0
                            selectedHour = 0
                            selectedMinute = 25
                            selectedSecond = 0
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
            // 新增：下方顯示今日完成任務清單
            VStack {
                Spacer()
                if !completedTasksToday.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Divider()
                        Text("今日已完成專注項目：")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        ForEach(completedTasksToday, id: \.self) { task in
                            HStack {
                                Text(task)
                                    .font(.subheadline)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
        .sheet(isPresented: $isShowingRecordSheet) {
            FocusRecordView(focusRecords: focusRecords)
        }
        .sheet(isPresented: $isShowingTaskSheet) {
            TaskCreationSheet(
                selectedHour: $selectedHour,
                selectedMinute: $selectedMinute,
                selectedSecond: $selectedSecond,
                currentTask: $currentTask,
                onComplete: {
                    timeRemaining = totalTime
                    isShowingTaskSheet = false
                },
                onTaskCompleted: { taskName in
                    // 避免重複加入
                    if !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !completedTasksToday.contains(taskName) {
                        completedTasksToday.append(taskName)
                    }
                },
                focusRecords: focusRecords // 修正這裡，傳遞 focusRecords 參數
            )
        }
        .sheet(isPresented: $isShowingStatsSheet) {
            FocusStatsView(focusRecords: focusRecords)
        }
        .onAppear {
            checkAndResetIfNewDay()
        }
        .onChange(of: todayString) { _, _ in
            checkAndResetIfNewDay()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .alert("確定要取消當前專注項目嗎？", isPresented: $showCancelAlert) {
            Button("確定", role: .destructive) {
                handleCancelTask()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("小貓睡不飽會起床搗蛋！")
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
                // 新增已完成紀錄
                if !currentTask.isEmpty {
                    focusRecords.append(FocusRecord(
                        date: todayString,
                        taskName: currentTask,
                        duration: totalTime,
                        isCompleted: true
                    ))
                }
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
    
    // 新增：取消任務的邏輯
    func handleCancelTask() {
        if !currentTask.isEmpty && timeRemaining > 0 {
            focusRecords.append(FocusRecord(
                date: todayString,
                taskName: currentTask,
                duration: totalTime - timeRemaining,
                isCompleted: false
            ))
        }
        pauseTimer()
        currentTask = ""
        timeRemaining = 0
        selectedHour = 0
        selectedMinute = 25
        selectedSecond = 0
    }
}

#Preview {
    ContentView()
}
