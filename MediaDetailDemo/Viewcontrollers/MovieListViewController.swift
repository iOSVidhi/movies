import UIKit

class MovieListViewController: UIViewController {
    
    //MARK:- Outlets -
    @IBOutlet weak var movieListCollectionView  : UICollectionView!
    
    //MARK:- Variables -
    lazy var movieListViewModel = MovieListViewModel()
    var isLoading : Bool = true
    
    //MARK:- ViewController Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        if Util.isInternetAvailable() == false {
            self.isLoading = false
        }
        prepareViewModel()
    }
    
    //MARK:- ViewController Methods -
    func prepareViewModel() {
        movieListViewModel.loading {
            if self.movieListViewModel.currentPage == 1 {
                self.movieListCollectionView.startLoading()
            }
        }.success { [weak self] movieListViewModel in
            if Util.isInternetAvailable() == true {
                self?.isLoading = true
            }
            self?.movieListCollectionView.reloadData()
        }.finish {
            if self.movieListViewModel.currentPage == 1 {
                self.movieListCollectionView.stopLoading()
            }
        }.catch { error in
            Alert.shared.ShowAlert(title: "Error while fetching data from API", message: error.localizedDescription, in: self);
            //Show errors
        }.trigger()
    }
}

//MARK:- TableView DataSource & Delegate Methods -
extension MovieListViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieListViewModel.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.registerAndGet(cell: MovieListCollectionViewCell.self, indexPath : indexPath)!
        movieListViewModel.configure(cell: cell, indexPath: indexPath)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = UIScreen.main.bounds.size
        return CGSize(width: (size.width-30)/2, height: 235)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > movieListViewModel.count - 3, movieListViewModel.currentPage < movieListViewModel.total_page {
            if isLoading {
                isLoading = false
                movieListViewModel.currentPage += 1
                self.prepareViewModel()
            }
        }
    }
}
