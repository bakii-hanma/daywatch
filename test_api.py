import requests
import json

def test_api():
    url = "http://192.168.137.1:5000/api/sonarr/series/recent"
    
    try:
        print("🔍 Test de l'API:", url)
        response = requests.get(url, timeout=10)
        
        print(f"📊 Status Code: {response.status_code}")
        print(f"📋 Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            data = response.json()
            print("\n✅ Réponse JSON reçue:")
            print(json.dumps(data, indent=2, ensure_ascii=False))
            
            # Analyser la structure
            if isinstance(data, list) and len(data) > 0:
                print(f"\n📈 Nombre d'éléments: {len(data)}")
                print(f"🔍 Premier élément:")
                print(json.dumps(data[0], indent=2, ensure_ascii=False))
                
                # Analyser les clés du premier élément
                if isinstance(data[0], dict):
                    print(f"\n🔑 Clés disponibles dans le premier élément:")
                    for key, value in data[0].items():
                        print(f"  - {key}: {type(value).__name__} = {value}")
        else:
            print(f"❌ Erreur HTTP: {response.status_code}")
            print(f"📄 Contenu de la réponse: {response.text}")
            
    except requests.exceptions.ConnectionError:
        print("❌ Erreur de connexion: Impossible de se connecter au serveur")
    except requests.exceptions.Timeout:
        print("⏰ Timeout: La requête a pris trop de temps")
    except json.JSONDecodeError as e:
        print(f"❌ Erreur JSON: {e}")
        print(f"📄 Contenu brut: {response.text}")
    except Exception as e:
        print(f"❌ Erreur inattendue: {e}")

if __name__ == "__main__":
    test_api() 