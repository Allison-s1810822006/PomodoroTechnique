import SwiftUI

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
