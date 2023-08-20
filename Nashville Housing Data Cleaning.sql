SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Portfolio Project.Covid].[dbo].[NashvilleHousing]

  ------------------------------------------------------------------------------------------------
  -- Standardize Date Format
  select SaleDateConverted, Convert(Date,SaleDate)
  from dbo.NashvilleHousing

  update NashvilleHousing
  SET SaleDate = Convert(Date,SaleDate)

  Alter Table NashvilleHousing
  Add SaleDateConverted Date;

  update NashvilleHousing
  SET SaleDateConverted = Convert(Date,SaleDate)

  ---------------------------------------------------------------------------------------------------

  -- Populate Property address data

  select *
  from dbo.NashvilleHousing
  Where PropertyAddress is NULL


  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
  from dbo.NashvilleHousing a
  Join dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
    and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from dbo.NashvilleHousing a
  Join dbo.NashvilleHousing b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is NULL


---------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, city, zip)

select PropertyAddress
from dbo.NashvilleHousing

select
 Substring(PropertyAddress, 1, charindex(',' ,PropertyAddress)) as Address,
 charindex(',' ,PropertyAddress)
 from dbo.NashvilleHousing

 select
 Substring(PropertyAddress, 1, charindex(',' ,PropertyAddress) -1) as Address
 from dbo.NashvilleHousing

 select
 Substring(PropertyAddress, 1, charindex(',' ,PropertyAddress) -1) as Address,
  Substring(PropertyAddress, charindex(',' ,PropertyAddress) +1, LEN(PropertyAddress)) as Address
 from dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, charindex(',' ,PropertyAddress) -1) 

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, charindex(',' ,PropertyAddress) +1, LEN(PropertyAddress))

Select *
from dbo.NashvilleHousing


Select OwnerAddress
from dbo.NashvilleHousing

select 
parsename(replace(OwnerAddress, ',', '.'), 3),
parsename(replace(OwnerAddress, ',', '.'), 2),
parsename(replace(OwnerAddress, ',', '.'), 1)
From dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
Set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
Set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
Set OwnerSplitState =  parsename(replace(OwnerAddress, ',', '.'), 1)

select *
from dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No form SoldAsVacant Column

select distinct (SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
 , CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
from dbo.NashvilleHousing


update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


----------------------------------------------------------------------------------------------------------

--Remove Duplicates


With RowNumCTE AS (
Select *, 
	Row_Number() over(
	Partition by ParcelID, PropertyAddress, SalePrice, 
	SaleDate,
	LegalReference
	Order by
	 UniqueID
	 ) row_num

from dbo.NashvilleHousing
--order by ParcelID
)
Delete
from RowNumCTE
where row_num >1
--order by PropertyAddress

With RowNumCTE AS (
Select *, 
	Row_Number() over(
	Partition by ParcelID, PropertyAddress, SalePrice, 
	SaleDate,
	LegalReference
	Order by
	 UniqueID
	 ) row_num

from dbo.NashvilleHousing
--order by ParcelID
)
Select *
from RowNumCTE
where row_num >1
order by PropertyAddress


------------------------------------------------------------------------------------------------------------

--Delete Unused Columns

select *
from dbo.NashvilleHousing

Alter Table dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table dbo.NashvilleHousing
drop column SaleDate