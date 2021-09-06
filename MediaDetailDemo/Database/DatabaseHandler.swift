import UIKit
import CoreData

class DatabaseHandler {
    
    //MARK:- Variables -
    static let shared: DatabaseHandler = DatabaseHandler()
    let managedContext =  Application.shared.persistentContainer.viewContext
    
    func fetchMovieList() -> [MovieList] {
        var result: [MovieList] = []
        do {
            result = try managedContext.fetch(MovieList.fetchRequest())
        } catch {
            print("Error while fetching movie list")
        }
        return result
    }
    
    func fetchMovieDetails(movieId: Int32) -> [MovieDetails] {
        let request: NSFetchRequest<MovieDetails> = MovieDetails.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "\(movieId)")
        var result: [MovieDetails] = []
        do {
            try result = managedContext.fetch(request)
        } catch {
            print("Error while fetching movie details")
        }
        return result
    }

    func saveContext() {
        do {
            try managedContext.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
