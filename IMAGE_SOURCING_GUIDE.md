# Fish Image Sourcing Guide for Gyo Gai Do

This document provides specific guidance for finding and replacing all fish images in the app.

## Image Requirements

### Scientific Diagrams (assets/images/scientific/)
- **Format**: JPG, 600x400px minimum
- **Content**: Side-view anatomical diagram with labeled parts
- **Style**: Scientific illustration showing key identifying features
- **Labels needed**: Fins, body parts, distinctive markings

### Habitat Maps (assets/images/maps/)
- **Format**: JPG, 600x400px minimum  
- **Content**: Ocean/geographical map with species distribution highlighted
- **Style**: Clear oceanic map showing natural range
- **Requirements**: Pacific/Atlantic regions marked as per database

### Sushi Images (assets/images/sushi/)
- **Format**: JPG, 600x400px minimum
- **Content**: High-quality food photography
- **Styles needed**: Both nigiri (on rice) and sashimi (sliced raw)
- **Requirements**: Professional food photography quality

## Species List and Search Terms

### Fish Species (20 total):

1. **Atlantic Mackerel** (Scomber scombrus)
   - Japanese: Saba (鯖)
   - Search terms: "atlantic mackerel anatomy", "saba sushi", "mackerel distribution map"

2. **Atlantic Salmon** (Salmo salar)
   - Japanese: Sake (鮭)
   - Search terms: "atlantic salmon anatomy", "sake nigiri", "salmon habitat range"

3. **Bluefin Tuna** (Thunnus thynnus)
   - Japanese: Kuro-maguro (黒鮪)
   - Search terms: "bluefin tuna anatomy", "maguro sashimi", "tuna migration map"

4. **Conger Eel** (Conger myriaster)
   - Japanese: Anago (穴子)
   - Search terms: "conger eel anatomy", "anago nigiri", "eel distribution"

5. **Giant Pacific Octopus** (Enteroctopus dofleini)
   - Japanese: Tako (蛸)
   - Search terms: "pacific octopus anatomy", "tako sushi", "octopus range map"

6. **Greater Amberjack** (Seriola dumerili)
   - Japanese: Kanpachi (間八)
   - Search terms: "greater amberjack anatomy", "kanpachi sashimi", "amberjack habitat"

7. **Horse Mackerel** (Trachurus japonicus)
   - Japanese: Aji (鯵)
   - Search terms: "horse mackerel anatomy", "aji nigiri", "jack mackerel range"

8. **Japanese Amberjack** (Seriola quinqueradiata)
   - Japanese: Hamachi (鰤)
   - Search terms: "yellowtail anatomy", "hamachi sashimi", "buri distribution"

9. **Japanese Eel** (Anguilla japonica)
   - Japanese: Unagi (鰻)
   - Search terms: "japanese eel anatomy", "unagi nigiri", "freshwater eel range"

10. **Japanese Flying Squid** (Todarodes pacificus)
    - Japanese: Ika (烏賊)
    - Search terms: "flying squid anatomy", "ika sushi", "pacific squid range"

11. **Japanese Sardine** (Sardinops melanostictus)
    - Japanese: Iwashi (鰯)
    - Search terms: "japanese sardine anatomy", "iwashi nigiri", "sardine distribution"

12. **Japanese Scallop** (Patinopecten yessoensis)
    - Japanese: Hotate (帆立)
    - Search terms: "japanese scallop anatomy", "hotate nigiri", "scallop habitat"

13. **Japanese Sea Bass** (Lateolabrax japonicus)
    - Japanese: Suzuki (鱸)
    - Search terms: "japanese sea bass anatomy", "suzuki sashimi", "sea bass range"

14. **Kuruma Prawn** (Penaeus japonicus)
    - Japanese: Ebi (海老)
    - Search terms: "kuruma shrimp anatomy", "ebi nigiri", "prawn distribution"

15. **Olive Flounder** (Paralichthys olivaceus)
    - Japanese: Hirame (鮃)
    - Search terms: "olive flounder anatomy", "hirame sashimi", "flounder habitat"

16. **Pacific Saury** (Cololabis saira)
    - Japanese: Sanma (秋刀魚)
    - Search terms: "pacific saury anatomy", "sanma nigiri", "saury migration"

17. **Red Sea Bream** (Pagrus major)
    - Japanese: Madai (真鯛)
    - Search terms: "red sea bream anatomy", "tai sashimi", "sea bream range"

18. **Red Snapper** (Lutjanus campechanus)
    - Japanese: Tai (鯛)
    - Search terms: "red snapper anatomy", "snapper sushi", "lutjanus distribution"

19. **Sea Urchin** (Strongylocentrotus nudus)
    - Japanese: Uni (雲丹)
    - Search terms: "sea urchin anatomy", "uni nigiri", "urchin habitat"

20. **Yellowfin Tuna** (Thunnus albacares)
    - Japanese: Kihada (黄肌)
    - Search terms: "yellowfin tuna anatomy", "kihada sashimi", "yellowfin range"

## Recommended Sources

### Scientific Diagrams:
1. **FishBase** (fishbase.org) - Most comprehensive fish database
2. **EOL Encyclopedia of Life** (eol.org) - CC-licensed scientific images
3. **Wikipedia Commons** - Search "Fish anatomy diagram"
4. **NOAA Fisheries** - Public domain US government fish illustrations
5. **FAO Species ID Sheets** - UN Food & Agriculture scientific drawings

### Habitat Maps:
1. **FishBase Distribution Maps** - Species-specific range maps
2. **GBIF** (gbif.org) - Global biodiversity occurrence data with maps
3. **AquaMaps** (aquamaps.org) - Marine species distribution predictions
4. **NOAA/NMFS** - US waters distribution data
5. **Wikipedia** - Often has range maps in species articles

### Sushi Images:
1. **Unsplash** (unsplash.com) - High-quality CC0 food photography
2. **Pexels** (pexels.com) - Free stock photography including sushi
3. **Wikimedia Commons** - Search for "sushi", "nigiri", "sashimi"
4. **Japanese restaurant websites** - Many allow usage with attribution
5. **Flickr Creative Commons** - Search with CC filter enabled

## Image Processing Notes

1. **Resize all images** to appropriate dimensions (800x600 for diagrams/maps, 600x400 for sushi)
2. **Compress to reasonable file sizes** (aim for 100-300KB each)
3. **Ensure consistent styling** within each category
4. **Verify licensing** - use only CC0, public domain, or properly licensed images
5. **Add watermark removal** if needed for CC-licensed images with attribution requirements

## Implementation Strategy

1. **Start with scientific diagrams** - These are most educational and have best free sources
2. **Follow with habitat maps** - Use FishBase and GBIF for accurate ranges  
3. **Finish with sushi images** - These may require more careful sourcing for quality

## File Naming Convention

Files should match exactly:
- `{species_id}_diagram.jpg` (scientific)
- `{species_id}_habitat.jpg` (maps)  
- `{species_id}_nigiri.jpg` (sushi)
- `{species_id}_sashimi.jpg` (sushi)

Where species_id matches the database IDs (e.g., "atlantic_mackerel", "bluefin_tuna").