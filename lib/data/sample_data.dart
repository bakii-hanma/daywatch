import '../models/movie_model.dart';
import '../models/comment_model.dart';

class SampleData {
  // Films populaires
  static const List<MovieModel> popularMovies = [
    MovieModel(
      id: '1',
      title: 'Spider-Man: Across the Spider-Verse',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      genre: 'Action • Animation • Adventure',
      duration: '2h 20',
      releaseDate: 'May 31, 2023',
      rating: 8.4,
    ),
    MovieModel(
      id: '2',
      title: 'Guardians of the Galaxy Vol. 3',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      genre: 'Action • Adventure • Comedy',
      duration: '2h 30',
      releaseDate: 'May 5, 2023',
      rating: 8.5,
    ),
    MovieModel(
      id: '3',
      title: 'Fast X',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      genre: 'Action • Crime • Thriller',
      duration: '2h 21',
      releaseDate: 'May 19, 2023',
      rating: 8.2,
    ),
    MovieModel(
      id: '4',
      title: 'John Wick: Chapter 4',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      genre: 'Action • Crime • Thriller',
      duration: '2h 49',
      releaseDate: 'Mar 24, 2023',
      rating: 8.7,
    ),
    MovieModel(
      id: '5',
      title: 'The Flash',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      genre: 'Action • Adventure • Fantasy',
      duration: '2h 24',
      releaseDate: 'Jun 16, 2023',
      rating: 8.0,
    ),
  ];

  // Séries populaires
  static const List<SeriesModel> popularSeries = [
    SeriesModel(
      id: '1',
      title: 'Loki',
      imagePath: 'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
      genre: 'Drama • Sci-Fi & Fantasy',
      seasons: '2 seasons',
      years: '2021 - 2023',
      rating: 8.4,
    ),
    SeriesModel(
      id: '2',
      title: 'The Mandalorian',
      imagePath: 'assets/poster/d88c27338531793104f79107f3fdf1722a0e9fdc.jpg',
      genre: 'Action • Adventure • Sci-Fi',
      seasons: '3 seasons',
      years: '2019 - 2023',
      rating: 8.7,
    ),
    SeriesModel(
      id: '3',
      title: 'House of the Dragon',
      imagePath: 'assets/poster/ee95c8d574be76182adb5fd79675435e550090e2.jpg',
      genre: 'Drama • Fantasy • Action',
      seasons: '2 seasons',
      years: '2022 - 2024',
      rating: 8.5,
    ),
    SeriesModel(
      id: '4',
      title: 'Stranger Things',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      genre: 'Drama • Fantasy • Horror',
      seasons: '4 seasons',
      years: '2016 - 2022',
      rating: 8.7,
    ),
    SeriesModel(
      id: '5',
      title: 'The Witcher',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      genre: 'Action • Adventure • Fantasy',
      seasons: '3 seasons',
      years: '2019 - 2023',
      rating: 8.2,
    ),
  ];

  // Acteurs
  static const List<ActorModel> actors = [
    ActorModel(
      id: '1',
      name: 'Chris Evans',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    ),
    ActorModel(
      id: '2',
      name: 'Millie Bobbie Brown',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ),
    ActorModel(
      id: '3',
      name: 'Elisabeth Olsen',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    ),
    ActorModel(
      id: '4',
      name: 'Tom Holland',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
    ),
    ActorModel(
      id: '5',
      name: 'Scarlett Johansson',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
    ),
    ActorModel(
      id: '6',
      name: 'Robert Downey Jr',
      imagePath: 'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
    ),
  ];

  // Bandes-annonces
  static const List<TrailerModel> trailers = [
    TrailerModel(
      id: '1',
      title: 'The Marvels',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      duration: '3m 14s',
    ),
    TrailerModel(
      id: '2',
      title: 'The Mandalorian',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      duration: '2m 45s',
    ),
    TrailerModel(
      id: '3',
      title: 'House of the Dragon',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      duration: '4m 12s',
    ),
    TrailerModel(
      id: '4',
      title: 'Stranger Things',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      duration: '3m 28s',
    ),
    TrailerModel(
      id: '5',
      title: 'The Witcher',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      duration: '3m 55s',
    ),
  ];

  // Box Office
  static const List<BoxOfficeModel> boxOfficeMovies = [
    BoxOfficeModel(
      id: '1',
      title: 'Avatar',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      earnings: '2 979 439 100 \$',
      duration: '3h 01',
      releaseDate: 'Apr 24, 2019',
      rating: 8.4,
      rank: 1,
    ),
    BoxOfficeModel(
      id: '2',
      title: 'Avengers: Endgame',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      earnings: '2 797 501 328 \$',
      duration: '3h 01',
      releaseDate: 'Apr 26, 2019',
      rating: 8.4,
      rank: 2,
    ),
    BoxOfficeModel(
      id: '3',
      title: 'Titanic',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      earnings: '2 201 647 264 \$',
      duration: '3h 14',
      releaseDate: 'Dec 19, 1997',
      rating: 7.9,
      rank: 3,
    ),
    BoxOfficeModel(
      id: '4',
      title: 'Star Wars',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      earnings: '2 068 223 624 \$',
      duration: '2h 18',
      releaseDate: 'Dec 18, 2015',
      rating: 7.8,
      rank: 4,
    ),
    BoxOfficeModel(
      id: '5',
      title: 'Avengers: Infinity War',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      earnings: '2 048 359 754 \$',
      duration: '2h 29',
      releaseDate: 'Apr 27, 2018',
      rating: 8.4,
      rank: 5,
    ),
  ];

