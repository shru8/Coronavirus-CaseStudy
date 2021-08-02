--what % of population has gotten covid 

--timeline 1 Jan 2020 18th june 2021

select * from PortfolioProject..CovidDeaths$
order by date 

--selecting top 3 countries in each continent by SUM of new_cases
with sum_new_cases AS(
select location, 
      continent,
       SUM(new_cases) AS sumofnew
	   from PortfolioProject..CovidDeaths$
	   group by location, continent)

select location, continent,sumofnew, row_number() over (partition by continent order by sumofnew desc) as location_rank 
from sum_new_cases 

-- total death count per continent

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
and location not IN ('World' , 'European Union', 'International') 
Group by Location
order by TotalDeathCount desc

--KF:- Europe had the highest death count followed by SA, NA, Asia and Africa. 

--ratio of new_cases/total_cases in every location 
With Aggcases AS(
select location, SUM(new_cases) AS sum_new_cases, SUM(total_cases) AS sum_total_cases -- new_cases/total_cases as ratio 
from PortfolioProject..CovidDeaths$
where new_cases is not null and total_cases is not null and continent is not null
group by location)
select *, sum_new_cases/sum_total_cases AS ratio
from Aggcases
order by ratio desc 

--ranking the death count in every continent
With AggregateDeathct AS(
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
and location not IN ('World' , 'European Union', 'International') 
Group by Location) 

select location, TotalDeathCount, DENSE_RANK() over (order by totalDeathCount desc ) 
From AggregateDeathct

--KF: Europe has the highest death count followed by SA, NA, Asia, Africa, Oceania 

--percentage affected in every continent 
With aggregate_sum_and_population as(
select continent, SUM(total_cases) AS total_cases, MAX(population) AS current_population  
from PortfolioProject..CovidDeaths$ 
where continent IS NOT NULL 
group by continent
) 
select *, ROUND((total_cases/current_population)*100,4) AS percentage_affected
from aggregate_sum_and_population
order by percentage_affected desc 

-- % affected is highest in NA, followed by SA and Europe. This contrasts with the death count that's highest in Europe, SA and NA. 

--percentage affected in every location 
With need as(
select location, SUM(total_cases) AS total_cases, MAX(population) AS current_population 
from PortfolioProject..CovidDeaths$ 
where location NOT LIKE 'World'
group by location, population
) 
select *, ROUND((total_cases/current_population)*100,4) AS percentage_affected
from need 
order by percentage_affected asc

--Falkland Islands, Montserrat are amongst the locations unaffected, highest affected  are Czechia, San Marino, Montenegro and Andorra which have more than 5% of their population affected. 


--let's break things down by continent
--4. 
select continent, MAX(cast(total_deaths as int)) AS total_deaths, MAX(cast(total_cases as int)) AS total_cases 
from PortfolioProject..CovidDeaths$
where continent is not null 
group by continent
order by total_deaths desc 

--Highes total deaths in NA, followed by SA and Asia 


--which 'day' was the max cases? April 28th of this year about 9 Lakh. 

select date, sum(new_cases) AS total_new_cases   
from PortfolioProject..CovidDeaths$
where continent is not null AND new_cases is not null 
group by date
order by total_new_cases desc

--Key Achievements : April 28th of this year about 9 Lakh. 
--total death %

select sum(cast(new_cases as int)) AS total_new_cases, sum(cast(new_deaths as int)) AS total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 AS deathpercentage 
from PortfolioProject..CovidDeaths$
where continent is not null 
--group by date
order by 1,2 desc

--where did the first case of 2020 come?

select location, date, total_cases, total_deaths, new_cases, new_deaths 
from PortfolioProject..CovidDeaths$
where continent is not null AND total_cases is not Null
order by date   

--first case of the year 2020 was in South Korea on the 22 January, followed by the 'Outbreak' in China the same day.

--Percentage affected in buckets of 4 

With aggregate_sum_and_population as(
select location, SUM(total_cases) AS total_cases, MAX(population) AS current_population  
from PortfolioProject..CovidDeaths$ 
where continent IS NOT NULL
 group by location, population 
) 
select *, ROUND((total_cases/current_population), 4) * 100 AS percent_infected, NTILE(100) over (order by ROUND((total_cases/current_population), 4) *100) AS percentile
from aggregate_sum_and_population
order by percentile asc  

-- KF:- If were were to organize the percent_infected in quartiles; Vietnam, New Zealand, Taiwan are in the 25% low, Nepal, Malaysia, Pakistan, Finland are in mid 50%, Bulgaria, UAE, Turkey, are in the top 75% and finally sweden, lithuania, Peru, Chile,
--Liechtenstein are amongst locations worst affected with percent_affected being >2%. 

SELECT A.location,
 ROUND((total_cases/population), 4) * 100 AS Perc_Infected
, NTILE(4) over (order by ROUND((total_cases/population), 4) *100) AS Quar
 FROM PortfolioProject..CovidDeaths$ AS A
JOIN ( SELECT LOCATION, MAX(DATE) AS MAX_DATE
        from PortfolioProject..CovidDeaths$
        WHERE continent IS NOT NULL
        GROUP BY LOCATION 
        ) AS B 
ON B.LOCATION = A.LOCATION
AND B.MAX_DATE = A.DATE
WHERE A.continent IS NOT NULL

SELECT *,
ROUND((total_cases/population), 4) * 100 AS Perc_Infected
, NTILE(4) over (order by ROUND((total_cases/population), 4) *100) AS Quar
 FROM (
SELECT *,  RANK() OVER(PARTITION BY LOCATION ORDER BY DATE DESC) AS RNK
FROM PortfolioProject..CovidDeaths$ A
WHERE A.continent IS NOT NULL
) AS D
WHERE D.RNK = 1