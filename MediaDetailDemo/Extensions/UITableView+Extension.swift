import Foundation
import UIKit

extension UICollectionView {

    func registerAndGet<T:UICollectionViewCell>(cell identifier:T.Type, indexPath : IndexPath) -> T?{
        let cellID = String(describing: identifier)

        self.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
        return self.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? T
    }

    func register<T:UICollectionViewCell>(cell identifier:T.Type) {
        let cellID = String(describing: identifier)
        self.register(UINib(nibName: cellID, bundle: nil), forCellWithReuseIdentifier: cellID)
    }
    
    var isLoading:Bool?{
        if let _ = self.superview {
            for v in self.superview!.subviews {
                if v is UIActivityIndicatorView {
                    if v.accessibilityValue == "tableLoader" {
                        return true
                    }
                }
            }
        }
        return false
    }

    func startLoading(withExtraTop: CGFloat = 10) {
        self.stopLoading(withAnimation: false)

        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.color = UIColor.black
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.accessibilityValue = "tableLoader"
        activityIndicatorView.startAnimating()

        self.superview?.addSubview(activityIndicatorView)

        self.contentInset = UIEdgeInsets(top: activityIndicatorView.frame.height + 20, left: 0, bottom: 0, right: 0)

        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

        let horizontalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)

        let verticalConstraint = NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: withExtraTop)

        self.superview?.addConstraints([horizontalConstraint,verticalConstraint])
    }

    func stopLoading(withAnimation: Bool = false) {
        if let _ = self.superview {
            for v in self.superview!.subviews {
                if v is UIActivityIndicatorView {
                    if v.accessibilityValue == "tableLoader" {
                        v.removeFromSuperview()

                    }
                }
            }
            if withAnimation {
                UIView.animate(withDuration: 0.2) {
                    if Thread.isMainThread {
                        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    } else {
                        DispatchQueue.main.async {
                            self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                        }
                    }
                }
            } else {
                if Thread.isMainThread {
                    self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                } else {
                    DispatchQueue.main.async {
                        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                    }
                }
            }
        }
    }
}
