import urllib.request
import json
import ssl

def test_api():
    url = "http://192.168.137.1:5000/api/sonarr/series/recent"
    
    try:
        print("🔍 Test de l'API:", url)
        print("⏳ Tentative de connexion...")
        
        # Créer un contexte SSL qui ignore les certificats (pour le développement)
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        
        # Créer la requête avec un timeout court
        req = urllib.request.Request(url)
        req.add_header('Content-Type', 'application/json')
        req.add_header('User-Agent', 'Mozilla/5.0 (Android; Mobile) AppleWebKit/537.36')
        
        # Effectuer la requête avec un timeout de 5 secondes
        with urllib.request.urlopen(req, context=context, timeout=5) as response:
            print(f"✅ Connexion réussie!")
            print(f"📊 Status Code: {response.status}")
            print(f"📋 Content-Type: {response.headers.get('Content-Type', 'Non spécifié')}")
            
            # Lire la réponse
            data = response.read()
            print(f"📄 Taille de la réponse: {len(data)} bytes")
            
            # Parser le JSON
            json_data = json.loads(data.decode('utf-8'))
            print("\n✅ Réponse JSON reçue:")
            print(json.dumps(json_data, indent=2, ensure_ascii=False))
            
            # Analyser la structure
            if isinstance(json_data, list) and len(json_data) > 0:
                print(f"\n📈 Nombre d'éléments: {len(json_data)}")
                print(f"🔍 Premier élément:")
                print(json.dumps(json_data[0], indent=2, ensure_ascii=False))
                
                # Analyser les clés du premier élément
                if isinstance(json_data[0], dict):
                    print(f"\n🔑 Clés disponibles dans le premier élément:")
                    for key, value in json_data[0].items():
                        value_type = type(value).__name__
                        if isinstance(value, str) and len(value) > 100:
                            value_preview = value[:100] + "..."
                        elif isinstance(value, list):
                            value_preview = f"Liste de {len(value)} éléments"
                        elif isinstance(value, dict):
                            value_preview = f"Dictionnaire avec {len(value)} clés"
                        else:
                            value_preview = str(value)
                        print(f"  - {key}: {value_type} = {value_preview}")
            elif isinstance(json_data, dict):
                print(f"\n🔑 Clés disponibles dans la réponse:")
                for key, value in json_data.items():
                    value_type = type(value).__name__
                    print(f"  - {key}: {value_type}")
                    
    except urllib.error.URLError as e:
        print(f"❌ Erreur URL: {e}")
        if hasattr(e, 'reason'):
            print(f"   Raison: {e.reason}")
    except urllib.error.HTTPError as e:
        print(f"❌ Erreur HTTP: {e.code} - {e.reason}")
        try:
            error_content = e.read().decode('utf-8')
            print(f"📄 Contenu de la réponse: {error_content}")
        except:
            print("📄 Impossible de lire le contenu de l'erreur")
    except json.JSONDecodeError as e:
        print(f"❌ Erreur JSON: {e}")
        try:
            print(f"📄 Contenu brut: {data.decode('utf-8')}")
        except:
            print("📄 Impossible de lire le contenu brut")
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")

if __name__ == "__main__":
    test_api() 