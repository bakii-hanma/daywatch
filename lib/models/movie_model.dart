class MovieModel {
  final String id;
  final String title;
  final String imagePath;
  final String genre;
  final String duration;
  final String releaseDate;
  final double rating;
  final String description;

  const MovieModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.genre,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    this.description = '',
  });
}

class SeriesModel {
  final String id;
  final String title;
  final String imagePath;
  final String genre;
  final String seasons;
  final String years;
  final double rating;
  final String description;

  const SeriesModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.genre,
    required this.seasons,
    required this.years,
    required this.rating,
    this.description = '',
  });
}

class ActorModel {
  final String id;
  final String name;
  final String imagePath;
  final String bio;

  const ActorModel({
    required this.id,
    required this.name,
    required this.imagePath,
    this.bio = '',
  });
}

class TrailerModel {
  final String id;
  final String title;
  final String imagePath;
  final String duration;
  final String videoUrl;

  const TrailerModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.duration,
    this.videoUrl = '',
  });
}

class BoxOfficeModel {
  final String id;
  final String title;
  final String imagePath;
  final String earnings;
  final String duration;
  final String releaseDate;
  final double rating;
  final int rank;

  const BoxOfficeModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.earnings,
    required this.duration,
    required this.releaseDate,
    required this.rating,
    required this.rank,
  });
}

class PlatformModel {
  final String id;
  final String name;
  final String imagePath;

  const PlatformModel({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

class EpisodeModel {
  final String id;
  final String title;
  final String imagePath;
  final String duration;
  final String description;
  final int episodeNumber;
  final double rating;

  const EpisodeModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.duration,
    required this.description,
    required this.episodeNumber,
    required this.rating,
  });
}

class SeasonModel {
  final String id;
  final String title;
  final String imagePath;
  final String episodes;
  final String year;
  final double rating;
  final String description;
  final List<EpisodeModel> episodesList;

  const SeasonModel({
    required this.id,
    required this.title,
    required this.imagePath,
    required this.episodes,
    required this.year,
    required this.rating,
    required this.description,
    required this.episodesList,
  });
}
