import pandas as pd
import geopandas as gpd
from pyproj import CRS

# Cargar el archivo GeoJSON y especificar el CRS proyectado
distritos = gpd.read_file('geojson.geojson')
distritos = distritos.to_crs(CRS.from_epsg(32721))  # Cambia el EPSG según tu CRS proyectado

# Calcular el punto medio geográfico para cada distrito
distritos['punto_medio'] = distritos.geometry.centroid

# Reproyectar el resultado a CRS geográfico (latitud y longitud)
distritos['punto_medio'] = distritos['punto_medio'].to_crs(CRS.from_epsg(4326))

# Obtener las coordenadas de latitud y longitud
distritos['latitud'] = distritos['punto_medio'].y
distritos['longitud'] = distritos['punto_medio'].x

# Crear un DataFrame con los nombres de los distritos, latitud y longitud
df = pd.DataFrame({
    'Distrito': distritos['dist_desc_'],
    'Latitud': distritos['latitud'],
    'Longitud': distritos['longitud']
})

# Guardar el DataFrame en un archivo Excel
df.to_excel('resultado.xlsx', index=False, sheet_name='Puntos Medios')
