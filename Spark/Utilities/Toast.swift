import UIKit

extension UIViewController {
    
    func showToast(message: String,
                   backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.8),
                   textColor: UIColor = .white,
                   duration: TimeInterval = 2.0) {
        
        let toastLabel = PaddingLabel()
        toastLabel.text = message
        toastLabel.textColor = textColor
        toastLabel.backgroundColor = backgroundColor
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.alpha = 0
        toastLabel.layer.cornerRadius = 12
        toastLabel.clipsToBounds = true
        
        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toastLabel)
        
        NSLayoutConstraint.activate([
            toastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            toastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
        
        UIView.animate(withDuration: 0.3) {
            toastLabel.alpha = 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
            }
        }
    }
}

import UIKit

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 12
    var bottomInset: CGFloat = 12
    var leftInset: CGFloat = 16
    var rightInset: CGFloat = 16
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset,
                                  left: leftInset,
                                  bottom: bottomInset,
                                  right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}
