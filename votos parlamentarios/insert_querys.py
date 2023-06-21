# Este script transforma los registros de la planilla detalles.xlsx en sentencias sql tipo insert, para ejecutarlas en la base de datos
import openpyxl

# Abrir el archivo Excel
workbook = openpyxl.load_workbook('detalles.xlsx')
sheet = workbook.active

# Obtener los encabezados de las columnas
headers = [cell.value for cell in sheet[1]]

# Construir las consultas SQL
queries = []
for row in sheet.iter_rows(min_row=2, values_only=True):
    query = "INSERT INTO detalles(id_votacion, id_voto, id_parlamentario) VALUES ('{}', {}, '{}');".format(row[0], row[1], row[2])
    queries.append(query)

# Escribir las consultas en el archivo de texto
with open('detalles_querys.txt', 'w') as file:
    file.write('\n'.join(queries))
