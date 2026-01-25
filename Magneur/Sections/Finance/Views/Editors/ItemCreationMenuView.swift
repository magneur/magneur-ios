//
//  ItemCreationMenuView.swift
//  Magneur
//
//  Created by Claude on 25.01.2026.
//

import SwiftUI

/// Menu for selecting which type of financial item to create
struct ItemCreationMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAssetType: FinancialItemType?
    @State private var selectedLiabilityType: FinancialItemType?
    @State private var showingGoalEditor = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: AppSection.finance.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Assets section
                        sectionView(title: "Assets", types: FinancialItemType.assetTypes) { type in
                            selectedAssetType = type
                        }

                        // Liabilities section
                        sectionView(title: "Liabilities", types: FinancialItemType.liabilityTypes) { type in
                            selectedLiabilityType = type
                        }

                        // Goals section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Goals")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)

                            Button {
                                showingGoalEditor = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "target")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                        .frame(width: 40, height: 40)
                                        .background(.blue.opacity(0.2))
                                        .clipShape(Circle())

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Financial Goal")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(.white)

                                        Text("Set savings targets or debt payoff goals")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.6))
                                            .lineLimit(1)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                                .padding(12)
                                .background(.ultraThinMaterial.opacity(0.3))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Item")
                        .font(.headline)
                        .foregroundStyle(.white)
                }

                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .sheet(item: $selectedAssetType) { type in
            editorView(for: type, isAsset: true)
        }
        .sheet(item: $selectedLiabilityType) { type in
            editorView(for: type, isAsset: false)
        }
        .sheet(isPresented: $showingGoalEditor) {
            GoalEditorView(goal: .savingsTarget()) {
                dismiss()
            }
        }
    }

    private func sectionView(title: String, types: [FinancialItemType], onSelect: @escaping (FinancialItemType) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 4)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(types) { type in
                    Button {
                        onSelect(type)
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type.icon)
                                .font(.title2)
                                .foregroundStyle(type.accentColor)

                            Text(type.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.ultraThinMaterial.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func editorView(for type: FinancialItemType, isAsset: Bool) -> some View {
        switch type {
        // Assets
        case .cashSavings:
            CashSavingsEditorView(item: .cashSavings()) { dismiss() }
        case .realEstate:
            RealEstateEditorView(item: .realEstate()) { dismiss() }
        case .vehicle:
            VehicleEditorView(item: .vehicle()) { dismiss() }
        case .preciousMetal:
            PreciousMetalEditorView(item: .preciousMetal(metalType: .gold)) { dismiss() }
        case .stock:
            StockEditorView(item: .stock()) { dismiss() }
        case .etfMutualFund:
            ETFEditorView(item: .etfMutualFund()) { dismiss() }
        case .bond:
            BondEditorView(item: .bond()) { dismiss() }
        case .crypto:
            CryptoEditorView(item: .crypto()) { dismiss() }
        case .businessEquity:
            BusinessEquityEditorView(item: .businessEquity()) { dismiss() }
        case .retirementAccount:
            RetirementAccountEditorView(item: .retirementAccount()) { dismiss() }
        case .otherAsset:
            OtherAssetEditorView(item: .otherAsset()) { dismiss() }

        // Liabilities
        case .mortgage:
            MortgageEditorView(item: .mortgage()) { dismiss() }
        case .autoLoan:
            AutoLoanEditorView(item: .autoLoan()) { dismiss() }
        case .studentLoan:
            StudentLoanEditorView(item: .studentLoan()) { dismiss() }
        case .creditCard:
            CreditCardEditorView(item: .creditCard()) { dismiss() }
        case .personalLoan:
            PersonalLoanEditorView(item: .personalLoan()) { dismiss() }
        case .businessLoan:
            BusinessLoanEditorView(item: .businessLoan()) { dismiss() }
        case .medicalDebt:
            MedicalDebtEditorView(item: .medicalDebt()) { dismiss() }
        case .otherLiability:
            OtherLiabilityEditorView(item: .otherLiability()) { dismiss() }
        }
    }
}

#Preview {
    ItemCreationMenuView()
}
