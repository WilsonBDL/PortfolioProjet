/*

											--Nettoyage de données avec SQL

*/

Select*
From project3.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Standardiser les dates de ventes

Select saleDateConvert, CONVERT(Date,SaleDate)
from project3.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConvert Date;

Update NashvilleHousing
SET SaleDateConvert = CONVERT(Date,SaleDate)

----------------------------------------------------------------------------------------------------------------------------------------------------

-- Maison sans adresse

Select PropertyAddress
from project3.dbo.NashvilleHousing
where PropertyAddress is null 
		-- beaucoup de null

Select*
from project3.dbo.NashvilleHousing
where PropertyAddress is null 

Select*
from project3.dbo.NashvilleHousing
order by ParcelID	-- On remarque que le ParcelID idemtifie les address.
						--Donc si adress = Null et nous avons le ParcelID, nous pouvons trouver l'adresse



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) -- ISNULL va ajouter l'adresse requise
from project3.dbo.NashvilleHousing a
JOIN project3.dbo.NashvilleHousing b
    on a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ] -- pas le meme Unique ID
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from project3.dbo.NashvilleHousing a
JOIN project3.dbo.NashvilleHousing b
    on a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

		--Nous permet de valider qu'il y a aucune adresse null
		Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) -- ISNULL va ajouter l'adresse requise
		from project3.dbo.NashvilleHousing a
		JOIN project3.dbo.NashvilleHousing b
		on a.ParcelID= b.ParcelID
		AND a.[UniqueID ]<> b.[UniqueID ] -- pas le meme Unique ID
		Where a.PropertyAddress is null





----------------------------------------------------------------------------------------------------------------------------------------------------

-- Diviser le PropertyAddress (Address,City,State)


Select PropertyAddress
from project3.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address -- Nous avons pas le "," dans notre adresse
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from project3.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


Select*
from project3.dbo.NashvilleHousing



Select OwnerAddress
from project3.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From project3.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)




ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


			--Cela permet de voir si la colonne est ajoutée
Select*
from project3.dbo.NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------------

-- Changer le Y et N pour Yes et No dans la colonne SoldasVacant

				--Permet de voir combien il y a de Y,N,Yes, No
Select Distinct(SoldAsVacant), Count (SoldAsVacant)
From project3.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
  when SoldAsVacant = 'N' THEN 'No'
  else SoldAsVacant 
  END
From project3.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' THEN 'Yes'
  when SoldAsVacant = 'N' THEN 'No'
  else SoldAsVacant 
  END
	-- Pour voir si cela fonctionne
	Select Distinct ( SoldAsVacant), COUNT(SOLDASVACANT)
	From project3.dbo.NashvilleHousing
	group by SoldAsVacant
	order by 2


----------------------------------------------------------------------------------------------------------------------------------------------------

--Enlever les "duplicates"

WITH RowNumCTE AS(
Select*,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num

				
From project3.dbo.NashvilleHousing )
--order By ParcelID

Select*
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

			---Effacer 
			with RowNumCTE as (
			select*,
			row_number() over (
			partition by ParcelID,
									PropertyAddress,
									SalePrice,
									LegalReference 
									order by
									UniqueID
											) row_num
			From project3.dbo.NashvilleHousing
			--order by ParcelID
			delete from RowNumCTE 
			Where row_num > 1
			--order by PropertyAddress

					--regarder si ya encore des "duplicates"
					with RowNumCTE as ( 
			select*,
			row_number() over (
			partition by ParcelID,
								PropertyAddress,
								SalePrice,
								LegalReference
								order by
								UniqueID
										) row_num
			from project3.dbo.NashvilleHousing
			--order by ParcelID

			Select*
			from RowNumCTE
			where row_num >1
			order by PropertyAddress




----------------------------------------------------------------------------------------------------------------------------------------------------

-- Effacer les colonnes inutilisées


Select*
From project3.dbo.NashvilleHousing

ALTER TABLE project3.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE project3.dbo.NashvilleHousing
DROP COLUMN SaleDate


