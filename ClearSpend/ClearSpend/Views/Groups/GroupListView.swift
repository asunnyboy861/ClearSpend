import SwiftUI
import CoreData

struct GroupListView: View {
    @StateObject private var viewModel = GroupViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.groups.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(viewModel.groups, id: \.objectID) { group in
                            groupCard(group)
                        }
                    }
                }
                .padding()
            }
            .frame(maxWidth: 720)
            .frame(maxWidth: .infinity)
            .navigationTitle("Groups")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingAddGroup = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddGroup) {
                addGroupSheet
            }
            .onAppear {
                viewModel.loadGroups()
            }
        }
    }
    
    private func groupCard(_ group: GroupEntity) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(group.name ?? "Unnamed Group")
                    .font(.headline)
                Spacer()
                Button(role: .destructive, action: { viewModel.deleteGroup(group) }) {
                    Image(systemName: "trash")
                        .font(.caption)
                }
            }
            
            let members = viewModel.membersForGroup(group)
            if !members.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(members, id: \.objectID) { member in
                            HStack(spacing: 4) {
                                Image(systemName: "person.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                Text(member.name ?? "")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .cardStyle()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.3")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No groups yet")
                .font(.headline)
            Text("Create a group to start splitting expenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
    
    private var addGroupSheet: some View {
        NavigationStack {
            Form {
                Section("Group Name") {
                    TextField("e.g., Roommates, Trip to NYC", text: $viewModel.newGroupName)
                }
                
                Section("Members") {
                    ForEach(viewModel.newMemberNames.indices, id: \.self) { index in
                        HStack {
                            TextField("Member name", text: $viewModel.newMemberNames[index])
                            if viewModel.newMemberNames.count > 1 {
                                Button(action: { viewModel.removeMemberField(at: index) }) {
                                    Image(systemName: "minus.circle")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    Button(action: viewModel.addMemberField) {
                        Label("Add Member", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.showingAddGroup = false
                        viewModel.newGroupName = ""
                        viewModel.newMemberNames = [""]
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        viewModel.createGroup()
                    }
                    .disabled(viewModel.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
