/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM tarek..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateconverted , CONVERT(date,SaleDate)
FROM tarek..NashvilleHousing

UPDATE tarek..NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE tarek..NashvilleHousing
ADD SalesDateconverted date ;

UPDATE tarek..NashvilleHousing
SET SaleDateconverted = CONVERT(date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM tarek..NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.[UniqueID ],a.PropertyAddress,b.[UniqueID ],b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM tarek..NashvilleHousing AS a
JOIN tarek..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM tarek..NashvilleHousing AS a
JOIN tarek..NashvilleHousing AS b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM tarek..NashvilleHousing

SELECT SUBSTRING(NashvilleHousing.PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1) AS Address
,SUBSTRING(NashvilleHousing.PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) AS City
FROM tarek..NashvilleHousing

ALTER TABLE tarek..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE tarek..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(NashvilleHousing.PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1)

ALTER TABLE tarek..NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE tarek..NashvilleHousing
SET PropertySplitCity = SUBSTRING(NashvilleHousing.PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM tarek..NashvilleHousing


SELECT OwnerAddress
FROM tarek..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM tarek..NashvilleHousing

ALTER TABLE tarek..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE tarek..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE tarek..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE tarek..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE tarek..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE tarek..NashvilleHousing
SET OwnerSplitstate = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM tarek..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM tarek..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
	, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END 

FROM tarek..NashvilleHousing


UPDATE tarek..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						WHEN SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
				    END 

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS 
(
	SELECT * , 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) AS row_num
	FROM tarek..NashvilleHousing
)
--DELETE 
SELECT * 
FROM RowNumCTE
WHERE row_num >1

SELECT *
FROM tarek..NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM tarek..NashvilleHousing

ALTER TABLE tarek..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


