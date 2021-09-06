import Foundation
import Kingfisher

extension UIImageView {
    func startLoading() {
        self.stopLoading()
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = UIColor.black
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        activityIndicatorView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        self.addSubview(activityIndicatorView)
    }

    func stopLoading() {
        for v in self.subviews {
            if v is UIActivityIndicatorView {
                v.removeFromSuperview()
            }
        }
    }

    func setImageWith(string: String) {
        if let url = URL(string: string) {
            if self.frame.size.width >= self.frame.size.height {
                self.kf.setImage(with: url, placeholder: nil,options: [.transition(.fade(0.2)),.keepCurrentImageWhileLoading])
            } else {
                self.kf.setImage(with: url, placeholder: nil,options: [.transition(.fade(0.2)),.keepCurrentImageWhileLoading])
            }
        } else {
            //self.image = placeholder
        }
    }
}
