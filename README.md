# Sr Isoscape Project: Geostatistical Modeling of Bioavailable 87Sr/86Sr

**Cel:** Budowa izoscapy strontu biodostępnego (87Sr/86Sr) dla Europy Środkowej przy użyciu pełnego workflow geostatystycznego w **R**, bez polegania na narzędziach GIS.

**Status:** Proof-of-concept — Europa Środkowa (Polska/Czechy/Niemcy)

---

## 📊 Metodologia

### Główne etapy:

1. **Import danych** — CSV (LAT/LONG/87Sr/86Sr)
2. **Pozyskanie kovariantów** — dane publiczne:
   - Dystans od brzegu (Natural Earth coastline)
   - Litologia/wiek geologiczny (Macrostrat API, GLiM)
   - Topografia (SRTM/GEBCO DEM)
   - Klimat (WorldClim)
   - Sea spray effect (buffer zones)

3. **Walidacja espacjalna** — CRS, outlery, autokorelacja
4. **Exploratory Spatial Data Analysis (ESDA)** — Moran's I, LISA
5. **Modelowanie geostatystyczne:**
   - Ordinary Kriging (OK)
   - Universal Kriging (UK)
   - Regression Kriging (RK)
   - Empirical Bayesian Kriging (EBK)

6. **Walidacja** — Spatial block cross-validation (k-means)
7. **Predykcja** — Raster 25km × 25km
8. **Mapy niepewności** — RMSE, błąd predykcji

---

## 📁 Struktura projektu

```
sr-isoscape-project/
├── data/
│   ├── raw/                          # Surowe dane (CSV + pobrane pliki)
│   ├── processed/                    # Oczyszczone dane, kowarianty
│   └── rasters/                      # GeoTIFF, GeoJSON
├── scripts/
│   ├── 00_setup_project.R            # Setup folderów + pakiety
│   ├── 01_download_data_sources.R    # Pobieranie danych publicznych
│   ├── 02_import_sr_data.R           # Import CSV → SF obiekty
│   ├── 03_validate_spatial.R         # Walidacja CRS, braki, outlery
│   ├── 04_covariate_distance.R       # Dystans od brzegu
│   ├── 05_covariate_geology.R        # Litologia (Macrostrat/GLiM)
│   ├── 06_covariate_dem.R            # DEM (SRTM/GEBCO)
│   ├── 07_covariate_climate.R        # WorldClim (temp, precip)
│   ├── 08_covariate_seaspray.R       # Sea spray buffer effect
│   ├── 09_exploration.R              # EDA (histogramy, korelacje)
│   ├── 10_spatial_autocorr.R         # Moran's I, LISA, variogram
│   ├── 11_kriging_ok.R               # Ordinary Kriging
│   ├── 12_kriging_uk.R               # Universal Kriging
│   ├── 13_kriging_rk.R               # Regression Kriging
│   ├── 14_kriging_ebk.R              # Empirical Bayesian Kriging
│   ├── 15_cross_validation.R         # Spatial block CV
│   ├── 16_prediction_raster.R        # Finalna predykcja
│   ├── 17_uncertainty_map.R          # Mapy błędu
│   ├── 18_visualization.R            # Publikacyjne mapy
│   └── 99_run_all.R                  # Master script
├── output/
│   ├── maps/                         # PNG/PDF mapy
│   ├── models/                       # Zapisane modele (.RDS)
│   └── reports/                      # Raporty HTML/PDF
├── docs/
│   ├── METHODOLOGY.md                # Metodologia szczegółowa
│   ├── DATA_SOURCES.md               # Źródła danych publicznych
│   └── CITATIONS.md                  # Literatura
└── .gitignore
```

---

## 🚀 Szybki start

### 1. Setup

```r
source("scripts/00_setup_project.R")
```

Tworzy strukturę folderów, waliduje pakiety, ustawia konfigurację.

### 2. Pobierz dane publiczne

```r
source("scripts/01_download_data_sources.R")
```

Pobiera:
- Natural Earth coastline
- SRTM/GEBCO DEM
- WorldClim (temp, precip)
- Macrostrat geological units (API)
- GLiM (Global Lithological Map)

### 3. Import + Walidacja

```r
source("scripts/02_import_sr_data.R")      # Import CSV
source("scripts/03_validate_spatial.R")    # Walidacja
```

### 4. Budowa kovariantów

```r
source("scripts/04_covariate_distance.R")   # Dystans
source("scripts/05_covariate_geology.R")    # Litologia
source("scripts/06_covariate_dem.R")        # Topografia
source("scripts/07_covariate_climate.R")    # Klimat
source("scripts/08_covariate_seaspray.R")   # Sea spray
```

### 5. Analiza przestrzenna

```r
source("scripts/09_exploration.R")          # EDA
source("scripts/10_spatial_autocorr.R")     # Autokorelacja
```

