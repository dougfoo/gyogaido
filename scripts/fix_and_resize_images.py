#!/usr/bin/env python3
"""
Image Fixer and Resizer for Gyo Gai Do App

This script fixes broken images and resizes all images to a uniform 400x300 pixels.
"""

import os
import requests
import time
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json

class ImageFixerResizer:
    def __init__(self):
        self.base_dir = Path(__file__).parent.parent
        self.images_dir = self.base_dir / "assets" / "images"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Gyo-Gai-Do-Educational-App/1.0'
        })
        
        # Target size for all images
        self.target_size = (400, 300)
        
        # List of broken images identified
        self.broken_images = [
            "natural/red_snapper_natural_2.jpg",
            "scientific/atlantic_mackerel_diagram.jpg", 
            "scientific/bluefin_tuna_diagram.jpg",
            "scientific/yellowfin_tuna_diagram.jpg",
            "maps/atlantic_salmon_habitat.jpg",
            "maps/horse_mackerel_habitat.jpg"
        ]

    def fix_broken_images(self):
        """Fix the broken images by recreating them"""
        print("Fixing broken images...")
        
        for broken_image in self.broken_images:
            image_path = self.images_dir / broken_image
            print(f"Fixing: {broken_image}")
            
            # Parse the image info from filename
            parts = broken_image.split('/')
            folder = parts[0]
            filename = parts[1]
            
            # Extract fish info from filename
            if folder == 'natural':
                fish_name = filename.replace('_natural_2.jpg', '').replace('_', ' ').title()
                self.create_natural_placeholder(image_path, fish_name)
            elif folder == 'scientific':
                fish_name = filename.replace('_diagram.jpg', '').replace('_', ' ').title()
                self.create_scientific_placeholder(image_path, fish_name)
            elif folder == 'maps':
                fish_name = filename.replace('_habitat.jpg', '').replace('_', ' ').title()
                self.create_map_placeholder(image_path, fish_name)
            
            print(f"  [OK] Fixed {broken_image}")

    def create_natural_placeholder(self, filepath: Path, fish_name: str):
        """Create a natural photo placeholder"""
        img = Image.new('RGB', self.target_size, (70, 130, 180))
        draw = ImageDraw.Draw(img)
        
        # Add gradient effect
        for y in range(self.target_size[1]):
            alpha = y / self.target_size[1]
            darker_color = tuple(int(c * (0.6 + 0.4 * alpha)) for c in (70, 130, 180))
            for x in range(self.target_size[0]):
                img.putpixel((x, y), darker_color)
        
        # Add text
        self.add_text_to_image(img, f"{fish_name}\n(Natural Photo)", (255, 255, 255))
        img.save(filepath, "JPEG", quality=90)

    def create_scientific_placeholder(self, filepath: Path, fish_name: str):
        """Create a scientific diagram placeholder"""
        img = Image.new('RGB', self.target_size, (147, 112, 219))
        draw = ImageDraw.Draw(img)
        
        # Add simple diagram-like elements
        draw.ellipse([50, 100, 350, 200], outline=(255, 255, 255), width=3)
        draw.line([100, 150, 80, 120], fill=(255, 255, 255), width=2)  # Line to "fin"
        draw.line([300, 150, 320, 120], fill=(255, 255, 255), width=2)  # Line to "tail"
        
        # Add text
        self.add_text_to_image(img, f"{fish_name}\n(Scientific Diagram)", (255, 255, 255))
        img.save(filepath, "JPEG", quality=90)

    def create_map_placeholder(self, filepath: Path, fish_name: str):
        """Create a habitat map placeholder"""
        img = Image.new('RGB', self.target_size, (32, 178, 170))
        draw = ImageDraw.Draw(img)
        
        # Add simple map-like elements
        # Ocean areas
        draw.ellipse([20, 50, 180, 150], fill=(0, 100, 150), outline=(255, 255, 255))
        draw.ellipse([220, 100, 380, 200], fill=(0, 100, 150), outline=(255, 255, 255))
        
        # Add text
        self.add_text_to_image(img, f"{fish_name}\n(Habitat Map)", (255, 255, 255))
        img.save(filepath, "JPEG", quality=90)

    def add_text_to_image(self, img: Image.Image, text: str, color: tuple):
        """Add text to an image with proper centering"""
        draw = ImageDraw.Draw(img)
        
        try:
            font = ImageFont.truetype("arial.ttf", 24)
        except:
            font = ImageFont.load_default()
        
        # Calculate text position
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (self.target_size[0] - text_width) // 2
        y = (self.target_size[1] - text_height) // 2
        
        # Draw text with shadow for better visibility
        draw.text((x+2, y+2), text, fill=(0, 0, 0, 128), font=font)
        draw.text((x, y), text, fill=color, font=font)

    def resize_all_images(self):
        """Resize all images to uniform 400x300 pixels"""
        print(f"Resizing all images to {self.target_size[0]}x{self.target_size[1]} pixels...")
        
        folders = ['natural', 'scientific', 'maps', 'sushi']
        total_resized = 0
        
        for folder in folders:
            folder_path = self.images_dir / folder
            if not folder_path.exists():
                continue
                
            print(f"\nProcessing {folder} images:")
            
            for image_file in folder_path.glob('*.jpg'):
                try:
                    # Open and check current size
                    with Image.open(image_file) as img:
                        current_size = img.size
                        
                        if current_size != self.target_size:
                            # Convert to RGB if needed to ensure JPEG compatibility
                            if img.mode in ('RGBA', 'P'):
                                rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                                if img.mode == 'P':
                                    img = img.convert('RGB')
                                elif img.mode == 'RGBA':
                                    rgb_img.paste(img, mask=img.split()[-1])
                                    img = rgb_img
                            
                            # Resize with high quality
                            resized_img = img.resize(self.target_size, Image.Resampling.LANCZOS)
                            
                            # Save with good quality
                            resized_img.save(image_file, "JPEG", quality=90, optimize=True)
                            print(f"  [RESIZED] {image_file.name}: {current_size[0]}x{current_size[1]} -> {self.target_size[0]}x{self.target_size[1]}")
                            total_resized += 1
                        else:
                            print(f"  [OK] {image_file.name}: Already correct size")
                            
                except Exception as e:
                    print(f"  [ERROR] {image_file.name}: {e}")
        
        print(f"\nResizing complete! {total_resized} images resized.")

    def download_better_replacement_images(self):
        """Try to download better replacement images for the broken ones"""
        print("Attempting to download better replacement images...")
        
        # Fish name mapping for better search
        fish_search_terms = {
            "red_snapper": "red snapper fish",
            "atlantic_mackerel": "atlantic mackerel fish anatomy",
            "bluefin_tuna": "bluefin tuna fish anatomy", 
            "yellowfin_tuna": "yellowfin tuna fish anatomy",
            "atlantic_salmon": "atlantic salmon habitat distribution",
            "horse_mackerel": "horse mackerel habitat distribution"
        }
        
        for broken_image in self.broken_images:
            parts = broken_image.split('/')
            folder = parts[0]
            filename = parts[1]
            
            # Extract fish key
            if folder == 'natural':
                fish_key = filename.replace('_natural_2.jpg', '')
            elif folder == 'scientific':
                fish_key = filename.replace('_diagram.jpg', '')
            elif folder == 'maps':
                fish_key = filename.replace('_habitat.jpg', '')
            
            search_term = fish_search_terms.get(fish_key, fish_key.replace('_', ' '))
            
            # Try to download from Wikimedia
            success = self.try_wikimedia_download(search_term, self.images_dir / broken_image, folder)
            
            if success:
                print(f"  [OK] Downloaded replacement for {broken_image}")
            else:
                print(f"  [FALLBACK] Using placeholder for {broken_image}")
            
            time.sleep(1)  # Rate limiting

    def try_wikimedia_download(self, search_term: str, filepath: Path, image_type: str) -> bool:
        """Try to download a replacement image from Wikimedia"""
        try:
            wiki_api = "https://commons.wikimedia.org/w/api.php"
            
            # Adjust search term based on image type
            if image_type == 'scientific':
                search_term += " anatomy diagram"
            elif image_type == 'maps':
                search_term += " distribution habitat map"
            elif image_type == 'natural':
                search_term += " fish"
            
            params = {
                'action': 'query',
                'format': 'json',
                'list': 'search',
                'srsearch': f'filetype:bitmap {search_term}',
                'srnamespace': 6,
                'srlimit': 3
            }
            
            response = self.session.get(wiki_api, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                
                if 'query' in data and 'search' in data['query']:
                    for result in data['query']['search']:
                        file_title = result['title']
                        image_url = self.get_wikimedia_image_url(file_title)
                        
                        if image_url and self.download_image_from_url(image_url, filepath):
                            return True
            
            return False
            
        except Exception as e:
            print(f"  [WARNING] Wikimedia download failed: {e}")
            return False

    def get_wikimedia_image_url(self, file_title: str) -> str:
        """Get direct image URL from Wikimedia Commons"""
        try:
            api_url = "https://commons.wikimedia.org/w/api.php"
            params = {
                'action': 'query',
                'format': 'json',
                'titles': file_title,
                'prop': 'imageinfo',
                'iiprop': 'url',
                'iiurlwidth': 600
            }
            
            response = self.session.get(api_url, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                pages = data.get('query', {}).get('pages', {})
                
                for page in pages.values():
                    if 'imageinfo' in page:
                        return page['imageinfo'][0].get('thumburl') or page['imageinfo'][0].get('url')
            
            return None
            
        except Exception:
            return None

    def download_image_from_url(self, url: str, filepath: Path) -> bool:
        """Download an image from URL"""
        try:
            response = self.session.get(url, timeout=30, stream=True)
            
            if response.status_code == 200:
                content_type = response.headers.get('content-type', '')
                if 'image' in content_type:
                    with open(filepath, 'wb') as f:
                        for chunk in response.iter_content(chunk_size=8192):
                            if chunk:
                                f.write(chunk)
                    return True
            return False
            
        except Exception:
            return False

    def run_fix_and_resize(self):
        """Main method to fix broken images and resize all images"""
        print("Starting image fixing and resizing process...")
        
        # Step 1: Try to download better replacements
        self.download_better_replacement_images()
        
        # Step 2: Fix any remaining broken images with placeholders
        self.fix_broken_images()
        
        # Step 3: Resize all images to uniform size
        self.resize_all_images()
        
        print("\nImage fixing and resizing complete!")
        print(f"All images are now {self.target_size[0]}x{self.target_size[1]} pixels")

if __name__ == "__main__":
    fixer = ImageFixerResizer()
    fixer.run_fix_and_resize()