SELECT *
FROM Projects.dbo.[owid-covid-data]
order by 3,4

Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
FROM Projects.dbo.[owid-covid-data]
order by 1,2

--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, new_cases, total_deaths, population
FROM Projects.dbo.[owid-covid-data]
order by 1,2

SELECT DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = 'owid-covid-data' AND 
     COLUMN_NAME = 'population'


ALTER TABLE dbo.[owid-covid-data] ALTER COLUMN total_cases float;  
GO 
ALTER TABLE dbo.[owid-covid-data] ALTER COLUMN new_cases float;  
GO
ALTER TABLE dbo.[owid-covid-data] ALTER COLUMN total_deaths float;  
GO
ALTER TABLE dbo.[owid-covid-data] ALTER COLUMN population float;  
GO

Select location, date, total_cases, new_cases, total_deaths, population, (total_deaths/total_cases)*100 AS deaths_percentage
FROM Projects.dbo.[owid-covid-data]
WHERE total_cases <> 0
order by 1,2

--Total cases vs population
--Shows what percantage of population has gotten covid
Select location, date, total_cases, population, (total_cases/population)*100 AS case_per_population
FROM Projects.dbo.[owid-covid-data]
--WHERE population <> 0
WHERE location like '%aze%'
order by 1,2

--Looking at countries with Highest Infection rate compared to population

Select location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS case_per_population
FROM Projects.dbo.[owid-covid-data]
WHERE population <> 0
--WHERE location like '%aze%'
Group by location, population
order by case_per_population Desc

--Showing highest death count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects.dbo.[owid-covid-data]
WHERE continent <> ' '
Group by location
order by TotalDeathCount Desc

SELECT *
FROM Projects..[owid-covid-data]
WHERE continent <> ' ' 

--Let's break things down by continent
--Showing the continent with the highest deaths count per population
Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Projects.dbo.[owid-covid-data]
WHERE continent = ' '
Group by location
order by TotalDeathCount Desc

--Global numbers
SELECT date, sum(cast(new_cases as float)) as TotalCases, sum(cast(new_deaths as float)) as TotalDeath, sum(cast(new_deaths as float))/sum(cast(new_cases as float))*100 as DeathPercantage
FROM Projects..[owid-covid-data]
WHERE new_cases <> 0
group by date
order by date

----Looking at total population vs vaccinations
SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(FLOAT, new_vaccinations)) OVER (PARTITION BY location ORDER BY location, date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated/population
From Projects..[owid-covid-data]
WHERE continent <> ' '
order by 1,2

----Use CTE
with PopVsVas (continent, location, date, population , new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT continent, location, date, population, new_vaccinations, SUM(CONVERT(FLOAT, new_vaccinations)) OVER (PARTITION BY location ORDER BY location, date) as RollingPeopleVaccinated
 --RollingPeopleVaccinated/population
From Projects..[owid-covid-data]
WHERE continent <> ' '
--order by 1,2
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVas
Where population <> 0 

----Temp table
Drop table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT continent, location, date, CONVERT(float, population), CONVERT(float,new_vaccinations), SUM(CONVERT(FLOAT, new_vaccinations)) OVER (PARTITION BY location ORDER BY location, date) as RollingPeopleVaccinated
 --RollingPeopleVaccinated/population
From Projects..[owid-covid-data]
--WHERE continent <> ' '

SELECT *, (RollingPeopleVaccinated/CONVERT(float,population))*100
FROM #PercentPopulationVaccinated
Where population <> 0 

----Creating view to store data for later visualizations
CREATE View PercentPopulationVaccinated as
SELECT continent, location, date, new_vaccinations, population, SUM(CONVERT(FLOAT, new_vaccinations)) OVER (PARTITION BY location ORDER BY location, date) as RollingPeopleVaccinated
 --RollingPeopleVaccinated/population
From Projects..[owid-covid-data]
WHERE continent <> ' '

SELECT *
FROM Projects..PercentPopulationVaccinated
