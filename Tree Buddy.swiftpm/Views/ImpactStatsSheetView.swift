//
//  ImpactStatsSheetView.swift
//  Tree Buddy
//
//  Created by Chris Pagolu.
//

import SwiftUI
import Charts

// MARK: - ImpactStatsSheetView
// This view displays the impact metrics of the user's forest.
// It includes additional impact metrics, CO₂ reduction, forest growth, water usage, and growth duration charts.

struct ImpactStatsSheetView: View {
    @ObservedObject var treeVM: TreeViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Additional Impact Metrics (Energy Saved, Air Quality).
                    HStack(spacing: 16) {
                        ImpactMetricCard(
                            title: "Energy Saved",
                            value: String(format: "%.1f kWh", treeVM.totalCO2Reduction * 0.5),
                            description: "Estimated energy saved through CO₂ reduction.",
                            systemImage: "bolt.fill"
                        )
                        ImpactMetricCard(
                            title: "Air Quality",
                            value: String(format: "%.0f%%", Double(treeVM.trees.count) * 3.0),
                            description: "Virtual improvement in air quality.",
                            systemImage: "wind"
                        )
                    }
                    .padding(.horizontal)
                    
                    Divider()
                    
                    // CO₂ Reduction Chart.
                    Text("CO₂ Reduction Over Time")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    ChartView(data: treeVM.co2Data, yLabel: "kg CO₂")
                        .frame(height: 200)
                        .padding(.bottom, 4)
                    Text("Estimates based on real‑life planting.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Forest Growth Chart.
                    Text("Forest Growth")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    ChartView(data: treeVM.forestData, yLabel: "Trees")
                        .frame(height: 200)
                        .padding(.bottom, 4)
                    Text("Number of trees planted over time.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Water Usage Chart.
                    Text("Water Usage Over Time")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityAddTraits(.isHeader)
                    ChartView(data: treeVM.waterData, yLabel: "Water Count")
                        .frame(height: 200)
                        .padding(.bottom, 4)
                    Text("Total waterings per day across your forest.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Growth Duration Chart.
                    let growthDurations = treeVM.trees.compactMap { tree -> TreeGrowthDuration? in
                        if let fullDate = tree.fullGrownDate {
                            return TreeGrowthDuration(
                                id: tree.id,
                                name: tree.name,
                                durationMinutes: fullDate.timeIntervalSince(tree.plantedDate) / 60
                            )
                        }
                        return nil
                    }
                    
                    // Display growth duration chart only if there are trees in the forest.
                    if !growthDurations.isEmpty {
                        Text("Growth Duration per Tree (minutes)")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityAddTraits(.isHeader)
                        Chart {
                            // Display bar marks for each tree.
                            ForEach(growthDurations) { data in
                                BarMark(
                                    x: .value("Tree", data.name),
                                    y: .value("Duration (min)", data.durationMinutes)
                                )
                                .cornerRadius(5)
                            }
                        }
                        .frame(height: 200)
                        .padding(.bottom, 4)
                        Text("Time taken for each tree to reach full growth.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .navigationTitle("Your Impact")
            .accessibilityElement(children: .contain)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityLabel("Done")
                        .accessibilityHint("Tap to close the impact view")
                }
            }
        }
    }
}

// MARK: - ImpactMetricCard, ChartView
// These views are used to display impact metrics and charts in the ImpactStatsSheetView.

struct TreeGrowthDuration: Identifiable {
    var id: UUID
    var name: String
    var durationMinutes: Double
}

struct ImpactMetricCard: View {
    let title: String
    let value: String
    let description: String
    let systemImage: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: systemImage)
                    .font(.title)
                    .foregroundColor(.green)
                    .accessibilityHidden(true)
                Text(title)
                    .font(.headline)
            }
            Text(value)
                .font(.largeTitle.bold())
                .accessibilityLabel("\(value)")
            Text(description)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .accessibilityElement(children: .combine)
    }
}

// ChartView displays a line chart with the provided data points and y-axis label.
struct ChartView: View {
    var data: [ImpactDataPoint]
    var yLabel: String
    
    var body: some View {
        Chart {
            ForEach(data) { point in
                LineMark(
                    x: .value("Time", point.date),
                    y: .value(yLabel, point.value)
                )
                .symbol(Circle())
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic)
        }
        .chartYScale(domain: .automatic)
        .accessibilityLabel("Chart displaying \(yLabel) over time")
    }
}
