/*
			-DATA CLEANING-
	Data: layoffs from companies around the world
    Steps: 1. Remove Duplcates
		   2. Standarize Data
           3. Deal with NULL or blank values
           4. Remove unnessesary columns 
           (this step is done when the col is not relevant at all and the removal won't effect other processes)
           (can be a huge problem if it's used elsewhere)
    
*/

-- Creating a STAGING table to keep raw data save
create table layoffs_staging
select * from layoffs;
-- or CREATE table layoffs_staging LIKE layoffs
select * from layoffs_staging;

-- 1.Removig Duplcates
/*
	- because there is no unique col we would use row_number to deal with the dups
    - row_number col is a temp column not presistant
*/

select *,
row_number()
over(partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- now we put it in a CTE to work with it as a dataset

with duplcate_cte as
(
select *,
row_number()
over(partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplcate_cte
where row_num >1;

-- we cant delete dups directly from the CTE so we create a table to hold the data
CREATE TABLE `layoffs_staging_2` (
  `company` text DEFAULT NULL,
  `location` text DEFAULT NULL,
  `industry` text DEFAULT NULL,
  `total_laid_off` int(11) DEFAULT NULL,
  `percentage_laid_off` text DEFAULT NULL,
  `date` text DEFAULT NULL,
  `stage` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `funds_raised_millions` int(11) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

select * 
from layoffs_staging_2;

insert layoffs_staging_2
select *,
row_number()
over(partition by company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

-- delete dups
-- check what you're deleting
select *
from layoffs_staging_2
where row_num >1;

Delete
from layoffs_staging_2
where row_num > 1;

-- 2. Standarization
/*
	- check columns if somthing is wrong
    - check datatypes
*/

select distinct company,  trim(company)
from layoffs_staging_2;
-- needs trimming
update layoffs_staging_2
set company = trim(company);

select distinct country
from layoffs_staging_2
order by 1;
-- like 'United States%' needs update
update layoffs_staging_2
set country = trim(trailing '.' from country);

select distinct location
from layoffs_staging_2
where location like 'Malm%'
order by 1;
-- like '%sseldorf' needs update , like 'Malm%' needs update
update layoffs_staging_2
set location = 'Dusseldorf'
where location like '%sseldorf';
update layoffs_staging_2
set location = 'Malmo'
where location like 'Malm%';

select distinct percentage_laid_off
from layoffs_staging_2
order by 1;
-- needs data type float
Alter table layoffs_staging_2
modify column percentage_laid_off float;

select `date`, str_to_date(`date`,"%m/%d/%Y")
from layoffs_staging_2;
-- change format and data type to date 
update layoffs_staging_2
set `date` = str_to_date(`date`,"%m/%d/%Y");

Alter table layoffs_staging_2
modify column `date` DATE;

-- 3. Deal with NULL or blank values
/*
	- a best bractice is to change all '' to null then deal with them
*/

select *
from layoffs_staging_2
where industry= '' or industry is null
order by 1;

select *
from layoffs_staging_2
where company='Carvana'
order by 1;

update layoffs_staging_2 
set industry = null
where industry= '' ;

select t1.company, t1.industry,t2.industry, t2.company company_2
from layoffs_staging_2 t1 join layoffs_staging_2 t2
	on t1.company=t2.company
where (t1.industry is null) and (t2.industry is  not null);

update layoffs_staging_2 t1 join layoffs_staging_2 t2
	on t1.company=t2.company
set t1.industry = t2.industry
where (t1.industry is null) and (t2.industry is  not null);

-- only one row for this company unfortunatly
select *
from layoffs_staging_2
where company like 'Ball%';


select *
from layoffs_staging_2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoffs_staging_2
where total_laid_off is null
and percentage_laid_off is null;


alter table layoffs_staging_2
drop column row_num;

select * from layoffs_staging_2;

