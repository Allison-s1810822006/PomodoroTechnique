import SwiftUI

struct TaskCreationSheet: View {
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedSecond: Int
    @Binding var currentTask: String
    let onComplete: () -> Void
    var onTaskCompleted: ((String) -> Void)? = nil
    let focusRecords: [FocusRecord]
    
    @State private var taskInput = ""
    @FocusState private var isTextFieldFocused: Bool
    @State private var isTaskCompleted = false
    
    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
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
                VStack(spacing: 10) {
                    Text("設定專注時間")
                        .font(.headline)
                        .foregroundColor(.primary)
                    HStack(spacing: 0) {
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
                        let trimmed = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            currentTask = trimmed
                        } else {
                            currentTask = "專注任務"
                        }
                        onComplete()
                    }
                    .fontWeight(.bold)
                }
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
