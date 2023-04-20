/*
	CLEANING DATA IN SQL QUERIES
*/


SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------

-- STANDARDIZE DATE FORMAT

SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)  --NO ACTUALIZÓ :(

-- Entonces usamos esta tecnica

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

-- Vemos que muchos registros duplicados de ParcelID tienen el mismo PropertyAddress, entonces lo que haremos es actualizar el PropertyAddress de aquellos duplicados que son NULL, asi vamos disminuyendo la cantidad de registros que tienen ese campo null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Ok, ya tenemos la sentencia ISNULL que nos va ayudar a rellenar los null en PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------

-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

-- Ahora debemos crear las columnas para los datos separados

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1,LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Usaremos otro metodo que no sea SUBSTRING, se llama PARSENAME, pero solo funciona con puntos, por lo que debemos reemplazar las comas por puntos.

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

-- Ahora creamos las columnas para cada dato

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Revisamos como quedó

SELECT *
FROM PortfolioProject..NashvilleHousing


-----------------------------------------------------------------------------------------------------------------

-- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Usaremos el metodo CASE

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM PortfolioProject..NashvilleHousing

-- Ahora hacemos el update directo en la columna SoldAsVacant

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

----------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
-- Se usa DELETE para eliminar los duplicados, luego el SELECT debe dar vacio.
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- DELETE UNUSED COLUMNS

