/*
			- EXPLORATORY DATA ANALYSIS (EDA)
	- Understand the poupse of the data in hand & what are it's used for.
    - what features are most important?
    - explore the data to answer questions.
*/

-- starting with a view of the data
select *
from layoffs_staging_2;

-- inspecting layoffs
SELECT AVG(total_laid_off) AS avg_layoffs,
 MAX(total_laid_off) AS max_layoffs,
 MIN(total_laid_off) AS min_layoffs
FROM layoffs_staging_2;	

-- how many layoffs per company
SELECT company, COUNT(total_laid_off) AS num_layoffs
FROM layoffs_staging_2
GROUP BY company
ORDER BY num_layoffs DESC;

-- how many layoffs per month
SELECT DATE_FORMAT(date, '%Y-%m') AS month, COUNT(*) AS num_layoffs
FROM layoffs_staging_2
	where DATE_FORMAT(date, '%Y-%m') is not null
	GROUP BY month
	ORDER BY month;

-- show the time range of our dataset
select min(`date`) as `from`,max(`date`) as `to`
from layoffs_staging_2;
-- interval
select round(timestampdiff(month,min(`date`), max(`date`))/12) interval_years
from layoffs_staging_2;
-- seems like the most important fields are total_laid_off, percentage_laid_off, and funds_raised_millions accordingly
-- as they indicate the effects on employees and companies
-- let's explore these 

-- total layoffs by company orderring to see what companies laidoff the most employees
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by sum(total_laid_off) desc;
-- total layoffs by stage of company
select stage, sum(total_laid_off)
from layoffs_staging_2
group by stage
order by sum(total_laid_off) desc;
-- total layoffs by industry to see what industries laidoff the most employees
select industry, sum(total_laid_off)
from layoffs_staging_2
group by industry
order by sum(total_laid_off) desc;
-- total layoffs by country to see what countries laidoff the most employees
select country, sum(total_laid_off)
from layoffs_staging_2
group by country
order by sum(total_laid_off) desc;
-- total layoffs per year
select year(`date`), sum(total_laid_off)
from layoffs_staging_2
group by year(`date`)
order by year(`date`) desc;

-- percentage_laid_off by company orderring to see what companies laidoff the most porportions of the company
-- 1 means all employees were laidoff
select company, percentage_laid_off
from layoffs_staging_2
group by company
order by percentage_laid_off desc;
 
 -- millions raised per company
 select company , sum(funds_raised_millions) saved_millions
 from layoffs_staging_2
 group by company
 order by 2 desc;
-- millions raised per industry
 select industry , sum(funds_raised_millions) saved_millions
 from layoffs_staging_2
 group by industry
 order by 2 desc;
 
 -- let's see total layoffs per month for all companies
 select substring(`date`,1,7) `month`, sum(total_laid_off) total_layoffs
 from layoffs_staging_2
 where substring(`date`,1,7) is not null
 group by `month`
 order by 1;
 
 -- now let's try a rolling total 
with layoffs_per_month (`Month`,Total_Layoffs)as
(
 select substring(`date`,1,7) `month`, sum(total_laid_off) total_layoffs
 from layoffs_staging_2
 where substring(`date`,1,7) is not null
 group by `month`
 order by 1
)
select `Month`, Total_Layoffs,
sum(Total_Layoffs) over(order by `Month`) as rolling_total
from layoffs_per_month;

-- now rank companies based on how much layed off 
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by 2 desc;

with  layoffs_per_company (company,total_layoffs) as
(
select company, sum(total_laid_off)
from layoffs_staging_2
group by company
order by 2 desc
)
select company, total_layoffs,
dense_rank() over(order by total_layoffs desc) as `rank`
from layoffs_per_company;

-- now rank companies based on how much layed off per year
select company, year(`date`) as `year`, sum(total_laid_off) total_layoffs
from layoffs_staging_2
group by company,`year`
order by 3 desc;

with layoffs_per_company_yearly (company, `Year`, Total_Layoffs) as
(
select company, year(`date`) as `year`, sum(total_laid_off) total_layoffs
from layoffs_staging_2
group by company,`year`
order by 3 desc
)
, ranked_totals as
(
select company, `Year`, Total_Layoffs,
dense_rank() over(partition by `Year` order by Total_Layoffs desc) as `rank`
from layoffs_per_company_yearly
where `Year` is not null
)
select company, `Year`, Total_Layoffs,`rank`
from ranked_totals
where `rank`<=5;








