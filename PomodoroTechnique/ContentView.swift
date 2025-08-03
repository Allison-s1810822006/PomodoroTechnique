import SwiftUI

// 搣蛋模式枚舉
enum MischievousMode: String, CaseIterable {
    case sleeping = "sleeping"
    case coffee = "coffee"
    case potted_plant = "potted_plant"
    case eat = "eat"
    case power_cord = "power_cord"
    case bit_clothes = "bit_clothes"
    case trash_can = "trash_can"
    
    var displayName: String {
        switch self {
        case .sleeping: return "休息中"
        case .coffee: return "弄倒咖啡杯"
        case .potted_plant: return "弄倒盆栽"
        case .eat: return "偷吃食物"
        case .power_cord: return "咬電線"
        case .bit_clothes: return "咬衣服"
        case .trash_can: return "翻垃圾"
        }
    }
    
    // 系統圖示 - 給選擇模式頁面用
    var iconName: String {
        switch self {
        case .sleeping: return "cat.body"
        case .coffee: return "cup.and.saucer.fill"
        case .potted_plant: return "leaf.fill"
        case .eat: return "fork.knife"
        case .power_cord: return "bolt.fill"
        case .bit_clothes: return "tshirt.fill"
        case .trash_can: return "trash.fill"
        }
    }
    
    // 自訂圖片名稱 - 給主頁面用
    var customImageName: String {
        switch self {
        case .sleeping: return "cat_sleeping"
        case .coffee: return "cat_coffee"
        case .potted_plant: return "cat_potted_plant"
        case .eat: return "cat_eat"
        case .power_cord: return "cat_bit_power_cord"
        case .bit_clothes: return "cat_bit_clothes"
        case .trash_can: return "cat_trash_can"
        }
    }
    
    // 動畫類型
    var animationType: AnimationType {
        switch self {
        case .sleeping: return .breathing
        case .coffee: return .shake
        case .potted_plant: return .bounce
        case .eat: return .wiggle
        case .power_cord: return .shock
        case .bit_clothes: return .bite
        case .trash_can: return .rummage
        }
    }
    
    // 背景 SF Symbols
    var backgroundSymbols: [String] {
        switch self {
        case .sleeping: return ["zzz", "moon.fill", "bed.double.fill", "pillow.fill"]
        case .coffee: return ["cup.and.saucer.fill", "drop.fill", "exclamationmark.triangle.fill", "flame.fill"]
        case .potted_plant: return ["leaf.fill", "tree.fill", "ladybug.fill", "sun.max.fill"]
        case .eat: return ["fork.knife", "fish.fill", "heart.eyes.fill", "mouth.fill"]
        case .power_cord: return ["bolt.fill", "exclamationmark.triangle.fill", "spark.fill", "eye.trianglebadge.exclamationmark.fill"]
        case .bit_clothes: return ["tshirt.fill", "scissors", "heart.fill", "pawprint.fill"]
        case .trash_can: return ["trash.fill", "bag.fill", "face.smiling.inverse", "questionmark.folder.fill"]
        }
    }
    
    // SF Symbols 的颜色主题
    var symbolColors: [Color] {
        switch self {
        case .sleeping: return [.blue, .purple, .indigo]
        case .coffee: return [.brown, .orange, .yellow]
        case .potted_plant: return [.green, .mint, .teal]
        case .eat: return [.yellow, .orange, .red]
        case .power_cord: return [.yellow, .red, .orange]
        case .bit_clothes: return [.pink, .purple, .blue]
        case .trash_can: return [.gray, .brown, .secondary]
        }
    }
}

// 動畫類型枚舉
enum AnimationType {
    case breathing, shake, bounce, wiggle, shock, bite, rummage
}

// 背景动画视图
struct AnimatedBackgroundView: View {
    let isRunning: Bool
    let mode: MischievousMode
    @State private var animationStates: [Bool] = []
    
    var body: some View {
        ZStack {
            // 纯白色背景
            Color.white
                .ignoresSafeArea()
            
            // 只在运行时显示动画符号
            if isRunning {
                ForEach(0..<12, id: \.self) { index in
                    AnimatedSymbol(
                        symbol: mode.backgroundSymbols[index % mode.backgroundSymbols.count],
                        symbolColors: mode.symbolColors,
                        index: index,
                        isAnimating: animationStates.count > index ? animationStates[index] : false
                    )
                }
            }
        }
        .onAppear {
            initializeAnimationStates()
        }
        .onChange(of: isRunning) { running in
            if running {
                startAnimation()
            } else {
                stopAnimation()
            }
        }
        .onChange(of: mode) { _ in
            initializeAnimationStates()
        }
    }
    
    private func initializeAnimationStates() {
        animationStates = Array(repeating: false, count: 12)
    }
    
