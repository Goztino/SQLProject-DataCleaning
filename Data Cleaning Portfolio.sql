/*
Cleaning Data in SQL Queries
*/
---------------------------------------------------------------------




				--STANDARDIZE DATE FORMAT-- (To set the date in a more pleasant format)

SELECT SaleDate, CONVERT(DATE, SaleDate)
FROM NatshvilleHousing

UPDATE NatshvilleHousing
SET SaleDate = CONVERT (DATE,SaleDate)

ALTER TABLE NatshvilleHousing
ADD SaleDateConverted DATE; --This will add another column known as SaleDateConverted

UPDATE NatshvilleHousing
SET SaleDateConverted = CONVERT (DATE,SaleDate) --This will set the converted dates into SaleDateConverted





				--POPULATE PROPERTY ADDRESS DATA-- (To put same address with same ParcelID under empty PropertyAddresses)

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress) --Adds Address into the Empty PropertyAddress
FROM NatshvilleHousing A
JOIN NatshvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM NatshvilleHousing A
JOIN NatshvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress IS NULL





				--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

--FOR PROPERTYADDRESS
SELECT PropertyAddress
FROM NatshvilleHousing

SELECT
PARSENAME(REPLACE(PropertyAddress, ',','.'),2) Address,
PARSENAME(REPLACE(PropertyAddress, ',','.'),1) Address
FROM NatshvilleHousing

ALTER TABLE NatshvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NatshvilleHousing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress,',', '.'),2)

ALTER TABLE NatshvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NatshvilleHousing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress,',', '.'),1)


--FOR OWNERADDRESS
SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3) Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'),2) Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'),1) Address
FROM NatshvilleHousing

ALTER TABLE NatshvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE NatshvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NatshvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE NatshvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE NatshvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE NatshvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)





				--CHANGE Y AND N TO YES AND NO IN [SOLD AS VACANT] FIELD

SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' then 'YES'
	WHEN SoldAsVacant = 'N' then 'NO'
	ELSE SoldAsVacant
	END
FROM NatshvilleHousing

UPDATE NatshvilleHousing
SET SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'NO'
	ELSE SoldAsVacant
	END





				--REMOVE DUPLICATES
WITH RowNumCTE AS(
SELECT*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
						) row_num
FROM NatshvilleHousing
)

select * 
from RowNumCTE
where row_num > 1
Order by PropertyAddress --The idea is to use partition by to identify and delete duplicate rows





				--Delete unused Columns

select*
from NatshvilleHousing
ALTER TABLE NatshvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NatshvilleHousing
DROP COLUMN SaleDate