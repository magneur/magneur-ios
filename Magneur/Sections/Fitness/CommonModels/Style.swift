import UIKit

struct MagneurStyle {
    // MARK: - Colors
    struct Colors {
        static let background = UIColor.magneurBlack()
        static let secondaryBackground = UIColor.magneurBlue()
        static let accent = UIColor.magneurOrange()
        static let text = UIColor.magneurSilver()
        static let secondaryText = UIColor.magneurLightGray()
        static let separator = UIColor.magneurLightGray().withAlphaComponent(0.5)
        static let platinum = UIColor.magneurPlatinum()
    }
    
    // MARK: - Fonts
    struct Fonts {
        static let titleLarge = UIFont(name: "MuseoModerno-Medium", size: 32)!
        static let title = UIFont(name: "MuseoModerno-Medium", size: 24)!
        static let subtitle = UIFont(name: "Raleway-Bold", size: 18)!
        static let body = UIFont(name: "Raleway-Medium", size: 16)!
        static let caption = UIFont(name: "Raleway-Light", size: 14)!
        static let small = UIFont(name: "Raleway-Light", size: 12)!
    }
    
    // MARK: - Layout
    struct Layout {
        static let cornerRadius: CGFloat = 20
        static let smallCornerRadius: CGFloat = 12
        static let standardPadding: CGFloat = 20
        static let smallPadding: CGFloat = 10
    }
    
    // MARK: - Gradients
    struct Gradients {
        static let primary = [
            UIColor.magneurBlack().cgColor,
            UIColor.magneurDarkBlue().cgColor
        ]
        
        static let accent = [
            UIColor.magneurRed().cgColor,
            UIColor.magneurOrange().cgColor
        ]
        
        static let secondary = [
            UIColor.magneurBlue().cgColor,
            UIColor.magneurDarkBlue().cgColor
        ]
        
        static let metallic = [
            UIColor.magneurLightGray().cgColor,
            UIColor.magneurBlack().cgColor
        ]
    }
    
    // MARK: - Cell Styling
    static func applyDefaultCellStyling(_ cell: UITableViewCell) {
        cell.backgroundColor = Colors.secondaryBackground.withAlphaComponent(0.8)
        cell.contentView.backgroundColor = .clear
        cell.textLabel?.textColor = Colors.text
        cell.detailTextLabel?.textColor = Colors.secondaryText
        cell.selectedBackgroundView = {
            let view = UIView()
            view.backgroundColor = Colors.accent.withAlphaComponent(0.1)
            return view
        }()
    }
    
    // MARK: - View Styling
    static func applyStandardShadow(to view: UIView) {
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 8
    }
    
    static func applyGlow(to view: UIView, color: UIColor = Colors.accent) {
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOffset = .zero
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 10
    }
}

// MARK: - UIView Extensions for Magneur
extension UIView {
    func applyMagneurGradient(colors: [CGColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        
        if let existingGradient = layer.sublayers?.first(where: { $0 is CAGradientLayer }) {
            existingGradient.removeFromSuperlayer()
        }
        
        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - UITableView Extensions for Magneur
extension UITableView {
    func applyMagneurStyling() {
        backgroundColor = MagneurStyle.Colors.background
        separatorColor = MagneurStyle.Colors.separator
        separatorInset = UIEdgeInsets(top: 0, left: MagneurStyle.Layout.standardPadding, bottom: 0, right: MagneurStyle.Layout.standardPadding)
    }
}

// MARK: - UINavigationBar Extensions for Magneur
extension UINavigationBar {
    func applyMagneurStyling() {
        tintColor = MagneurStyle.Colors.text
        titleTextAttributes = [
            .foregroundColor: MagneurStyle.Colors.text,
            .font: MagneurStyle.Fonts.title
        ]
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: MagneurStyle.Colors.text,
            .font: MagneurStyle.Fonts.title
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: MagneurStyle.Colors.text,
            .font: MagneurStyle.Fonts.titleLarge
        ]
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
    }
} 