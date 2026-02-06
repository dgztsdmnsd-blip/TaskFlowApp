@MainActor
final class UserProjectsViewModel: ObservableObject {

    @Published var projects: [ProjectResponse] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let userId: Int

    init(userId: Int) {
        self.userId = userId
    }

    func fetchProjects() async {
        isLoading = true
        errorMessage = nil

        do {
            projects = try await ProjectService.shared
                .listProjects(for: userId)
        } catch APIError.httpError(_, let message) {
            errorMessage = message
        } catch {
            errorMessage = "Erreur réseau."
        }

        isLoading = false
    }
}
