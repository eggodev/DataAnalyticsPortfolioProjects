import pandas as pd

# Cargar el archivo Excel original
df_original = pd.read_excel('PdteVicePorDistrito.xlsx')

# Agrupar los votos por distrito y sumar los valores
df_agrupado = df_original.groupby('DISTRITO').sum()

# Agregar la columna DEPARTAMENTO al distrito correspondiente
df_agrupado['DEPARTAMENTO'] = df_original.groupby('DISTRITO')['DEPARTAMENTO'].first()

# Obtener la primera aparición de LATITUD y LONGITUD para cada distrito
df_agrupado['LATITUD'] = df_original.groupby('DISTRITO')['LATITUD'].first()
df_agrupado['LONGITUD'] = df_original.groupby('DISTRITO')['LONGITUD'].first()

# Guardar el resultado en una nueva planilla
df_agrupado.to_excel('resultados.xlsx', index=True)
