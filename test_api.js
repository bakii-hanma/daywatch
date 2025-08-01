const http = require('http');

const url = 'http://192.168.137.1:5000/api/sonarr/series/recent';

console.log('🔍 Test de l\'API:', url);

http.get(url, (res) => {
  let data = '';
  console.log('📊 Status Code:', res.statusCode);
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    try {
      const json = JSON.parse(data);
      console.log('\n✅ Réponse JSON reçue:');
      console.log(JSON.stringify(json, null, 2));
      if (Array.isArray(json) && json.length > 0) {
        console.log(`\n📈 Nombre d\'éléments: ${json.length}`);
        console.log('🔍 Premier élément:');
        console.log(JSON.stringify(json[0], null, 2));
        console.log('\n🔑 Clés disponibles dans le premier élément:');
        Object.entries(json[0]).forEach(([key, value]) => {
          let type = Array.isArray(value) ? 'Array' : typeof value;
          let preview = '';
          if (typeof value === 'string' && value.length > 100) {
            preview = value.substring(0, 100) + '...';
          } else if (Array.isArray(value)) {
            preview = `Liste de ${value.length} éléments`;
          } else if (typeof value === 'object' && value !== null) {
            preview = `Objet avec ${Object.keys(value).length} clés`;
          } else {
            preview = value;
          }
          console.log(`  - ${key}: ${type} = ${preview}`);
        });
      }
    } catch (e) {
      console.error('❌ Erreur lors du parsing JSON:', e.message);
      console.log('📄 Contenu brut:', data);
    }
  });
}).on('error', (err) => {
  console.error('❌ Erreur de connexion:', err.message);
}); 