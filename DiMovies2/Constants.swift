import Foundation

struct Constants {
    
    static let youtubeEmbedURL = "https://www.youtube.com/embed/"
    
    //MARK: cell identifiers
    static let actorCellIdentifier = "actorCell"
    static let trailerCellIdentifier = "trailerCell"
    static let movieHeaderCellIdentifier = "movieHeaderCell"
    static let movieCellIdentifier = "movieCell"
    static let searchSectionHeaderCellIdentifier = "searchSectionheaderCell"
    static let searchedMovieCellIdentifier = "searchedMovieCell"
    static let selectCollectionToAddMovieCellIdentifier = "selectCollectionToAddMovieCell"
    static let collectionListCellIdentifier = "CollectionListCell"
    
    //MARK: segues
    static let selectedMovieSegue = "selectedMovie"
    static let selectedSearchMovieSegue = "selectedSearchMovie"
    static let addCollectionSegue = "addCollection"
    static let showMoviesSegue = "showMovies"
    static let unknownSegue = "Unknown segue"
    static let didAddCollectionSegue = "didAddCollection"
    
    //MARK: Section headers
    static let moviesSectionHeader = "Movies"
    static let seriesSectionHeader = "Series"
    
    //MARK: Strings
    static let deleteString = "Delete"
    static let cantRemoveCollectionString = "This collection can't be removed"
    static let okString = "Ok"
    static let notAvailableString = "N/A"
    static let idString = "id"
    
    //MARK: Collection id
    static let seenCollectionId = 1
    static let wantToWatchCollectionId = 0
}
