import Foundation
import SwiftUI
import Combine
import CoreData

@MainActor
final class GroupViewModel: ObservableObject {
    @Published var groups: [GroupEntity] = []
    @Published var showingAddGroup = false
    @Published var newGroupName = ""
    @Published var newMemberNames: [String] = [""]
    
    private let dataManager = DataManager.shared
    
    func loadGroups() {
        groups = dataManager.fetchGroups()
    }
    
    func addMemberField() {
        newMemberNames.append("")
    }
    
    func removeMemberField(at index: Int) {
        guard newMemberNames.count > 1 else { return }
        newMemberNames.remove(at: index)
    }
    
    func createGroup() {
        let validNames = newMemberNames
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard !newGroupName.trimmingCharacters(in: .whitespaces).isEmpty, !validNames.isEmpty else { return }
        
        if dataManager.isFreeGroupLimitReached {
            return
        }
        
        _ = dataManager.createGroup(name: newGroupName.trimmingCharacters(in: .whitespaces), members: validNames)
        newGroupName = ""
        newMemberNames = [""]
        showingAddGroup = false
        loadGroups()
    }
    
    func deleteGroup(_ group: GroupEntity) {
        dataManager.context.delete(group)
        dataManager.save()
        loadGroups()
    }
    
    func membersForGroup(_ group: GroupEntity) -> [MemberEntity] {
        if let members = group.members as? Set<MemberEntity> {
            return members.sorted { $0.name ?? "" < $1.name ?? "" }
        }
        return []
    }
}
