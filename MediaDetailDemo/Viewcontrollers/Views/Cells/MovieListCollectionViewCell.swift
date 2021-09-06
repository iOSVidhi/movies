import UIKit

class MovieListCollectionViewCell: UICollectionViewCell {
    
    //MARK:- Outlet -
    @IBOutlet weak var movieImageView       : UIImageView!
    @IBOutlet weak var movieNameLabel       : UILabel!
    
    //MARK:- Set Data -
    var movie: MovieList! {
        didSet {
            movieImageView.image = UIImage(named: "moviePosterPlaceholder")
            movieNameLabel.text   = movie.title1
            let posterPath = movie.posterPath1
            let strUrl = "https://image.tmdb.org/t/p/original\(posterPath ?? "")"
            movieImageView.kf.setImage(with: URL(string: strUrl))
        }
    }
}
