import SwiftUI

struct MaintenanceTipsView: View {
    @ObservedObject var tipManager: MaintenanceTipManager
    
    var body: some View {
        VStack {
            Text("Maintenance Tips")
                .font(.title)
                .padding()
            
            if tipManager.maintenanceTips.isEmpty {
                Text("현재 제공할 유지 관리 팁이 없습니다.")
                    .font(.body)
                    .padding()
            } else {
                List(tipManager.maintenanceTips, id: \.self) { tip in
                    Text(tip)
                        .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding()
    }
}
