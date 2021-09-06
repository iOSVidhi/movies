import Foundation
import UIKit
import CoreData

protocol Stateful {
    @discardableResult
    func loading(loading:(()->Void)?) -> Stateful
    
    @discardableResult
    func `catch`(failure:((WebError)->Void)?) -> Stateful
    
    @discardableResult
    func finish(finish:(()->Void)?) -> Stateful
    
    @discardableResult
    func success(success:((Stateful)->Void)?) -> Stateful
    
    func trigger()
}

class MovieListViewModel {
    
    //MARK:- Variables -
    var movies                  : [MovieList] = []
    var movieDetailArray        : [MovieTitleDetails] = []
    let managedContext          = Application.shared.persistentContainer.viewContext

    //MARK:- State -
    private var _loading: (()->Void)?
    private var _success: ((MovieListViewModel)->Void)?
    private var _failure: ((WebError)->Void)?
    private var _finish : (()->Void)?
    
    var count: Int {
        return movies.count
    }
    
    var total_page: Int = 500
    var currentPage : Int = 1

    //MARK:- Save movie object to coredata -
    func cacheCoreData(movie: MovieTitleDetails){
        
        let coreMovie = MovieList(context: managedContext)
        coreMovie.id1 = Int32(movie.id ?? 00)
        coreMovie.title1 = movie.title
        coreMovie.releaseDate1 = movie.release_date
        coreMovie.overview1 = movie.overview
        coreMovie.posterPath1 = movie.poster_path
        do{
            try managedContext.save()
        } catch{
            print("Error in save context\(error)")
        }
    }
    
    // MARK:- Delete all coredata -
    func deleteAllData(){
        let managedContext = Application.shared.persistentContainer.viewContext
        do {
            let items = try managedContext.fetch(MovieList.fetchRequest()) as! [NSManagedObject]
            for item in items {
                managedContext.delete(item)
            }
            try managedContext.save()
            
        } catch {
            print("Error in deleting...")
        }
    }
    
    //MARK:- Fetch data from coredata -
    func fetchCoreData(){
        if Util.isInternetAvailable() == true {
            self.fetchDataFromApi()
            print("Fetched from API")
        } else {
            movies = DatabaseHandler.shared.fetchMovieList()
            self.currentPage = movies.count/20
            self._success?(self)
            print("Fetched from coredata")
        }
    }
    
    //MARK:- Fetch data from API -
    func fetchDataFromApi(){
        
        if (Util.isInternetAvailable()) {
            Web.sendRequest(.moviesList(pageNumber: "\(self.currentPage)") , type: MovieDecodable.self) { (response) in
                print(response)
                self.total_page = response.total_pages ?? 1
                if let movieDetails = response.results {
                    if self.currentPage == 1 {
                        self.deleteAllData()
                    }
                    self.movieDetailArray = movieDetails
                    for movie in movieDetails {
                        self.cacheCoreData(movie: movie)
                    }
                    self.movies = DatabaseHandler.shared.fetchMovieList()
                    self.currentPage = self.movies.count/20
                    self._success?(self)
                }else {
                    self._failure?(.noData)
                }
            } failureCompletion: { (error, responseError) in
                self._failure?(error)
            }
        } else {
            self._failure?(.noInternet)
        }
    }
    
    //MARK:- Configure Cell -
    func configure(cell: MovieListCollectionViewCell, indexPath: IndexPath) {
        cell.movie = movies[indexPath.row]
        self._finish?()
    }
}

extension MovieListViewModel: Stateful {
    @discardableResult
    func loading(loading:(()->Void)?) -> Stateful {
        self._loading = loading
        return self
    }
    
    @discardableResult
    func `catch`(failure:((WebError)->Void)?) -> Stateful {
        self._failure = failure
        return self
    }
    
    @discardableResult
    func finish(finish:(()->Void)?) -> Stateful {
        self._finish = finish
        return self
    }
    
    @discardableResult
    func success(success:((Stateful)->Void)?) -> Stateful {
        self._success = success
        return self
    }
    
    func trigger() {
        self._loading?()
        fetchCoreData()
    }
}
