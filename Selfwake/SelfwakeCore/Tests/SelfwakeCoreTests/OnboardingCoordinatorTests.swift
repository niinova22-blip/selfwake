import Testing
@testable import SelfwakeCore

@Suite("OnboardingCoordinator ilerleme")
struct OnboardingCoordinatorTests {
    @Test("Welcome ile başlar")
    func startsAtWelcome() {
        let coordinator = OnboardingCoordinator()
        #expect(coordinator.step == .welcome)
        #expect(!coordinator.isComplete)
    }

    @Test("Sırayla tüm adımlardan geçer")
    func advancesThroughAllSteps() {
        var coordinator = OnboardingCoordinator()
        let expected: [OnboardingStep] = [
            .howItWorks, .science, .honesty, .permissions, .reminderSetup, .targetTimeSetup
        ]
        for step in expected {
            coordinator.advance()
            #expect(coordinator.step == step)
        }
    }

    @Test("Son adımdan sonra advance() tamamlandı işaretler")
    func completesAfterLastStep() {
        var coordinator = OnboardingCoordinator()
        for _ in 0..<6 { coordinator.advance() }
        #expect(coordinator.step == .targetTimeSetup)
        #expect(!coordinator.isComplete)
        coordinator.advance()
        #expect(coordinator.isComplete)
    }

    @Test("goBack bir adım geri götürür")
    func goBackMovesOneStepBack() {
        var coordinator = OnboardingCoordinator()
        coordinator.advance()
        coordinator.advance()
        #expect(coordinator.step == .science)
        coordinator.goBack()
        #expect(coordinator.step == .howItWorks)
    }

    @Test("Welcome'da goBack hiçbir şey yapmaz")
    func goBackNoOpAtWelcome() {
        var coordinator = OnboardingCoordinator()
        coordinator.goBack()
        #expect(coordinator.step == .welcome)
    }
}