### 6. Modelowanie

```r
source("scripts/11_kriging_ok.R")           # OK baseline
source("scripts/12_kriging_uk.R")           # UK z trendami
source("scripts/13_kriging_rk.R")           # RK z kovariantami
source("scripts/14_kriging_ebk.R")          # EBK
```

### 7. Predykcja + Walidacja

```r
source("scripts/15_cross_validation.R")     # Spatial block CV
source("scripts/16_prediction_raster.R")    # Finalna mapa
source("scripts/17_uncertainty_map.R")      # Mapa błędu
source("scripts/18_visualization.R")        # Publikacyjne mapy
```

### Lub uruchom wszystko naraz:

```r
source("scripts/99_run_all.R")
```

---

## 📦 Wymagane pakiety R

```r
install.packages(c(
  "sf", "terra", "tidyverse", "ggplot2",
  "gstat", "sfdep", "rnaturalearth", "geodata",
  "elevatr", "httr", "jsonlite", "readxl",
  "car", "corrplot", "blockCV"
))
```

---

## 🗺️ Bounding Box (Europa Środkowa)

```
Zachodnia granica (LON): 13°E
Wschodnia granica (LON): 24°E
Południowa granica (LAT): 49°N
Północna granica (LAT): 53°N

Rozdzielczość gridu: 25 km × 25 km
CRS: EPSG:4326 (WGS84)
CRS lokalne: EPSG:32633 (UTM Zone 33N)
```

---

## 📚 Literatura główna

- Scaffdi & Knudson (2020) — Universal Kriging z local polynomial detrending
- Chala-Aldana et al. (2026) — Regression Kriging vs. ML comparison
- James et al. (2025) — EBK Regression Prediction z litologią + DEM
- Hoogewerff et al. (2019) — Random Forest + Natural Neighbour interpolation
- Willmes et al. (2018) — Kriging z geological clusters (external drift)
- Blank et al. (2018) — EBK dla małych datasetów (n=155)

---

## 📝 Dane wejściowe

**Format:** CSV z kolumnami:
- `latitude_n` — szerokość geograficzna (°N)
- `longitude_e` — długość geograficzna (°E)
- `x87sr_86sr` — stosunek izotopowy 87Sr/86Sr

**Przykład:**
```
latitude_n,longitude_e,x87sr_86sr
30.45,78.7,0.7986
28.04,84.67,0.7969
-17.4093,130.7745,0.7957
```

**Ścieżka:** `data/raw/Sr+coord_do_GIS.csv`

---

## 📊 Output

### Mapy (output/maps/):
- `isoscape_sr87sr86.png` — finalna mapa 87Sr/86Sr
- `uncertainty_rmse.png` — mapa RMSE
- `variogram_fit.png` — dopasowany variogram
- `spatial_autocorr.png` — Moran's I, LISA

### Modele (output/models/):
- `kriging_ok.RDS` — Ordinary Kriging
- `kriging_uk.RDS` — Universal Kriging
- `kriging_rk.RDS` — Regression Kriging
- `kriging_ebk.RDS` — EBK model

### Raporty (output/reports/):
- `cv_results.csv` — wyniki cross-validation
- `model_diagnostics.txt` — diagnostyka modelów

---

## ⚙️ Konfiguracja projektu

Edytuj `data/processed/project_config.RDS` (automatycznie tworzony przez setup):

```r
config <- list(
  crs_wgs84 = "EPSG:4326",
  crs_utm = "EPSG:32633",
  bbox = c(xmin=13, ymin=49, xmax=24, ymax=53),
  grid_res_km = 25,
  kriging_params = list(
    max_dist = 500,
    min_neighbors = 5,
    max_neighbors = 15,
    variogram_model = "Sph"
  )
)
```

---

## 🔍 Kontakt i licencja

**Autor:** Damon Tarrant et al. (oryginalne badanie BC)  
**Reprodukcja/rozszerzenie:** Adam Budziszewski  
**Licencja:** CC-BY-4.0  
**Data:** 2026-09-01

---

## 📋 Checklist pracy

- [ ] Setup projektu (`00_setup_project.R`)
- [ ] Pobierz dane publiczne (`01_download_data_sources.R`)
- [ ] Import Sr data + walidacja (`02_import_sr_data.R`, `03_validate_spatial.R`)
- [ ] Budowa kovariantów (`04-08`)
- [ ] EDA + diagnostyka (`09-10`)
- [ ] Modelowanie kriging (`11-14`)
- [ ] Walidacja + predykcja (`15-17`)
- [ ] Wizualizacja (`18`)
- [ ] Raport końcowy + publikacja wyników

---

**Status:** 🚀 In Progress  
**Ostatnia aktualizacja:** 2026-09-01
