import SwiftUI
import Lottie
 
public struct LottieView: UIViewRepresentable {
    let lottieFile: String
    let loopMode: Bool
 
    let animationView = LottieAnimationView()
    var complete: (() -> Void)? = nil
    public func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        animationView.animation = LottieAnimation.named(lottieFile)
        animationView.contentMode = .scaleAspectFit
        if self.loopMode == true {
            animationView.loopMode = .loop
        }
        animationView.play(completion: {_ in
            complete?()
        })
        view.addSubview(animationView)
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
 
        return view
    }
 
    public func updateUIView(_ uiView: UIViewType, context: Context) {
 
    }
}
