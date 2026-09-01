# ============================================================================
# Sr Isoscape Project - Setup & Project Structure
# ============================================================================
# Cel: Inicjalizacja folderu roboczego, walidacja pakietów, struktura danych
# Data: 2026-09-01
# ============================================================================

# 1. USTAWIENIE WORKING DIRECTORY
# ============================================================================
# Zmień to na Twoją ścieżkę lokalną:
setwd("C:/Users/abudz/Documents/Domasław/Kringing test")

# Sprawdź bieżący katalog
cat("Working directory:", getwd(), "\n")

# 2. UTWORZENIE STRUKTURY FOLDERÓW
# ============================================================================
dirs <- c(
  "data/raw",
  "data/processed",
  "data/rasters",
  "scripts",
  "output/maps",
  "output/models",
  "output/reports",
  "docs"
)

for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE, showWarnings = FALSE)
    cat("✓ Utworzono folder:", dir, "\n")
  } else {
    cat("✓ Folder już istnieje:", dir, "\n")
  }
}

# 3. WALIDACJA PAKIETÓW
# ============================================================================
cat("\n--- Walidacja pakietów ---\n")

required_packages <- c(
  "sf",           # vector spatial data
  "terra",        # raster spatial data (nowoczesny)
  "tidyverse",    # data wrangling
  "ggplot2",      # visualization
  "gstat",        # geostatistics (kriging, variogram)
  "sfdep",        # spatial dependence (Moran's I)
  "rnaturalearth",# Natural Earth data (coastline)
  "geodata",      # WorldClim, GEBCO, DEM
  "elevatr",      # elevation wrapper
  "httr",         # HTTP requests (API)
  "jsonlite",     # JSON parsing
  "readxl",       # Excel files
  "car",          # statistics (VIF, etc)
  "corrplot",     # correlation matrices
  "blockCV"       # spatial cross-validation
)

missing_packages <- required_packages[!required_packages %in% rownames(installed.packages())]

if (length(missing_packages) > 0) {
  cat("\nInstaluję brakujące pakiety:\n")
  install.packages(missing_packages, dependencies = TRUE)
} else {
  cat("\nWszystkie wymagane pakiety są już zainstalowane.\n")
}

# Załaduj pakiety
invisible(sapply(required_packages, library, character.only = TRUE, quietly = TRUE))
cat("✓ Wszystkie pakiety załadowane.\n")

# 4. USTAWIENIA GLOBALNE
# ============================================================================
options(timeout = 300)  # Timeout dla pobrań (5 minut)
options(digits = 7)     # Precyzja liczb

# CRS docelowy (EPSG:4326 = WGS84)
CRS_WGS84 <- "EPSG:4326"
CRS_UTM33 <- "EPSG:32633"  # UTM Zone 33N (Europa Środkowa)

cat("\n--- Ustawienia ---\n")
cat("CRS docelowy (WGS84):", CRS_WGS84, "\n")
cat("CRS lokalne (UTM33N):", CRS_UTM33, "\n")

# 5. BBOX DOCELOWY (Europa Środkowa - Polska/Czechy/Niemcy)
# ============================================================================
bbox_emc <- c(
  xmin = 13,    # W
  ymin = 49,    # S
  xmax = 24,    # E
  ymax = 53     # N
)

cat("\n--- Bounding Box ---\n")
cat("Zachodnia granica (LON):", bbox_emc["xmin"], "°E\n")
cat("Wschodnia granica (LON):", bbox_emc["xmax"], "°E\n")
cat("Południowa granica (LAT):", bbox_emc["ymin"], "°N\n")
cat("Północna granica (LAT):", bbox_emc["ymax"], "°N\n")

# Konwertuj na sf bounding box
bbox_sf <- sf::st_as_sfc(
  sf::st_bbox(c(xmin = bbox_emc["xmin"], ymin = bbox_emc["ymin"],
                xmax = bbox_emc["xmax"], ymax = bbox_emc["ymax"]),
              crs = CRS_WGS84)
)

# 6. PARAMETRY MODELOWANIA
# ============================================================================
cat("\n--- Parametry modelowania ---\n")

# Rozdzielczość rastru docelowego (25 km)
grid_res_km <- 25
cat("Rozdzielczość gridu predykcyjnego:", grid_res_km, "km\n")

# Parametry kriging'u
kriging_params <- list(
  max_dist = 500,           # maksymalny dystans (km)
  min_neighbors = 5,        # min. liczba sąsiadów
  max_neighbors = 15,       # max. liczba sąsiadów
  variogram_model = "Sph"   # model variogramu (Sph = Spherical)
)

cat("Maksymalny dystans kriging'u:", kriging_params$max_dist, "km\n")

# 7. SPRAWDZENIE POŁĄCZENIA INTERNETOWEGO
# ============================================================================
cat("\n--- Test pobierania danych ---\n")

test_url <- "https://www.worldclim.org"
test_connection <- tryCatch(
  {
    httr::HEAD(test_url, timeout(5))$status_code == 200
  },
  error = function(e) FALSE
)

if (test_connection) {
  cat("✓ Połączenie internetowe OK - możemy pobierać dane\n")
} else {
  cat("⚠ Brak połączenia internetowego lub niedostępny serwer\n")
}

# 8. ZAPIS KONFIGURACJI
# ============================================================================
config <- list(
  working_dir = getwd(),
  crs_wgs84 = CRS_WGS84,
  crs_utm = CRS_UTM33,
  bbox = bbox_emc,
  bbox_sf = bbox_sf,
  grid_res_km = grid_res_km,
  kriging_params = kriging_params,
  date_created = Sys.Date()
)

saveRDS(config, "data/processed/project_config.RDS")
cat("\n✓ Konfiguracja zapisana w: data/processed/project_config.RDS\n")

cat("\n✅ Setup projektu ZAKOŃCZONY\n")
cat("Następny krok: scripts/01_download_data_sources.R\n")
