


--CLEANING DATA IN SQL

Select*
From NashvilleHousing



--Standardize Date Format

Select SaleDateConverted, CONVERT (date,SaleDate)
From NashvilleHousing

Update	NashvilleHousing
SET SaleDate = CONVERT (date,SaleDate)

Select SaleDateConverted as SaleDate2
From NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT (date,SaleDate)


--Populate Property Address Data

Select PropertyAddress
From NashvilleHousing
Where PropertyAddress is null

Select *
From NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID

--We have found all addresses connected with NULL using the ParcelID. 
Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
From NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Now we need to populate those with NULL.

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL (A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

-- Now we are making sure there are no NULL values. 
-- ISNULL query checks if the value is NULL and if it is then it populates with the value from the relevant row
-- Alternatively, it can populate empty row with "No data/address" 

Update A
SET PropertyAddress = ISNULL (A.PropertyAddress,B.PropertyAddress)
From NashvilleHousing A
JOIN NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null


--Breaking out Address into Columns (Address, City, State) - Getting rid of the delimiter ","

Select PropertyAddress
From NashvilleHousing


SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

-- Cant separate data from 1 column without creating a proper second column

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select*
From NashvilleHousing

--Splitting OwnerAddress column

Select OwnerAddress
From NashvilleHousing


Select*
From NashvilleHousing

--Separating the State

Select
PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From NashvilleHousing


-- Splitting into 3 Columns - Address, City, State

Select
PARSENAME(Replace(OwnerAddress,',', '.'), 3)
, PARSENAME(Replace(OwnerAddress,',', '.'), 2)
, PARSENAME(Replace(OwnerAddress,',', '.'), 1)
From NashvilleHousing

-- Now adding the proper column names and updating the data

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)


--Changing Y and N to Yes and No in "Sold as Vacant" field

--Checking the SoldAsVacant column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2

--Changing Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From NashvilleHousing

--Updating the Nashville Housing File

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
	   	 

-- REMOVE DUPLICATES
-- Determining the duplicate rows

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From NashvilleHousing
--Order by ParcelID
)
Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

----DELETING Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY 
					UniqueID
					) row_num
From NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1

-- Delete Unused Columns

ALTER TABLE NashvilleHousing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
	DROP COLUMN SaleDate

Select *
From NashvilleHousing
