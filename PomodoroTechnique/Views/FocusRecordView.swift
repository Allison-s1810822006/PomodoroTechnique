import SwiftUI

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
            .background(Color.white)
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