    private func startAnimation() {
        for i in 0..<animationStates.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                if i < animationStates.count {
                    animationStates[i] = true
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationStates = Array(repeating: false, count: 12)
    }
}

// 单个动画符号
struct AnimatedSymbol: View {
    let symbol: String
    let symbolColors: [Color]
    let index: Int
    let isAnimating: Bool
    
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var scale: Double = 0.5
    @State private var opacity: Double = 0
    @State private var colorIndex: Int = 0
    
    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 20 + Double(index % 3) * 10, weight: .medium))
            .foregroundColor(symbolColors[colorIndex % symbolColors.count])
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .position(position)
            .onAppear {
                setupInitialPosition()
                colorIndex = Int.random(in: 0..<symbolColors.count)
            }
            .onChange(of: isAnimating) { animating in
                if animating {
                    startFloatingAnimation()
                } else {
                    resetAnimation()
                }
            }
    }
    
    private func setupInitialPosition() {
        // 随机初始位置
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        position = CGPoint(
            x: CGFloat.random(in: 40...(screenWidth - 40)),
            y: CGFloat.random(in: 100...(screenHeight - 200))
        )
    }
    
    private func startFloatingAnimation() {
        // 淡入动画
        withAnimation(.easeIn(duration: 0.5)) {
            opacity = 0.6
            scale = 1.0
        }
        
        // 持续的浮动动画
        withAnimation(
            .linear(duration: Double.random(in: 3...6))
            .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
        
        withAnimation(
            .easeInOut(duration: Double.random(in: 2...4))
            .repeatForever(autoreverses: true)
        ) {
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            
            position = CGPoint(
                x: CGFloat.random(in: 40...(screenWidth - 40)),
                y: CGFloat.random(in: 100...(screenHeight - 200))
            )
            scale = Double.random(in: 0.8...1.5)
        }
        
        withAnimation(
            .easeInOut(duration: Double.random(in: 1...3))
            .repeatForever(autoreverses: true)
        ) {
            opacity = Double.random(in: 0.4...0.8)
        }
        
        // 随机改变颜色
        withAnimation(
            .easeInOut(duration: Double.random(in: 2...5))
            .repeatForever(autoreverses: false)
        ) {
            colorIndex = (colorIndex + 1) % symbolColors.count
        }
    }
    
    private func resetAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.5
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
    @State private var timeRemaining = 0000
    @State private var timer: Timer?
    @State private var currentTask = ""
    @State private var currentMode: MischievousMode = .sleeping
    @State private var isAnimating = false
    
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
            // 背景动画
            AnimatedBackgroundView(isRunning: isRunning, mode: currentMode)
            
            VStack(spacing: 18) {
                // 狀態按鈕 - 可以選擇搗蛋模式
                Button {
                    isShowingModeSheet = true
                } label: {
                    Text("狀態：\(currentMode.displayName) > ")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .foregroundColor(.blue)
                }
                
                // 貓咪圖片 - 根據選擇的模式顯示自訂圖片
                VStack {
                    Image(currentMode.customImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 240, height: 200)
                        .padding()
                        .modifier(AnimatedCatModifier(
                            isRunning: isRunning,
                            animationType: currentMode.animationType
                        ))
                }
                
                // 時間顯示
                Text(timeDisplay)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                    .foregroundColor(isRunning ? .blue : .gray)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                
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
                            .overlay(
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
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
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

// 貓咪動畫 Modifier
struct AnimatedCatModifier: ViewModifier {
    let isRunning: Bool
    let animationType: AnimationType
    @State private var animationState = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scaleEffect)
            .rotationEffect(rotationEffect)
            .offset(offsetEffect)
            .opacity(opacityEffect)
            .animation(animationStyle, value: animationState)
            .onAppear {
                if isRunning {
                    animationState = true
                }
            }
            .onChange(of: isRunning) { running in
                animationState = running
            }
    }
    
    private var scaleEffect: CGFloat {
        guard isRunning && animationState else { return 1.0 }
        switch animationType {
        case .breathing: return 1.05
        case .bounce: return 1.1
        case .shock: return 1.08
        default: return 1.0
        }
    }
    
    private var rotationEffect: Angle {
        guard isRunning && animationState else { return .degrees(0) }
        switch animationType {
        case .shake: return .degrees(8)
        case .wiggle: return .degrees(5)
        case .bite: return .degrees(10)
        case .rummage: return .degrees(6)
        default: return .degrees(0)
        }
    }
    
    private var offsetEffect: CGSize {
        guard isRunning && animationState else { return .zero }
        switch animationType {
        case .shake: return CGSize(width: 3, height: 0)
        case .rummage: return CGSize(width: 2, height: 2)
        case .shock: return CGSize(width: 1, height: 1)
        default: return .zero
        }
    }
    
    private var opacityEffect: Double {
        guard isRunning else { return 1.0 }
        switch animationType {
        case .shock: return animationState ? 0.8 : 1.0
        default: return 1.0
        }
    }
    
    private var animationStyle: Animation {
        switch animationType {
        case .breathing:
            return .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
        case .shake, .wiggle:
            return .easeInOut(duration: 0.4).repeatForever(autoreverses: true)
        case .bounce:
            return .easeOut(duration: 0.8).repeatForever(autoreverses: true)
        case .bite:
            return .linear(duration: 0.3).repeatForever(autoreverses: true)
        case .shock:
            return .easeInOut(duration: 0.2).repeatForever(autoreverses: true)
        case .rummage:
            return .easeInOut(duration: 0.6).repeatForever(autoreverses: true)
        }
    }
}

// 搣蛋模式選擇的 Sheet 頁面
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
            VStack(spacing: 16) {
                
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
