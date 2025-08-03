#!/usr/bin/env python3
"""
Fish Image Download Script for Gyo Gai Do
This script provides automation helpers for downloading fish images from various sources.
"""

import requests
import os
import json
from urllib.parse import urlparse
import time

# Load fish database
def load_fish_database():
    with open('../assets/data/fish_database.json', 'r', encoding='utf-8') as f:
        return json.load(f)

# Fish species and their search terms
FISH_SEARCH_TERMS = {
    'atlantic_mackerel': {
        'scientific': ['atlantic mackerel anatomy', 'Scomber scombrus illustration'],
        'habitat': ['atlantic mackerel distribution', 'mackerel habitat map'],
        'sushi': ['saba nigiri', 'saba sashimi', 'atlantic mackerel sushi']
    },
    'atlantic_salmon': {
        'scientific': ['atlantic salmon anatomy', 'Salmo salar illustration'],
        'habitat': ['atlantic salmon distribution', 'salmon habitat range'],
        'sushi': ['sake nigiri', 'sake sashimi', 'salmon sushi']
    },
    'bluefin_tuna': {
        'scientific': ['bluefin tuna anatomy', 'Thunnus thynnus illustration'],
        'habitat': ['bluefin tuna migration map', 'tuna distribution'],
        'sushi': ['maguro nigiri', 'maguro sashimi', 'bluefin tuna sushi']
    },
    # Add all other species...
}

# Recommended sources with their APIs/search endpoints
SOURCES = {
    'fishbase': {
        'base_url': 'https://www.fishbase.org',
        'description': 'Best source for scientific diagrams and distribution maps'
    },
    'eol': {
        'base_url': 'https://eol.org/api',
        'description': 'Encyclopedia of Life - CC licensed images'
    },
    'gbif': {
        'base_url': 'https://api.gbif.org/v1',
        'description': 'Global biodiversity occurrence data'
    },
    'wikimedia': {
        'base_url': 'https://commons.wikimedia.org/w/api.php',
        'description': 'Wikimedia Commons free images'
    }
}

def search_wikimedia_commons(search_term, limit=5):
    """Search Wikimedia Commons for images"""
    url = "https://commons.wikimedia.org/w/api.php"
    params = {
        'action': 'query',
        'format': 'json',
        'list': 'search',
        'srsearch': search_term,
        'srnamespace': '6',  # File namespace
        'srlimit': limit
    }
    
    try:
        response = requests.get(url, params=params)
        data = response.json()
        return data.get('query', {}).get('search', [])
    except Exception as e:
        print(f"Error searching Wikimedia: {e}")
        return []

def get_fishbase_species_info(scientific_name):
    """Get species information from FishBase (note: this would need FishBase API access)"""
    # FishBase doesn't have a public API, but provides excellent images
    # Manual search recommended: https://www.fishbase.se/search.php
    fishbase_search_url = f"https://www.fishbase.se/search.php?q={scientific_name.replace(' ', '+')}"
    return fishbase_search_url

def download_image(url, filepath):
    """Download image from URL to filepath"""
    try:
        response = requests.get(url, stream=True)
        response.raise_for_status()
        
        with open(filepath, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"Downloaded: {filepath}")
        return True
    except Exception as e:
        print(f"Error downloading {url}: {e}")
        return False

def generate_search_urls():
    """Generate search URLs for manual image sourcing"""
    database = load_fish_database()
    
    print("=== FISH IMAGE SEARCH URLS ===\n")
    
    for fish in database['fish_database']:
        species_id = fish['id']
        common_name = fish['unique_name']
        scientific_name = fish['scientific_name']
        japanese_name = fish.get('japanese_name_romaji', '')
        
        print(f"### {common_name} ({scientific_name})")
        print(f"Japanese: {japanese_name}")
        print()
        
        # Scientific diagram searches
        print("**Scientific Diagrams:**")
        print(f"- FishBase: https://www.fishbase.se/search.php?q={scientific_name.replace(' ', '+')}")
        print(f"- Wikipedia: https://en.wikipedia.org/wiki/{scientific_name.replace(' ', '_')}")
        print(f"- Google Images: https://images.google.com/search?q={scientific_name.replace(' ', '+')}+anatomy+diagram")
        print()
        
        # Habitat map searches  
        print("**Habitat Maps:**")
        print(f"- FishBase Maps: https://www.fishbase.se/Country/CountrySpeciesSummary.php?c_code=&id={scientific_name.replace(' ', '+')}")
        print(f"- GBIF: https://www.gbif.org/species/search?q={scientific_name.replace(' ', '+')}")
        print(f"- AquaMaps: https://www.aquamaps.org/search.php?q={scientific_name.replace(' ', '+')}")
        print()
        
        # Sushi image searches
        print("**Sushi Images:**")
        print(f"- Google Images: https://images.google.com/search?q={japanese_name}+nigiri")
        print(f"- Google Images: https://images.google.com/search?q={japanese_name}+sashimi")
        print(f"- Unsplash: https://unsplash.com/search/photos/{japanese_name}+sushi")
        print()
        print("-" * 80)
        print()

def main():
    """Main function"""
    print("Fish Image Download Helper for Gyo Gai Do")
    print("=" * 50)
    
    choice = input("""
Choose an option:
1. Generate search URLs for manual downloading
2. Search Wikimedia Commons (automated)
3. Get FishBase URLs
4. Exit

Enter choice (1-4): """)
    
    if choice == '1':
        generate_search_urls()
    elif choice == '2':
        term = input("Enter search term: ")
        results = search_wikimedia_commons(term)
        print(f"Found {len(results)} results for '{term}':")
        for i, result in enumerate(results, 1):
            print(f"{i}. {result['title']}")
    elif choice == '3':
        database = load_fish_database()
        for fish in database['fish_database']:
            url = get_fishbase_species_info(fish['scientific_name'])
            print(f"{fish['unique_name']}: {url}")
    elif choice == '4':
        print("Goodbye!")
    else:
        print("Invalid choice!")

if __name__ == "__main__":
    main()