/*

Data Cleaning with SQL queries

*/

select *
from NashvilleHousing;
-----------------------------------------------

--Standardize Date Format

select SaleDateConverted, CONVERT(date, SaleDate)
from NashvilleHousing;

update NashvilleHousing
set SaleDate = CONVERT(date, SaleDate);

alter table NashvilleHousing
add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);

select SaleDateConverted
from NashvilleHousing;

---------------------------------------------------------

--Populate Property Address data

select *
from NashvilleHousing
where PropertyAddress is null
order by ParcelID; --the parcel id stays same for the Property Address

select a.ParcelID, a.PropertyAddress, b.ParcelId, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

------------------------------------------------------------

----Breaking out Address into different columns (Address, City, State)

select PropertyAddress
from NashvilleHousing;

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress)) as Address
FROM NashvilleHousing;

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 );

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress));

select * from NashvilleHousing;



select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing;

alter table NashvilleHousing
add  OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


select * from NashvilleHousing;
----------------------------------------------------------------------------------------


---Change Y and N to Yes and No in "Sold in Vacant" field


select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

select SoldAsVacant, 
CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END;

---------------------------------

--Removing Duplicates

WITH RowNumCTE AS(
select *, ROW_NUMBER() OVER (
		  PARTITION BY ParcelID,
					   PropertyAddress,
					   SalePrice,
					   SaleDate,
					   LegalReference
					   ORDER BY 
							UniqueID
							) row_num

from NashvilleHousing
)

select * from RowNumCTE
where row_num>1

select * from NashvilleHousing;

----------------------------------------------------------------------

--Delete Unused Columns

select * from NashvilleHousing;

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress,TaxDistrict,SaleDate;



