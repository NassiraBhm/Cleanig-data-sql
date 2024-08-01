SELECT * 
FROM DataCleaning..NashvilleHousing

-- Standardize Date Format

SELECT SaleDate 
from DataCleaning..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--Or:


ALTER TABLE DataCleaning..NashvilleHousing
ADD ConvertedDate DATE;

UPDATE DataCleaning..NashvilleHousing
SET ConvertedDate = convert(DATE, SaleDate)

-- Populate NULL Property Address values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM DataCleaning..NashvilleHousing a
join DataCleaning..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID
WHERE  a.PropertyAddress is null

UPDATE a
set a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..NashvilleHousing a
join DataCleaning..NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.UniqueID <> b.UniqueID

select * 
from DataCleaning..NashvilleHousing
WHERE PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from DataCleaning..NashvilleHousing
  
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , len(PropertyAddress)) as City
from DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE DataCleaning..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE DataCleaning..NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE DataCleaning..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1 , len(PropertyAddress))

SELECT * FROM DataCleaning..NashvilleHousing


SELECT OwnerAddress
FROM DataCleaning..NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM DataCleaning..NashvilleHousing

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE DataCleaning..NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE DataCleaning..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" Column

SELECT DISTINCT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
  CASE WHEN SoldAsVacant = 'Y' then 'Yes'
  WHEN SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end
FROM DataCleaning..NashvilleHousing

UPDATE DataCleaning..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' then 'Yes'
  WHEN SoldAsVacant = 'N' then 'No'
  else SoldAsVacant
  end

SELECT DISTINCT(SoldAsVacant)
FROM DataCleaning..NashvilleHousing

-- Check for and Remove Duplicates

WITH RowNumCte as (
SELECT *, ROW_NUMBER() over (
     PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				 UniqueID) RowNum
FROM DataCleaning..NashvilleHousing
)
DELETE 
From RowNumCTE
WHERE RowNum > 1


--Removing unused columns

Select *
From DataCleaning..NashvilleHousing


ALTER TABLE DataCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
