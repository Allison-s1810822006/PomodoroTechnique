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
            .scaleEffect(isRunning && animationState ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animationState)
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

// 專注紀錄資料結構
struct FocusRecord: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    let date: String // yyyy/MM/dd
    let taskName: String
    let duration: Int // 秒
    let isCompleted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, date, taskName, duration, isCompleted
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

// 任務創建的 Sheet 頁面
struct TaskCreationSheet: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedSecond: Int
    @Binding var currentTask: String
    let onComplete: () -> Void
    // 新增：完成任務時回傳 closure
    var onTaskCompleted: ((String) -> Void)? = nil
    // 新增：接收 focusRecords 參數
    let focusRecords: [FocusRecord]
    
    @State private var taskInput = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isTaskCompleted = false
    
    // 日期格式化
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }
    
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
                        let trimmed = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            currentTask = trimmed
                        } else {
                            currentTask = "專注任務"
                        }
                        // 不再於此新增紀錄，僅設定任務與時間
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

// 專注紀錄檢視
struct FocusRecordView: View {
    let focusRecords: [FocusRecord]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if focusRecords.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("尚無專注紀錄")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("完成專注任務後，紀錄會顯示在這裡")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(focusRecords) { record in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(record.taskName)
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(record.isCompleted ? .white : .black)
                                    Text("時長：\(formatDuration(record.duration))")
                                        .font(.subheadline)
                                        .foregroundColor(record.isCompleted ? .white.opacity(0.85) : .black.opacity(0.85))
                                    Text("日期：\(record.date)")
                                        .font(.subheadline)
                                        .foregroundColor(record.isCompleted ? .white.opacity(0.85) : .black.opacity(0.85))
                                }
                                Spacer()
                                Image(systemName: record.isCompleted ? "checkmark.circle" : "xmark.circle")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(record.isCompleted ? .white : .black)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .background(record.isCompleted ? Color(hex: "#558859") : Color(hex: "#c3c3c3"))
                            .cornerRadius(20)
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
            }
            .background(Color.white) // 將底圖設為白色
            .navigationTitle("專注紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // 格式化時間顯示
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%d小時%d分鐘%d秒", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d分鐘%d秒", minutes, secs)
        } else {
            return String(format: "%d秒", secs)
        }
    }
}

// 新增 FocusStatsView
struct FocusStatsView: View {
    let focusRecords: [FocusRecord]
    @Environment(\.dismiss) private var dismiss
    
    // 分組統計資料
    var groupedStats: [(date: String, completed: Int, uncompleted: Int, totalDuration: Int)] {
        let grouped = Dictionary(grouping: focusRecords) { $0.date }
        return grouped.keys.sorted(by: >).map { date in
            let records = grouped[date] ?? []
            let completed = records.filter { $0.isCompleted }.count
            let uncompleted = records.filter { !$0.isCompleted }.count
            let totalDuration = records.reduce(0) { $0 + $1.duration }
            return (date, completed, uncompleted, totalDuration)
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 18) {
                    if groupedStats.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)
                            Text("尚無統計紀錄")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("完成專注任務後，統計會顯示在這裡")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(groupedStats, id: \.date) { stat in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(stat.date)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                HStack {
                                    Label("完成：\(stat.completed) 項", systemImage: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Label("未完成：\(stat.uncompleted) 項", systemImage: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                                Text("總專注時間：\(formatDuration(stat.totalDuration))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(18)
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 2)
                        }
                    }
                }
                .padding(.top, 24)
                .padding(.horizontal, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("統計紀錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // 格式化時間顯示
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        if hours > 0 {
            return String(format: "%d小時%d分鐘%d秒", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%d分鐘%d秒", minutes, secs)
        } else {
            return String(format: "%d秒", secs)
        }
    }
}

// 新增自訂 ButtonStyle
struct ButtonStyleWithHighlight: ButtonStyle {
    var normalBackground: Color
    var highlightedBackground: Color
    var normalForeground: Color
    var highlightedForeground: Color
    var cornerRadius: CGFloat = 8
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? highlightedForeground : normalForeground)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(configuration.isPressed ? highlightedBackground : normalBackground)
            )
    }
}

// 新增 Color 擴充，支援 hex 初始化
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
