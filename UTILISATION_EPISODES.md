# Utilisation des Épisodes avec Données Complètes

## Vue d'ensemble

Le système a été mis à jour pour récupérer et gérer les épisodes avec toutes leurs données, y compris :
- Informations de fichier (chemin, taille, qualité)
- Métadonnées TMDB (titre en français, description, notes)
- Galerie d'images
- URLs de streaming et téléchargement

## Structure des Données d'Épisode

Chaque épisode contient maintenant les informations suivantes :

```json
{
  "id": 26,
  "episodeNumber": 1,
  "title": "Take Me Home",
  "overview": "Determined to complete her newest armored suit...",
  "airDate": "2025-06-24",
  "runtime": 41,
  "hasFile": true,
  "monitored": true,
  "seasonNumber": 1,
  "ratings": {
    "value": 0
  },
  "file": {
    "id": 14,
    "fileName": "Ironheart - S01E01 - Take Me Home WEBRip-480p.mp4",
    "fullPath": "/medias/shows/Ironheart/Season 1/Ironheart - S01E01 - Take Me Home WEBRip-480p.mp4",
    "size": 279897258,
    "sizeGB": 0.26,
    "quality": {
      "name": "WEBRip-480p",
      "resolution": 480
    },
    "downloadUrl": "http://185.139.230.11:8989/api/v3/episodefile/14/download",
    "streamUrl": "http://185.139.230.11:8989/api/v3/episodefile/14/download"
  },
  "tmdbData": {
    "tmdbId": 2910190,
    "name": "Retour au bercail",
    "overview": "Déterminée à finir sa nouvelle armure...",
    "voteAverage": 4.9,
    "voteCount": 29,
    "runtime": 44
  },
  "gallery": {
    "stills": [
      {
        "filePath": "https://image.tmdb.org/t/p/w500/aRamHYwekA5oOUsf97hZdhQokK3.jpg",
        "url": "https://image.tmdb.org/t/p/w500/aRamHYwekA5oOUsf97hZdhQokK3.jpg",
        "thumbUrl": "https://image.tmdb.org/t/p/w780/aRamHYwekA5oOUsf97hZdhQokK3.jpg"
      }
    ]
  }
}
```

## Méthodes de Récupération

### 1. Récupérer une série avec tous ses épisodes

```dart
// Récupère la série avec tous ses épisodes inclus
final series = await SeriesService.getSeriesWithEpisodes('series_id');

if (series != null) {
  // Accéder aux épisodes par saison
  final season1Episodes = series.getEpisodesForSeason(1);
  final season2Episodes = series.getEpisodesForSeason(2);
  
  print('Série: ${series.title}');
  print('Saison 1: ${season1Episodes.length} épisodes');
  print('Saison 2: ${season2Episodes.length} épisodes');
}
```

### 2. Récupérer un épisode spécifique

```dart
// Récupère un épisode spécifique avec toutes ses données
final episode = await SeriesService.getEpisodeById(
  seriesId: 'series_id',
  seasonNumber: 1,
  episodeNumber: 1,
);

if (episode != null) {
  print('Épisode: ${episode.title}');
  print('Fichier: ${episode.file?.fileName}');
  print('Qualité: ${episode.getQuality()}');
  print('Taille: ${episode.getFileSize()}');
  print('URL de streaming: ${episode.getStreamUrl()}');
  print('Chemin du fichier: ${episode.getFilePath()}');
}
```

### 3. Utilisation dans les écrans

#### Écran de détails de série

```dart
class SeriesDetailScreen extends StatefulWidget {
  final String seriesId;
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SeriesApiModel?>(
      future: SeriesService.getSeriesWithEpisodes(seriesId),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final series = snapshot.data!;
          
          return Scaffold(
            body: Column(
              children: [
                // Informations de la série
                SeriesInfoWidget(series: series),
                
                // Liste des saisons avec épisodes
                Expanded(
                  child: ListView.builder(
                    itemCount: series.seasonInfo.seasons.length,
                    itemBuilder: (context, index) {
                      final season = series.seasonInfo.seasons[index];
                      final episodes = series.getEpisodesForSeason(season.number);
                      
                      return SeasonCard(
                        season: season,
                        episodes: episodes,
                        onEpisodeTap: (episode) {
                          // Navigation vers l'épisode
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EpisodeDetailScreen(
                                series: series,
                                episode: episode,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }
        
        return LoadingWidget();
      },
    );
  }
}
```

#### Écran de détails d'épisode

```dart
class EpisodeDetailScreen extends StatelessWidget {
  final SeriesApiModel series;
  final EpisodeApiModel episode;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${series.title} - S${episode.seasonNumber}E${episode.episodeNumber}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image de l'épisode
            if (episode.stillPath != null)
              Image.network(
                episode.stillPath!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre de l'épisode
                  Text(
                    episode.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Informations de l'épisode
                  Row(
                    children: [
                      Text('Saison ${episode.seasonNumber}'),
                      SizedBox(width: 16),
                      Text('Épisode ${episode.episodeNumber}'),
                      SizedBox(width: 16),
                      Text('${episode.runtime} min'),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Description
                  Text(
                    episode.overview,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Informations du fichier
                  if (episode.hasFile && episode.file != null) ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informations du fichier',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Text('Nom: ${episode.file!.fileName}'),
                            Text('Qualité: ${episode.getQuality()}'),
                            Text('Taille: ${episode.getFileSize()}'),
                            Text('Chemin: ${episode.file!.fullPath}'),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Boutons d'action
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Lancer la lecture
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(
                                    videoUrl: episode.getStreamUrl()!,
                                    title: episode.title,
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.play_arrow),
                            label: Text('Lire'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Télécharger l'épisode
                              // Implémenter la logique de téléchargement
                            },
                            icon: Icon(Icons.download),
                            label: Text('Télécharger'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Épisode non disponible',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Méthodes Utilitaires

### EpisodeApiModel

- `getStreamUrl()`: Retourne l'URL de streaming
- `getFilePath()`: Retourne le chemin complet du fichier
- `isAvailable()`: Vérifie si l'épisode est disponible
- `getQuality()`: Retourne la qualité de l'épisode
- `getFileSize()`: Retourne la taille du fichier formatée
- `toEpisodeModel()`: Convertit vers le modèle EpisodeModel

### SeriesApiModel

- `getEpisodesForSeason(int seasonNumber)`: Récupère les épisodes d'une saison
- `hasEpisodesForSeason(int seasonNumber)`: Vérifie si une saison a des épisodes
- `withEpisodesForSeason(int seasonNumber, List<EpisodeApiModel> episodes)`: Ajoute des épisodes à une saison

## Avantages

1. **Données complètes**: Toutes les informations de l'épisode sont disponibles
2. **Performance**: Les épisodes sont récupérés avec la série en une seule requête
3. **Flexibilité**: Possibilité de récupérer des épisodes individuels ou par saison
4. **Compatibilité**: Conversion automatique vers les modèles existants
5. **Gestion des erreurs**: Retry automatique et gestion des timeouts

## Notes Importantes

- Les données TMDB sont prioritaires pour les titres et descriptions en français
- Les URLs de streaming et téléchargement sont automatiquement extraites
- La qualité et la taille des fichiers sont formatées pour l'affichage
- Les images de la galerie sont disponibles via `episode.gallery.stills` 