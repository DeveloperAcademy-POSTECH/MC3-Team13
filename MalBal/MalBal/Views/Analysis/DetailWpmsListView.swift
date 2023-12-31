//
//  DetailWpmsListView.swift
//  MalBal
//
//  Created by Eric Lee on 2023/07/31.
//

import SwiftUI

struct DetailWpmsListView: View {
    @EnvironmentObject var vm: AnalysisViewModel
    
    var body: some View {
        ZStack{
            
            Rectangle()
                .foregroundColor(.main4)
            
            ScrollView {
                VStack(alignment: .center, spacing: 0) {
                    ForEach(vm.record.detailWpms.indices, id:  \.self) { index in
                        let wpm = vm.record.detailWpms[index]
                        Button {
                            vm.seekToMinute(index)
                        } label: {
                            DetailWpmsListCellView(index: index, wpm: wpm)
                        }
                        if index < vm.record.detailWpms.count - 1 {
                            scrollDevider
                        }
                    }
                }
                .frame(width: GLConstants.glScreenWidth - 48)

            }
        }
        .frame(width: GLConstants.glScreenWidth - 48, height: 191)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private struct DetailWpmsListCellView: View {
        @EnvironmentObject var vm: AnalysisViewModel
        var index: Int
        var wpm: Int
        
        var body: some View {
            HStack(alignment: .top, spacing: 0) {
                
                Image("\(vm.detailWpmImageName(wpm: wpm))")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .padding(.leading, 50)
                    .padding(.top, 7)
                    .padding(.trailing, 12)
                
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("\(vm.cellTimeText(index: index))")
                        .font(FontManager.shared.appleSDGothicNeo(.medium, 12))
                        .foregroundColor(Color(hex: "FFFFFF").opacity(0.4))
                    
                    HStack(spacing: 6) {
                        Text("\(vm.cellSpeedText(wpm: wpm))")
                            .font(FontManager.shared.appleSDGothicNeo(.semibold, 16))
                            .foregroundColor(Color(hex: "FFFFFF"))
                        Text("・")
                            .font(FontManager.shared.appleSDGothicNeo(.semibold, 16))
                            .foregroundColor(Color(hex: "FFFFFF"))
                        HStack(spacing: 0) {
                            Text("\(wpm)")
                                .font(FontManager.shared.appleSDGothicNeo(.semibold, 16))
                                .foregroundColor(Color(hex: "FFFFFF"))
                            Text("w/min")
                                .font(FontManager.shared.appleSDGothicNeo(.semibold, 10))
                                .foregroundColor(Color(hex: "FFFFFF"))
                        }
                    }
                        
                }
                .frame(height: 32)
                .padding(.top, 15)
                
                Spacer()
                
                if index == Int(vm.currentTime) / 60 {
                    Image(systemName: "checkmark")
                        .font(FontManager.shared.appleSDGothicNeo(.semibold, 24))
                        .foregroundColor(Color(hex: "FFFFFF"))
                        .frame(width: 23, height: 22)
                        .padding(.top, 20)
                        .padding(.trailing, 44)
                }
            }
            .frame(maxWidth: 393)
            .frame(height: 64)
        }
        
    }
    
    private var scrollDevider: some View {
        Rectangle()
            .frame(width: 319, height: 0.5)
            .foregroundColor(Color(hex: "FFFFFF").opacity(0.3))
    }
    
}

struct DetailWpmsListView_Previews: PreviewProvider {
    static let testRecord = Record(createdAt: Date(),
                                   wpm: 100,
                                   detailWpms: [100, 200, 300, 400, 500])
    static let testEnvObject = AnalysisViewModel(record: testRecord)
    
    static var previews: some View {
        DetailWpmsListView()
            .environmentObject(testEnvObject)
    }
}
