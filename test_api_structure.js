const https = require('https');
const http = require('http');

async function testAPI() {
  const url = 'http://192.168.137.1:5000/api/sonarr/series/recent';
  
  console.log('🔍 Test de l\'API:', url);
  
  return new Promise((resolve, reject) => {
    const client = url.startsWith('https') ? https : http;
    
    client.get(url, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        try {
          const jsonData = JSON.parse(data);
          console.log('✅ Réponse reçue');
          
          // Vérifier la structure de la réponse
          if (jsonData.data && Array.isArray(jsonData.data)) {
            console.log(`📊 ${jsonData.data.length} séries trouvées`);
            
            // Analyser la première série
            if (jsonData.data.length > 0) {
              const firstSeries = jsonData.data[0];
              console.log('\n🔍 Structure de la première série:');
              console.log('   - ID:', firstSeries.id);
              console.log('   - Title:', firstSeries.title);
              console.log('   - Clés disponibles:', Object.keys(firstSeries));
              
              // Chercher les informations de fichier
              if (firstSeries.seasons && Array.isArray(firstSeries.seasons)) {
                console.log(`   - ${firstSeries.seasons.length} saisons`);
                
                // Analyser la première saison
                if (firstSeries.seasons.length > 0) {
                  const firstSeason = firstSeries.seasons[0];
                  console.log('\n📺 Structure de la première saison:');
                  console.log('   - Season Number:', firstSeason.seasonNumber);
                  console.log('   - Clés disponibles:', Object.keys(firstSeason));
                  
                  // Chercher les épisodes
                  if (firstSeason.episodes && Array.isArray(firstSeason.episodes)) {
                    console.log(`   - ${firstSeason.episodes.length} épisodes`);
                    
                    // Analyser le premier épisode
                    if (firstSeason.episodes.length > 0) {
                      const firstEpisode = firstSeason.episodes[0];
                      console.log('\n🎬 Structure du premier épisode:');
                      console.log('   - Episode Number:', firstEpisode.episodeNumber);
                      console.log('   - Title:', firstEpisode.title);
                      console.log('   - hasFile:', firstEpisode.hasFile);
                      console.log('   - Clés disponibles:', Object.keys(firstEpisode));
                      
                      // Chercher les informations de fichier
                      if (firstEpisode.file) {
                        console.log('\n📁 Informations du fichier trouvées:');
                        console.log('   - file:', JSON.stringify(firstEpisode.file, null, 2));
                      }
                      
                      if (firstEpisode.episodeFile) {
                        console.log('\n📁 Informations episodeFile trouvées:');
                        console.log('   - episodeFile:', JSON.stringify(firstEpisode.episodeFile, null, 2));
                      }
                    }
                  }
                }
              }
            }
          } else {
            console.log('❌ Structure de réponse inattendue');
            console.log('Type de data:', typeof jsonData.data);
            if (Array.isArray(jsonData)) {
              console.log('Data est un tableau direct');
            }
          }
          
          resolve(jsonData);
        } catch (error) {
          console.error('❌ Erreur de parsing JSON:', error);
          reject(error);
        }
      });
    }).on('error', (error) => {
      console.error('❌ Erreur de requête:', error);
      reject(error);
    });
  });
}

testAPI().catch(console.error); 