  // Plateformes
  static const List<PlatformModel> platforms = [
    PlatformModel(
      id: '1',
      name: 'Netflix',
      imagePath: 'assets/plateformes/netflix.png',
    ),
    PlatformModel(
      id: '2',
      name: 'Prime Video',
      imagePath: 'assets/plateformes/prime video.png',
    ),
    PlatformModel(
      id: '3',
      name: 'Disney+',
      imagePath: 'assets/plateformes/dysney plus.png',
    ),
    PlatformModel(
      id: '4',
      name: 'Apple TV+',
      imagePath: 'assets/plateformes/apple tv.png',
    ),
    PlatformModel(
      id: '5',
      name: 'Disney+',
      imagePath: 'assets/plateformes/dysney plus.png',
    ),
    PlatformModel(
      id: '6',
      name: 'Apple TV+',
      imagePath: 'assets/plateformes/apple tv.png',
    ),
  ];

  // Commentaires
  static const List<CommentModel> comments = [
    CommentModel(
      id: '1',
      userName: 'Mel Sardes',
      timeAgo: 'Il y a 3 heures',
      comment:
          'Non et quo. Qui nostrum sapiente maxime porro quia est quia corporis excepturi. Repellendus id consequatur necessitatibus cum. Ut dicta soluta. Sunt sit assumenda dolor quia soluta animi repudiandae eos.',
      avatarPath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
    ),
    CommentModel(
      id: '2',
      userName: 'Mel Sardes',
      timeAgo: 'Il y a 3 heures',
      comment:
          'Non et quo. Qui nostrum sapiente maxime porro quia est quia corporis excepturi. Repellendus id consequatur necessitatibus cum. Ut dicta soluta. Sunt sit assumenda dolor quia soluta animi repudiandae eos.',
      avatarPath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
    ),
    CommentModel(
      id: '3',
      userName: 'Mel Sardes',
      timeAgo: 'Il y a 3 heures',
      comment:
          'Non et quo. Qui nostrum sapiente maxime porro quia est quia corporis excepturi. Repellendus id consequatur necessitatibus cum. Ut dicta soluta. Sunt sit assumenda dolor quia soluta animi repudiandae eos.',
      avatarPath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
    ),
  ];

  // Épisodes
  static const List<EpisodeModel> lokiSeason1Episodes = [
    EpisodeModel(
      id: '1',
      title: 'Glorious Purpose',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      duration: '51 min',
      description:
          'After stealing the Tesseract in "Avengers: Endgame," Loki is brought before the Time Variance Authority.',
      episodeNumber: 1,
      rating: 8.5,
    ),
    EpisodeModel(
      id: '2',
      title: 'The Variant',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      duration: '54 min',
      description:
          'Mobius puts Loki to work, but not everyone at the TVA is thrilled about the God of Mischief\'s presence.',
      episodeNumber: 2,
      rating: 8.3,
    ),
    EpisodeModel(
      id: '3',
      title: 'Lamentis',
      imagePath: 'assets/poster/4e4a3cc015940574343120069e05287e1c336646.jpg',
      duration: '43 min',
      description:
          'Loki finds out The Variant\'s hideout and comes face to face with them.',
      episodeNumber: 3,
      rating: 8.7,
    ),
    EpisodeModel(
      id: '4',
      title: 'The Nexus Event',
      imagePath: 'assets/poster/5ed7e48d341cf2480085a445b6486dbd9964e1c9.jpg',
      duration: '49 min',
      description:
          'Frayed nerves and paranoia infiltrate the TVA as Mobius and Hunter B-15 search for Loki and Sylvie.',
      episodeNumber: 4,
      rating: 8.9,
    ),
    EpisodeModel(
      id: '5',
      title: 'Journey Into Mystery',
      imagePath: 'assets/poster/7b34871fae5b7f45aa181d008eed6283e8596fa7.jpg',
      duration: '42 min',
      description:
          'Loki tries to escape The Void, a desolate realm where the TVA dumps its prisoners.',
      episodeNumber: 5,
      rating: 8.8,
    ),
    EpisodeModel(
      id: '6',
      title: 'For All Time. Always.',
      imagePath: 'assets/poster/a540bacb454d0bcc68204ff72c60210d17f9679f.jpg',
      duration: '45 min',
      description:
          'The season finale brings Loki and Sylvie to the end of their journey.',
      episodeNumber: 6,
      rating: 9.1,
    ),
  ];

  // Saisons
  static const List<SeasonModel> seasons = [
    SeasonModel(
      id: '1',
      title: 'Season 1',
      imagePath: 'assets/poster/304002ec328ad17a89f9c1df6cf8c782947ff218.jpg',
      episodes: '6 épisodes',
      year: '2021',
      rating: 8.6,
      description:
          'After stealing the Tesseract during the events of "Avengers: Endgame," an alternate version of Loki is brought to the mysterious Time Variance Authority.',
      episodesList: lokiSeason1Episodes,
    ),
    SeasonModel(
      id: '2',
      title: 'Season 2',
      imagePath: 'assets/poster/3fb13cb9a2be12d3257ebc49f50c0c193be46dec.jpg',
      episodes: '6 épisodes',
      year: '2023',
      rating: 8.8,
      description:
          'Loki finds himself in a battle for the soul of the Time Variance Authority. Along with Mobius, Hunter B-15, and a team of new and returning characters.',
      episodesList:
          lokiSeason1Episodes, // Pour l'exemple, on réutilise les mêmes épisodes
    ),
  ];
}
