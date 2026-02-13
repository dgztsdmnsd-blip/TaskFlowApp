//
//  BacklogView.swift
//  TaskFlow
//
//  Created by luc banchetti on 05/02/2026.
//

import SwiftUI

struct BacklogView: View {

    @StateObject private var vm: ProjectListViewModel
    @EnvironmentObject private var sessionVM: SessionViewModel
    
    @State private var tags: [TagResponse] = []
    @State private var selectedTag: TagResponse? = nil
    @State private var isFiltering = false
    
    // INIT PROD
    init(etatUS: StoryStatus = .inProgress) {
        _vm = StateObject(wrappedValue: ProjectListViewModel())
    }

    // INIT PREVIEW / TEST
    init(
        vm: ProjectListViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
    }
    

    var body: some View {
        VStack {
            // Filtre par Tag
            tagsFilterInfo
            tagsFilterBar
            
            if isFiltering {
                ProgressView("Filtrage…")
            }
            
            // Projets et user stories
            if vm.isLoading {
                ProgressView()
                
            } else if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                
            } else if vm.projects.isEmpty {
                Text("Aucun projet trouvé")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.projects) { project in
                            BacklogProjetsView(
                                project: project,
                                isOwner: project.owner.id == sessionVM.currentUser?.id
                            )
                            .padding()
                        }
                    }
                }
            }
        }
        .background(
            BackgroundView(ecran: .backlog)
        )
        .task {
            guard !ProcessInfo.isRunningPreviews else { return }
            await vm.fetchActiveProjects()
            await loadTags()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .projectListShouldRefresh)
        ) { _ in
            Task { await vm.fetchActiveProjects() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userStoryDidChange)) { _ in
            Task {
                if let selectedTag {
                    filterByTag(selectedTag)     // conserve filtre
                } else {
                    await vm.fetchActiveProjects()
                }
            }
        }

    }
    
    
    func loadTags() async {
        do {
            tags = try await TagsService.shared.listTags()
        } catch {
            print("Erreur chargement tags:", error)
        }
    }
    
    
    var tagsFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {

                // Reset filtre
                TagFilterChip(
                    title: "Tous",
                    isSelected: selectedTag == nil
                ) {
                    selectedTag = nil
                    Task {
                        await vm.fetchActiveProjects()

                        withAnimation {
                            // animation visuelle déclenchée après update
                        }
                    }
                }

                // Tags API
                ForEach(tags) { tag in
                    TagFilterChip(
                        title: tag.tagName,
                        color: Color(hex: tag.couleur),
                        isSelected: selectedTag?.id == tag.id
                    ) {
                        selectedTag = tag
                        filterByTag(tag)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    var tagsFilterInfo: some View {
        Group {
            if let activeTag = selectedTag {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.secondary)

                    Text("Filtré par :")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TagBadgeMiniView(tag: activeTag)

                    Spacer()

                    Button {
                        self.selectedTag = nil
                        Task { await vm.fetchActiveProjects() }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }



    func filterByTag(_ tag: TagResponse) {
        Task {
            isFiltering = true
            defer { isFiltering = false }

            do {
                let impact = try await TagsService.shared.fetchTagImpact(tagId: tag.id)

                withAnimation(.easeInOut) {
                    vm.projects = impact.projects
                }

            } catch {
                print("Erreur filtrage tag:", error)
            }
        }
    }


}
