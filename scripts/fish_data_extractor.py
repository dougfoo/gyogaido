#!/usr/bin/env python3
"""
Fish Data Extractor for Gyo Gai Do App

This script extracts comprehensive fish data from multiple sources and downloads
high-quality images for the Flutter fish identification app.

Sources:
- FishBase.org API for scientific data
- Wikipedia for cultural information
- Various marine biology sites for images

Usage:
    python fish_data_extractor.py
"""

import requests
import json
import os
import time
import urllib.parse
from dataclasses import dataclass, asdict
from typing import List, Dict, Optional
import hashlib
from pathlib import Path
import re
from urllib.parse import urljoin, urlparse
import base64

@dataclass
class FishData:
    """Data class matching the Flutter Fish model structure"""
    id: str
    unique_name: str
    description: str
    common_aliases: List[str]
    scientific_name: str
    japanese_name_romaji: str
    japanese_name_kanji: str
    lifespan: str
    size: str
    weight: str
    habitats: List[str]
    ways_to_eat: List[str]
    sushi_images: List[str]
    wild_images: List[str]
    habitat_map_image: str

class FishDataExtractor:
    """Main class for extracting fish data and images"""
    
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent
        self.assets_dir = self.base_dir / "assets"
        self.images_dir = self.assets_dir / "images"
        self.data_dir = self.assets_dir / "data"
        
        # Create directory structure
        self.setup_directories()
        
        # API endpoints and headers
        self.fishbase_api = "https://fishbase.ropensci.org"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Gyo-Gai-Do-App/1.0 (Educational Research)'
        })

    def setup_directories(self):
        """Create the necessary directory structure for assets"""
        directories = [
            self.images_dir / "natural",
            self.images_dir / "scientific", 
            self.images_dir / "sushi",
            self.images_dir / "maps",
            self.data_dir
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            
        print(f"Created asset directories in: {self.assets_dir}")

    def get_top_20_fish_species(self) -> List[Dict]:
        """Define the top 20 fish species for sushi/Japanese cuisine"""
        return [
            {"common_name": "Bluefin Tuna", "scientific_name": "Thunnus thynnus", "japanese_romaji": "Kuro-maguro", "japanese_kanji": "黒鮪"},
            {"common_name": "Yellowfin Tuna", "scientific_name": "Thunnus albacares", "japanese_romaji": "Kihada", "japanese_kanji": "黄肌"},
            {"common_name": "Atlantic Salmon", "scientific_name": "Salmo salar", "japanese_romaji": "Sake", "japanese_kanji": "鮭"},
            {"common_name": "Japanese Amberjack", "scientific_name": "Seriola quinqueradiata", "japanese_romaji": "Hamachi", "japanese_kanji": "鰤"},
            {"common_name": "Red Sea Bream", "scientific_name": "Pagrus major", "japanese_romaji": "Madai", "japanese_kanji": "真鯛"},
            {"common_name": "Atlantic Mackerel", "scientific_name": "Scomber scombrus", "japanese_romaji": "Saba", "japanese_kanji": "鯖"},
            {"common_name": "Horse Mackerel", "scientific_name": "Trachurus japonicus", "japanese_romaji": "Aji", "japanese_kanji": "鯵"},
            {"common_name": "Japanese Sardine", "scientific_name": "Sardinops melanostictus", "japanese_romaji": "Iwashi", "japanese_kanji": "鰯"},
            {"common_name": "Japanese Sea Bass", "scientific_name": "Lateolabrax japonicus", "japanese_romaji": "Suzuki", "japanese_kanji": "鱸"},
            {"common_name": "Olive Flounder", "scientific_name": "Paralichthys olivaceus", "japanese_romaji": "Hirame", "japanese_kanji": "鮃"},
            {"common_name": "Red Snapper", "scientific_name": "Lutjanus campechanus", "japanese_romaji": "Tai", "japanese_kanji": "鯛"},
            {"common_name": "Japanese Eel", "scientific_name": "Anguilla japonica", "japanese_romaji": "Unagi", "japanese_kanji": "鰻"},
            {"common_name": "Conger Eel", "scientific_name": "Conger myriaster", "japanese_romaji": "Anago", "japanese_kanji": "穴子"},
            {"common_name": "Japanese Flying Squid", "scientific_name": "Todarodes pacificus", "japanese_romaji": "Ika", "japanese_kanji": "烏賊"},
            {"common_name": "Giant Pacific Octopus", "scientific_name": "Enteroctopus dofleini", "japanese_romaji": "Tako", "japanese_kanji": "蛸"},
            {"common_name": "Kuruma Prawn", "scientific_name": "Penaeus japonicus", "japanese_romaji": "Ebi", "japanese_kanji": "海老"},
            {"common_name": "Japanese Scallop", "scientific_name": "Patinopecten yessoensis", "japanese_romaji": "Hotate", "japanese_kanji": "帆立"},
            {"common_name": "Sea Urchin", "scientific_name": "Strongylocentrotus nudus", "japanese_romaji": "Uni", "japanese_kanji": "雲丹"},
            {"common_name": "Greater Amberjack", "scientific_name": "Seriola dumerili", "japanese_romaji": "Kanpachi", "japanese_kanji": "間八"},
            {"common_name": "Pacific Saury", "scientific_name": "Cololabis saira", "japanese_romaji": "Sanma", "japanese_kanji": "秋刀魚"}
        ]

    def fetch_fishbase_data(self, scientific_name: str) -> Optional[Dict]:
        """Fetch data from FishBase API"""
        try:
            # FishBase species endpoint
            url = f"{self.fishbase_api}/species"
            params = {"species": scientific_name}
            
            response = self.session.get(url, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data and len(data) > 0:
                    return data[0]
            
            print(f"No FishBase data found for {scientific_name}")
            return None
            
        except Exception as e:
            print(f"Error fetching FishBase data for {scientific_name}: {e}")
            return None

    def fetch_wikipedia_data(self, common_name: str) -> Optional[Dict]:
        """Fetch supplementary data from Wikipedia API"""
        try:
            # Wikipedia API endpoint
            url = "https://en.wikipedia.org/api/rest_v1/page/summary/"
            encoded_name = urllib.parse.quote(common_name)
            
            response = self.session.get(f"{url}{encoded_name}", timeout=10)
            if response.status_code == 200:
                return response.json()
            
            return None
            
        except Exception as e:
            print(f"Error fetching Wikipedia data for {common_name}: {e}")
            return None

    def generate_fish_id(self, common_name: str) -> str:
        """Generate a consistent ID from the common name"""
        return common_name.lower().replace(" ", "_").replace("-", "_")

    def extract_fish_data(self, species_info: Dict) -> FishData:
        """Extract and combine data from multiple sources into FishData object"""
        common_name = species_info["common_name"]
        scientific_name = species_info["scientific_name"]
        japanese_romaji = species_info["japanese_romaji"]
        japanese_kanji = species_info["japanese_kanji"]
        
        fish_id = self.generate_fish_id(common_name)
        
        print(f"Extracting data for: {common_name}")
        
        # Fetch data from sources
        fishbase_data = self.fetch_fishbase_data(scientific_name)
        wikipedia_data = self.fetch_wikipedia_data(common_name)
        
        # Build description
        description = self.build_description(common_name, fishbase_data, wikipedia_data)
        
        # Build comprehensive fish data
        fish_data = FishData(
            id=fish_id,
            unique_name=common_name,
            description=description,
            common_aliases=self.get_aliases(common_name, japanese_romaji),
            scientific_name=scientific_name,
            japanese_name_romaji=japanese_romaji,
            japanese_name_kanji=japanese_kanji,
            lifespan=self.extract_lifespan(fishbase_data),
            size=self.extract_size(fishbase_data),
            weight=self.extract_weight(fishbase_data),
            habitats=self.extract_habitats(fishbase_data),
            ways_to_eat=self.get_ways_to_eat(common_name),
            sushi_images=self.get_image_paths(fish_id, "sushi"),
            wild_images=self.get_image_paths(fish_id, "natural"),
            habitat_map_image=f"assets/images/maps/{fish_id}_habitat.jpg"
        )
        
        # Small delay to be respectful to APIs
        time.sleep(1)
        
        return fish_data

    def build_description(self, common_name: str, fishbase_data: Optional[Dict], wikipedia_data: Optional[Dict]) -> str:
        """Build a comprehensive description from multiple sources"""
        descriptions = []
        
        if wikipedia_data and 'extract' in wikipedia_data:
            descriptions.append(wikipedia_data['extract'])
        
        if fishbase_data and 'Comments' in fishbase_data:
            descriptions.append(fishbase_data['Comments'])
            
        # Fallback descriptions for common sushi fish
        fallback_descriptions = {
            "Bluefin Tuna": "Large, powerful fish prized for its rich, fatty flesh. Highly valued in sushi cuisine for its complex flavor profile ranging from lean akami to fatty otoro.",
            "Atlantic Salmon": "Popular fish with distinctive pink flesh. Commonly farm-raised and wild-caught, known for its rich flavor and high omega-3 content.",
            "Japanese Amberjack": "Premium fish with buttery texture and clean taste. Young yellowtail (hamachi) is especially prized for sushi and sashimi."
        }
        
        if not descriptions and common_name in fallback_descriptions:
            descriptions.append(fallback_descriptions[common_name])
        
        if not descriptions:
            descriptions.append(f"A species of fish commonly used in Japanese cuisine, particularly sushi and sashimi preparation.")
        
        return descriptions[0][:200] + "..." if len(descriptions[0]) > 200 else descriptions[0]

    def get_aliases(self, common_name: str, japanese_romaji: str) -> List[str]:
        """Get common aliases for the fish"""
        aliases = [japanese_romaji]
        
        # Add common variations
        alias_map = {
            "Bluefin Tuna": ["Maguro", "Hon-maguro", "Kuro-maguro"],
            "Yellowfin Tuna": ["Ahi", "Kihada"],
            "Atlantic Salmon": ["Sake", "Norwegian Salmon"],
            "Japanese Amberjack": ["Hamachi", "Yellowtail", "Buri"],
            "Red Sea Bream": ["Tai", "Madai", "Sea Bream"]
        }
        
        if common_name in alias_map:
            aliases.extend(alias_map[common_name])
        
        return list(set(aliases))  # Remove duplicates

    def extract_lifespan(self, fishbase_data: Optional[Dict]) -> str:
        """Extract lifespan information"""
        if fishbase_data and 'LongevityWild' in fishbase_data:
            years = fishbase_data['LongevityWild']
            return f"{years} years"
        return "5-15 years"  # Default fallback

    def extract_size(self, fishbase_data: Optional[Dict]) -> str:
        """Extract size information"""
        if fishbase_data and 'Length' in fishbase_data:
            cm = fishbase_data['Length']
            inches = round(cm * 0.393701, 1)
            return f"{inches} in ({cm} cm)"
        return "12-24 in (30-60 cm)"  # Default fallback

    def extract_weight(self, fishbase_data: Optional[Dict]) -> str:
        """Extract weight information"""
        if fishbase_data and 'Weight' in fishbase_data:
            kg = fishbase_data['Weight']
            lbs = round(kg * 2.20462, 1)
            return f"{lbs} lbs ({kg} kg)"
        return "2-10 lbs (1-4.5 kg)"  # Default fallback

    def extract_habitats(self, fishbase_data: Optional[Dict]) -> List[str]:
        """Extract habitat information"""
        default_habitats = ["Pacific Ocean", "Atlantic Ocean", "Coastal Waters"]
        
        if fishbase_data and 'FamCode' in fishbase_data:
            # This would need more sophisticated mapping
            # For now, return sensible defaults
            return default_habitats[:2]
        
        return default_habitats[:2]

    def get_ways_to_eat(self, common_name: str) -> List[str]:
        """Get common ways to prepare/eat the fish"""
        preparation_map = {
            "Bluefin Tuna": ["Sashimi", "Nigiri", "Seared", "Tataki"],
            "Atlantic Salmon": ["Sashimi", "Nigiri", "Grilled", "Smoked"],
            "Japanese Amberjack": ["Sashimi", "Nigiri", "Grilled", "Teriyaki"],
            "Red Sea Bream": ["Sashimi", "Nigiri", "Steamed", "Grilled"],
            "Atlantic Mackerel": ["Sashimi", "Nigiri", "Grilled", "Pickled"],
            "Japanese Eel": ["Unagi", "Kabayaki", "Grilled", "Rice Bowl"]
        }
        
        return preparation_map.get(common_name, ["Sashimi", "Nigiri", "Grilled", "Steamed"])

    def get_image_paths(self, fish_id: str, image_type: str) -> List[str]:
        """Generate image paths for the fish"""
        if image_type == "sushi":
            return [
                f"assets/images/sushi/{fish_id}_nigiri.jpg",
                f"assets/images/sushi/{fish_id}_sashimi.jpg"
            ]
        elif image_type == "natural":
            return [
                f"assets/images/natural/{fish_id}_natural_1.jpg",
                f"assets/images/natural/{fish_id}_natural_2.jpg"
            ]
        return []

    def download_free_images(self, fish_list: List[FishData]):
        """Download images from multiple free, open sources without API keys"""
        print("Downloading images from multiple free sources...")
        
        for fish in fish_list:
            fish_id = fish.id
            common_name = fish.unique_name
            scientific_name = fish.scientific_name
            japanese_romaji = fish.japanese_name_romaji
            
            print(f"Downloading images for: {common_name}")
            
            # Download different types of images from various sources
            success_counts = {
                'natural': 0,
                'scientific': 0,
                'maps': 0,
                'sushi': 0
            }
            
            # Try multiple sources for each image type
            success_counts['natural'] += self.download_natural_images(fish_id, common_name, scientific_name)
            success_counts['scientific'] += self.download_scientific_diagrams(fish_id, common_name, scientific_name)
            success_counts['maps'] += self.download_habitat_maps(fish_id, common_name, scientific_name)
            success_counts['sushi'] += self.download_sushi_images(fish_id, common_name, japanese_romaji)
            
            # Create placeholders only for missing images
            self.create_missing_placeholders(fish_id, common_name, scientific_name, success_counts)
            
            # Small delay to be respectful to all sources
            time.sleep(2)
                        
        print(f"Downloaded images for {len(fish_list)} fish species")

    def download_natural_images(self, fish_id: str, common_name: str, scientific_name: str) -> int:
        """Download natural/wild fish images from multiple sources"""
        images_downloaded = 0
        target_count = 2
        
        # Try different sources for natural fish photos
        sources = [
            lambda: self.download_wikimedia_images(fish_id, common_name, scientific_name, 'natural'),
            lambda: self.download_fishbase_images(fish_id, common_name, scientific_name, 'natural'),
            lambda: self.download_gbif_images(fish_id, scientific_name, 'natural'),
            lambda: self.download_inaturalist_images(fish_id, scientific_name, 'natural')
        ]
        
        for source_func in sources:
            if images_downloaded >= target_count:
                break
            try:
                images_downloaded += source_func()
                time.sleep(1)  # Rate limiting
            except Exception as e:
                print(f"  [WARNING] Source failed: {e}")
                continue
        
        print(f"  [INFO] Downloaded {images_downloaded}/{target_count} natural images")
        return images_downloaded

    def download_scientific_diagrams(self, fish_id: str, common_name: str, scientific_name: str) -> int:
        """Download scientific diagrams and anatomy illustrations"""
        images_downloaded = 0
        target_count = 1
        
        # Try different sources for scientific diagrams
        sources = [
            lambda: self.download_fishbase_diagrams(fish_id, scientific_name),
            lambda: self.download_wikimedia_images(fish_id, f"{scientific_name} anatomy", scientific_name, 'scientific'),
            lambda: self.download_wikimedia_images(fish_id, f"{common_name} diagram", scientific_name, 'scientific'),
            lambda: self.download_fao_diagrams(fish_id, scientific_name)
        ]
        
        for source_func in sources:
            if images_downloaded >= target_count:
                break
            try:
                images_downloaded += source_func()
                time.sleep(1)
            except Exception as e:
                print(f"  [WARNING] Scientific diagram source failed: {e}")
                continue
        
        print(f"  [INFO] Downloaded {images_downloaded}/{target_count} scientific diagrams")
        return images_downloaded

    def download_habitat_maps(self, fish_id: str, common_name: str, scientific_name: str) -> int:
        """Download habitat distribution maps"""
        images_downloaded = 0
        target_count = 1
        
        # Try different sources for habitat maps
        sources = [
            lambda: self.download_fishbase_maps(fish_id, scientific_name),
            lambda: self.download_gbif_maps(fish_id, scientific_name),
            lambda: self.download_aquamaps_data(fish_id, scientific_name),
            lambda: self.download_wikimedia_images(fish_id, f"{scientific_name} distribution", scientific_name, 'maps')
        ]
        
        for source_func in sources:
            if images_downloaded >= target_count:
                break
            try:
                images_downloaded += source_func()
                time.sleep(1)
            except Exception as e:
                print(f"  [WARNING] Habitat map source failed: {e}")
                continue
        
        print(f"  [INFO] Downloaded {images_downloaded}/{target_count} habitat maps")
        return images_downloaded

    def download_sushi_images(self, fish_id: str, common_name: str, japanese_romaji: str) -> int:
        """Download sushi preparation images (nigiri and sashimi)"""
        images_downloaded = 0
        target_count = 2  # nigiri + sashimi
        
        # Try different sources for sushi images
        sources = [
            lambda: self.download_wikimedia_sushi_images(fish_id, common_name, japanese_romaji),
            lambda: self.download_unsplash_sushi_images(fish_id, common_name, japanese_romaji),
            lambda: self.download_pexels_sushi_images(fish_id, common_name, japanese_romaji)
        ]
        
        for source_func in sources:
            if images_downloaded >= target_count:
                break
            try:
                images_downloaded += source_func()
                time.sleep(1)
            except Exception as e:
                print(f"  [WARNING] Sushi image source failed: {e}")
                continue
        
        print(f"  [INFO] Downloaded {images_downloaded}/{target_count} sushi images")
        return images_downloaded

    def download_wikimedia_images(self, fish_id: str, search_term: str, scientific_name: str, image_type: str = 'natural') -> int:
        """Download images from Wikimedia Commons (free license)"""
        try:
            wiki_api = "https://commons.wikimedia.org/w/api.php"
            images_downloaded = 0
            target_count = 2 if image_type == 'natural' else 1
            
            # Enhanced search terms based on image type
            search_queries = self.get_wikimedia_search_terms(search_term, scientific_name, image_type)
            
            for query in search_queries:
                if images_downloaded >= target_count:
                    break
                    
                params = {
                    'action': 'query',
                    'format': 'json',
                    'list': 'search',
                    'srsearch': f'filetype:bitmap {query}',
                    'srnamespace': 6,  # File namespace
                    'srlimit': 5
                }
                
                try:
                    response = self.session.get(wiki_api, params=params, timeout=10)
                    if response.status_code == 200:
                        data = response.json()
                        
                        if 'query' in data and 'search' in data['query']:
                            for result in data['query']['search']:
                                if images_downloaded >= target_count:
                                    break
                                    
                                file_title = result['title']
                                image_url = self.get_wikimedia_image_url(file_title)
                                
                                if image_url:
                                    filename = self.get_filename(fish_id, image_type, images_downloaded)
                                    folder = self.get_image_folder(image_type)
                                    filepath = self.images_dir / folder / filename
                                    
                                    if self.download_image_from_url(image_url, filepath):
                                        print(f"  [OK] Downloaded {filename} from Wikimedia")
                                        images_downloaded += 1
                                        time.sleep(2)  # Be respectful to Wikimedia
                                
                except Exception as e:
                    print(f"  [WARNING] Wikimedia search error: {e}")
                    continue
            
            return images_downloaded
                    
        except Exception as e:
            print(f"  [ERROR] Error downloading Wikimedia images: {e}")
            return 0

    def get_wikimedia_image_url(self, file_title: str) -> Optional[str]:
        """Get direct image URL from Wikimedia Commons file title"""
        try:
            api_url = "https://commons.wikimedia.org/w/api.php"
            params = {
                'action': 'query',
                'format': 'json',
                'titles': file_title,
                'prop': 'imageinfo',
                'iiprop': 'url',
                'iiurlwidth': 800  # Resize to reasonable size
            }
            
            response = self.session.get(api_url, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                pages = data.get('query', {}).get('pages', {})
                
                for page in pages.values():
                    if 'imageinfo' in page:
                        return page['imageinfo'][0].get('thumburl') or page['imageinfo'][0].get('url')
            
            return None
            
        except Exception as e:
            print(f"  [ERROR] Error getting Wikimedia image URL: {e}")
            return None

    def download_image_from_url(self, url: str, filepath: Path) -> bool:
        """Download an image from URL to filepath"""
        try:
            headers = {
                'User-Agent': 'Gyo-Gai-Do-Educational-App/1.0'
            }
            response = self.session.get(url, headers=headers, timeout=30, stream=True)
            
            if response.status_code == 200:
                # Check if it's actually an image
                content_type = response.headers.get('content-type', '')
                if 'image' in content_type:
                    with open(filepath, 'wb') as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            if chunk:
                                f.write(chunk)
                    return True
            return False
            
        except Exception as e:
            print(f"  [ERROR] Download error: {e}")
            return False

    # Helper functions for image management
    def get_wikimedia_search_terms(self, search_term: str, scientific_name: str, image_type: str) -> List[str]:
        """Generate appropriate search terms for different image types"""
        base_terms = [search_term, scientific_name]
        
        if image_type == 'natural':
            return [f"{term}" for term in base_terms] + [f"{term} fish" for term in base_terms]
        elif image_type == 'scientific':
            return [f"{search_term} anatomy", f"{search_term} diagram", f"{search_term} illustration",
                    f"{scientific_name} anatomy", f"{scientific_name} diagram", f"{scientific_name} illustration"]
        elif image_type == 'maps':
            return [f"{search_term} distribution", f"{search_term} habitat", f"{search_term} range map",
                    f"{scientific_name} distribution", f"{scientific_name} habitat", f"{scientific_name} range map"]
        elif image_type == 'sushi':
            return [f"{search_term} sushi", f"{search_term} sashimi", f"{search_term} nigiri",
                    f"{scientific_name} sushi", f"{scientific_name} sashimi", f"{scientific_name} nigiri"]
        
        return base_terms

    def get_filename(self, fish_id: str, image_type: str, index: int) -> str:
        """Generate appropriate filename based on image type and index"""
        if image_type == 'natural':
            return f"{fish_id}_natural_{index + 1}.jpg"
        elif image_type == 'scientific':
            return f"{fish_id}_diagram.jpg"
        elif image_type == 'maps':
            return f"{fish_id}_habitat.jpg"
        elif image_type == 'sushi':
            suffix = 'nigiri' if index == 0 else 'sashimi'
            return f"{fish_id}_{suffix}.jpg"
        return f"{fish_id}_{image_type}_{index + 1}.jpg"

    def get_image_folder(self, image_type: str) -> str:
        """Get the folder name for different image types"""
        folder_map = {
            'natural': 'natural',
            'scientific': 'scientific',
            'maps': 'maps',
            'sushi': 'sushi'
        }
        return folder_map.get(image_type, 'natural')

    # Additional source functions
    def download_fishbase_images(self, fish_id: str, common_name: str, scientific_name: str, image_type: str) -> int:
        """Download images from FishBase"""
        try:
            # FishBase image search
            search_url = f"https://www.fishbase.se/photos/PicturesSummary.php?resultPage=1&what=species&ID={scientific_name}"
            
            response = self.session.get(search_url, timeout=10)
            if response.status_code == 200:
                # Parse HTML to find image URLs (simplified - would need proper HTML parsing)
                content = response.text
                image_urls = re.findall(r'https://www\.fishbase\.se/photos/.*?\.jpg', content)
                
                images_downloaded = 0
                target = 2 if image_type == 'natural' else 1
                
                for url in image_urls[:target]:
                    filename = self.get_filename(fish_id, image_type, images_downloaded)
                    folder = self.get_image_folder(image_type)
                    filepath = self.images_dir / folder / filename
                    
                    if self.download_image_from_url(url, filepath):
                        print(f"  [OK] Downloaded {filename} from FishBase")
                        images_downloaded += 1
                        time.sleep(1)
                
                return images_downloaded
            return 0
        except Exception as e:
            print(f"  [WARNING] FishBase download failed: {e}")
            return 0

    def download_gbif_images(self, fish_id: str, scientific_name: str, image_type: str) -> int:
        """Download images from GBIF (Global Biodiversity Information Facility)"""
        try:
            # GBIF API for species images
            gbif_api = "https://api.gbif.org/v1/species/search"
            params = {'q': scientific_name, 'limit': 1}
            
            response = self.session.get(gbif_api, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data.get('results'):
                    species_key = data['results'][0].get('key')
                    
                    # Get occurrence images
                    occurrence_api = f"https://api.gbif.org/v1/occurrence/search"
                    params = {'taxonKey': species_key, 'mediaType': 'StillImage', 'limit': 5}
                    
                    response = self.session.get(occurrence_api, params=params, timeout=10)
                    if response.status_code == 200:
                        data = response.json()
                        images_downloaded = 0
                        target = 2 if image_type == 'natural' else 1
                        
                        for occurrence in data.get('results', [])[:target]:
                            media = occurrence.get('media', [])
                            for media_item in media:
                                if media_item.get('type') == 'StillImage':
                                    url = media_item.get('identifier')
                                    if url:
                                        filename = self.get_filename(fish_id, image_type, images_downloaded)
                                        folder = self.get_image_folder(image_type)
                                        filepath = self.images_dir / folder / filename
                                        
                                        if self.download_image_from_url(url, filepath):
                                            print(f"  [OK] Downloaded {filename} from GBIF")
                                            images_downloaded += 1
                                            time.sleep(1)
                                        break
                        
                        return images_downloaded
            return 0
        except Exception as e:
            print(f"  [WARNING] GBIF download failed: {e}")
            return 0

    def download_inaturalist_images(self, fish_id: str, scientific_name: str, image_type: str) -> int:
        """Download images from iNaturalist"""
        try:
            # iNaturalist API
            api_url = "https://api.inaturalist.org/v1/observations"
            params = {
                'taxon_name': scientific_name,
                'photos': 'true',
                'quality_grade': 'research',
                'per_page': 5
            }
            
            response = self.session.get(api_url, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                images_downloaded = 0
                target = 2 if image_type == 'natural' else 1
                
                for observation in data.get('results', [])[:target]:
                    photos = observation.get('photos', [])
                    for photo in photos:
                        url = photo.get('url')
                        if url:
                            # Get medium size image
                            url = url.replace('square', 'medium')
                            filename = self.get_filename(fish_id, image_type, images_downloaded)
                            folder = self.get_image_folder(image_type)
                            filepath = self.images_dir / folder / filename
                            
                            if self.download_image_from_url(url, filepath):
                                print(f"  [OK] Downloaded {filename} from iNaturalist")
                                images_downloaded += 1
                                time.sleep(1)
                            break
                
                return images_downloaded
            return 0
        except Exception as e:
            print(f"  [WARNING] iNaturalist download failed: {e}")
            return 0

    def download_fishbase_diagrams(self, fish_id: str, scientific_name: str) -> int:
        """Download scientific diagrams from FishBase"""
        try:
            # FishBase species page for diagrams
            species_url = f"https://www.fishbase.se/summary/{scientific_name.replace(' ', '-')}.html"
            
            response = self.session.get(species_url, timeout=10)
            if response.status_code == 200:
                content = response.text
                # Look for diagram images (simplified pattern)
                diagram_urls = re.findall(r'https://www\.fishbase\.se/images/species/.*?\.gif', content)
                
                for url in diagram_urls[:1]:  # Just one diagram
                    filename = f"{fish_id}_diagram.jpg"
                    filepath = self.images_dir / "scientific" / filename
                    
                    if self.download_image_from_url(url, filepath):
                        print(f"  [OK] Downloaded {filename} from FishBase")
                        return 1
                        
            return 0
        except Exception as e:
            print(f"  [WARNING] FishBase diagram download failed: {e}")
            return 0

    def download_fao_diagrams(self, fish_id: str, scientific_name: str) -> int:
        """Download scientific diagrams from FAO Species Identification Sheets"""
        try:
            # FAO species database (simplified)
            fao_url = f"http://www.fao.org/fishery/species/search"
            params = {'species': scientific_name}
            
            response = self.session.get(fao_url, params=params, timeout=10)
            if response.status_code == 200:
                # This would need more sophisticated parsing
                # For now, return 0 as this requires complex HTML parsing
                return 0
            return 0
        except Exception as e:
            print(f"  [WARNING] FAO diagram download failed: {e}")
            return 0

    def download_fishbase_maps(self, fish_id: str, scientific_name: str) -> int:
        """Download habitat maps from FishBase"""
        try:
            # FishBase distribution map
            map_url = f"https://www.fishbase.se/Country/CountrySpeciesSummary.php?c_code=&id={scientific_name}"
            
            response = self.session.get(map_url, timeout=10)
            if response.status_code == 200:
                content = response.text
                # Look for map images
                map_urls = re.findall(r'https://www\.fishbase\.se/images/gifs/.*?map.*?\.gif', content)
                
                for url in map_urls[:1]:  # Just one map
                    filename = f"{fish_id}_habitat.jpg"
                    filepath = self.images_dir / "maps" / filename
                    
                    if self.download_image_from_url(url, filepath):
                        print(f"  [OK] Downloaded {filename} from FishBase")
                        return 1
                        
            return 0
        except Exception as e:
            print(f"  [WARNING] FishBase map download failed: {e}")
            return 0

    def download_gbif_maps(self, fish_id: str, scientific_name: str) -> int:
        """Download distribution maps from GBIF"""
        try:
            # GBIF map API
            gbif_api = "https://api.gbif.org/v1/species/search"
            params = {'q': scientific_name, 'limit': 1}
            
            response = self.session.get(gbif_api, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data.get('results'):
                    species_key = data['results'][0].get('key')
                    
                    # GBIF map URL
                    map_url = f"https://api.gbif.org/v2/map/occurrence/density/0/0/0@1x.png?taxonKey={species_key}"
                    
                    filename = f"{fish_id}_habitat.jpg"
                    filepath = self.images_dir / "maps" / filename
                    
                    if self.download_image_from_url(map_url, filepath):
                        print(f"  [OK] Downloaded {filename} from GBIF")
                        return 1
                        
            return 0
        except Exception as e:
            print(f"  [WARNING] GBIF map download failed: {e}")
            return 0

    def download_aquamaps_data(self, fish_id: str, scientific_name: str) -> int:
        """Download habitat data from AquaMaps"""
        try:
            # AquaMaps API (simplified)
            # This would require more complex API integration
            return 0
        except Exception as e:
            print(f"  [WARNING] AquaMaps download failed: {e}")
            return 0

    def download_wikimedia_sushi_images(self, fish_id: str, common_name: str, japanese_romaji: str) -> int:
        """Download sushi images from Wikimedia"""
        images_downloaded = 0
        
        # Search for both nigiri and sashimi
        sushi_types = ['nigiri', 'sashimi']
        search_terms = [common_name, japanese_romaji]
        
        for sushi_type in sushi_types:
            for term in search_terms:
                if images_downloaded >= 2:
                    break
                    
                result = self.download_wikimedia_images(
                    fish_id, f"{term} {sushi_type}", common_name, 'sushi'
                )
                images_downloaded += result
                
                if result > 0:
                    break  # Found image for this sushi type
        
        return min(images_downloaded, 2)

    def download_unsplash_sushi_images(self, fish_id: str, common_name: str, japanese_romaji: str) -> int:
        """Download sushi images from Unsplash (would need API key)"""
        # Unsplash requires API key, returning 0 for now
        # Could be implemented with proper API key
        return 0

    def download_pexels_sushi_images(self, fish_id: str, common_name: str, japanese_romaji: str) -> int:
        """Download sushi images from Pexels (would need API key)"""
        # Pexels requires API key, returning 0 for now
        # Could be implemented with proper API key
        return 0

    def create_missing_placeholders(self, fish_id: str, common_name: str, scientific_name: str, success_counts: Dict[str, int]):
        """Create placeholders only for images that couldn't be downloaded"""
        targets = {'natural': 2, 'scientific': 1, 'maps': 1, 'sushi': 2}
        
        for image_type, target_count in targets.items():
            downloaded = success_counts.get(image_type, 0)
            missing = target_count - downloaded
            
            if missing > 0:
                print(f"  [INFO] Creating {missing} placeholder(s) for {image_type} images")
                self.create_type_specific_placeholders(fish_id, common_name, scientific_name, image_type, downloaded, missing)

    def create_type_specific_placeholders(self, fish_id: str, common_name: str, scientific_name: str, image_type: str, start_index: int, count: int):
        """Create placeholders for specific image type"""
        try:
            from PIL import Image, ImageDraw, ImageFont
            
            color_map = {
                'natural': (70, 130, 180),
                'scientific': (147, 112, 219),
                'maps': (32, 178, 170),
                'sushi': (255, 160, 122)
            }
            
            text_map = {
                'natural': f"{common_name}\n(Natural Photo)",
                'scientific': f"{scientific_name}\n(Diagram)",
                'maps': f"{common_name}\n(Habitat Map)",
                'sushi': f"{common_name}\n(Sushi)"
            }
            
            color = color_map.get(image_type, (128, 128, 128))
            text = text_map.get(image_type, common_name)
            
            for i in range(count):
                filename = self.get_filename(fish_id, image_type, start_index + i)
                folder = self.get_image_folder(image_type)
                filepath = self.images_dir / folder / filename
                
                # Create enhanced placeholder
                img = Image.new('RGB', (600, 400), color)
                draw = ImageDraw.Draw(img)
                
                try:
                    font = ImageFont.truetype("arial.ttf", 32)
                except:
                    font = ImageFont.load_default()
                
                # Calculate text position
                bbox = draw.textbbox((0, 0), text, font=font)
                text_width = bbox[2] - bbox[0]
                text_height = bbox[3] - bbox[1]
                x = (600 - text_width) // 2
                y = (400 - text_height) // 2
                
                # Draw text with shadow
                draw.text((x+2, y+2), text, fill=(0, 0, 0, 128), font=font)
                draw.text((x, y), text, fill=(255, 255, 255), font=font)
                
                img.save(filepath, "JPEG", quality=90)
                print(f"  [OK] Created placeholder {filename}")
                
        except ImportError:
            # Fallback to basic placeholders
            self.create_basic_type_placeholders(fish_id, image_type, start_index, count)
        except Exception as e:
            print(f"  [ERROR] Error creating placeholders: {e}")

    def create_basic_type_placeholders(self, fish_id: str, image_type: str, start_index: int, count: int):
        """Create basic placeholder images when PIL is not available"""
        minimal_jpeg = bytes([
            0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
            0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
            0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
            0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
            0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
            0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
            0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
            0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x64,
            0x00, 0x64, 0x03, 0x01, 0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
            0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
            0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
            0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x9F, 0xFF, 0xD9
        ])
        
        for i in range(count):
            filename = self.get_filename(fish_id, image_type, start_index + i)
            folder = self.get_image_folder(image_type)
            filepath = self.images_dir / folder / filename
            
            with open(filepath, 'wb') as f:
                f.write(minimal_jpeg)
            print(f"  [OK] Created basic {filename}")

    def create_enhanced_placeholders(self, fish_id: str, common_name: str, scientific_name: str):
        """Create enhanced placeholder images with fish information"""
        try:
            from PIL import Image, ImageDraw, ImageFont
            
            # Image specifications
            specs = [
                ("natural", 1, f"{common_name}\n(Natural Habitat)", (70, 130, 180)),
                ("natural", 2, f"{scientific_name}\n(Wild)", (65, 105, 225)),
                ("sushi", "nigiri", f"{common_name}\nNigiri", (255, 160, 122)),
                ("sushi", "sashimi", f"{common_name}\nSashimi", (255, 182, 193)),
                ("maps", "habitat", f"{common_name}\nHabitat Range", (32, 178, 170)),
                ("scientific", "diagram", f"{scientific_name}\nAnatomy", (147, 112, 219))
            ]
            
            for spec in specs:
                folder, suffix, text, color = spec
                
                # Create high-quality placeholder
                width, height = 600, 400
                img = Image.new('RGB', (width, height), color)
                
                # Add gradient effect
                for y in range(height):
                    alpha = y / height
                    darker_color = tuple(int(c * (0.7 + 0.3 * alpha)) for c in color)
                    for x in range(width):
                        img.putpixel((x, y), darker_color)
                
                draw = ImageDraw.Draw(img)
                
                # Try to use a better font
                try:
                    title_font = ImageFont.truetype("arial.ttf", 36)
                    subtitle_font = ImageFont.truetype("arial.ttf", 24)
                except:
                    title_font = ImageFont.load_default()
                    subtitle_font = ImageFont.load_default()
                
                # Draw text with shadow
                lines = text.split('\n')
                y_start = height // 2 - (len(lines) * 35) // 2
                
                for i, line in enumerate(lines):
                    bbox = draw.textbbox((0, 0), line, font=title_font if i == 0 else subtitle_font)
                    text_width = bbox[2] - bbox[0]
                    x = (width - text_width) // 2
                    y = y_start + i * 45
                    
                    # Shadow
                    draw.text((x+2, y+2), line, fill=(0, 0, 0, 128), font=title_font if i == 0 else subtitle_font)
                    # Main text
                    draw.text((x, y), line, fill=(255, 255, 255), font=title_font if i == 0 else subtitle_font)
                
                # Add decorative border
                border_color = tuple(max(0, c - 50) for c in color)
                draw.rectangle([10, 10, width-10, height-10], outline=border_color, width=3)
                
                # Save image
                if isinstance(suffix, int):
                    filename = f"{fish_id}_{folder}_{suffix}.jpg"
                else:
                    filename = f"{fish_id}_{suffix}.jpg"
                
                filepath = self.images_dir / folder / filename
                img.save(filepath, "JPEG", quality=90)
                print(f"  [OK] Created enhanced {filename}")
                
        except ImportError:
            print("  [WARNING] PIL not available, creating basic placeholders")
            self.create_basic_placeholders(fish_id, common_name, scientific_name)
        except Exception as e:
            print(f"  [ERROR] Error creating enhanced placeholders: {e}")
            self.create_basic_placeholders(fish_id, common_name, scientific_name)

    def create_basic_placeholders(self, fish_id: str, common_name: str, scientific_name: str):
        """Create basic placeholder images when PIL is not available"""
        
        # Create minimal but valid JPEG files
        minimal_jpeg = bytes([
            0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
            0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
            0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
            0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
            0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
            0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
            0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
            0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x64,
            0x00, 0x64, 0x03, 0x01, 0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
            0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
            0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
            0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x9F, 0xFF, 0xD9
        ])
        
        files_to_create = [
            ("natural", f"{fish_id}_natural_1.jpg"),
            ("natural", f"{fish_id}_natural_2.jpg"),
            ("sushi", f"{fish_id}_nigiri.jpg"),
            ("sushi", f"{fish_id}_sashimi.jpg"),
            ("maps", f"{fish_id}_habitat.jpg"),
            ("scientific", f"{fish_id}_diagram.jpg")
        ]
        
        for folder, filename in files_to_create:
            filepath = self.images_dir / folder / filename
            if not filepath.exists():
                with open(filepath, 'wb') as f:
                    f.write(minimal_jpeg)
                print(f"  [OK] Created basic {filename}")

    def generate_json_dataset(self, fish_list: List[FishData]) -> str:
        """Generate the final JSON dataset"""
        dataset = {
            "fish_database": [asdict(fish) for fish in fish_list],
            "metadata": {
                "version": "1.0",
                "generated_at": time.strftime("%Y-%m-%d %H:%M:%S"),
                "total_species": len(fish_list),
                "description": "Fish database for Gyo Gai Do app"
            }
        }
        
        json_path = self.data_dir / "fish_database.json"
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(dataset, f, indent=2, ensure_ascii=False)
        
        print(f"Generated JSON dataset: {json_path}")
        return str(json_path)

    def run_extraction(self):
        """Main method to run the complete extraction process"""
        print("Starting fish data extraction process...")
        
        # Get species list
        species_list = self.get_top_20_fish_species()
        print(f"Extracting data for {len(species_list)} fish species")
        
        # Extract data for each species
        fish_data_list = []
        for species_info in species_list:
            try:
                fish_data = self.extract_fish_data(species_info)
                fish_data_list.append(fish_data)
                print(f"[OK] Completed: {fish_data.unique_name}")
            except Exception as e:
                print(f"[FAIL] Failed: {species_info['common_name']} - {e}")
        
        # Download real images from free sources
        self.download_free_images(fish_data_list)
        
        # Generate JSON dataset
        json_path = self.generate_json_dataset(fish_data_list)
        
        print(f"\nExtraction complete!")
        print(f"- Extracted data for {len(fish_data_list)} fish species")
        print(f"- Created placeholder images in: {self.images_dir}")
        print(f"- Generated dataset: {json_path}")
        print(f"\nNext steps:")
        print("1. Replace placeholder images with real fish photos")
        print("2. Update pubspec.yaml to include assets")
        print("3. Create Fish model class in Flutter")
        print("4. Implement database loading from JSON")

if __name__ == "__main__":
    extractor = FishDataExtractor()
    extractor.run_extraction()