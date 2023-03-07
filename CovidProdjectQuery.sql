
----Covid 19 Database: Data Exploration--- 
/*
Skills Utized: Joins, CTE's, Temp Tables, Windows Functions, 
Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT TOP 50 *
FROM CovidDeaths
Order by 3,4;

SELECT TOP 50 *
FROM CovidVaccination
Order by 3,4;

---Selecting Data to use---
-----??????________-----++++-----
SELECT top 50 D.location, D.date, D.total_cases, D.new_cases, D.total_deaths, V.population
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
Where D.location like '%poland%'
ORDER BY 1,2;

---Total cases vs Total Deaths in Poland---
---Risk of death if contracted covid within Poland---

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeathsPerCase
FROM CovidDeaths
Where location like '%poland%'
ORDER BY 1,2;

----Total cases vs Population---
----Percentage of popution that have had covid---


SELECT DISTINCT D.location, D.date, D.total_cases, V.population, (D.total_cases/V.population)*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
Where D.location like '%poland%'
ORDER BY 1,2;

----Looking at countries infection rate---

SELECT D.location, V.population, D.date, MAX(D.total_cases) as HighestInfectionCount, MAX((D.total_cases/V.population))*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
WHERE D.continent IS NOT NULL
GROUP BY V.population, D.location, D.date
ORDER BY 4 desc;

----Countries death count per Population---

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

----Total deaths per continent---

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is null
AND location NOT LIKE ('World', 'International', 'European Union')
AND location NOT LIKE '%income%' 
GROUP BY location
ORDER BY TotalDeathCount desc;

----Global numbers---
 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


---total population vs vaccination---

SELECT D.continent, D.location, D.date, V.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS RollingCountOfVaccinations
FROM CovidDeaths D
JOIN CovidVaccination V
	ON D.location=V.location
	AND D.date=V.date
WHERE D.continent is not null
AND D.location like '%Poland%'
ORDER BY 2,3


----Temp Table----- SECTION NOT NEEDED because of updated table
DROP TABLE IF exists #PopulationVaccinatedPercentage
Create Table #PopulationVaccinatedPercentage
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingCountOfVaccinations numeric
)
Insert into #PopulationVaccinatedPercentage
SELECT D.continent, D.location, D.date, V.population, V.new_vaccinations, 
SUM(CAST(V.new_vaccinations as bigint)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS rollingCountOfVaccinations
FROM CovidDeaths D
JOIN CovidVaccination V
	ON D.location=V.location
	AND D.date=V.date
WHERE D.continent is not null
--AND D.location like '%Poland%'
---ORDER BY 2,3

SELECT *, (RollingCountOfVaccinations/population)*100 as PercentageOfPopulationVaccinated
FROM #PopulationVaccinatedPercentage
WHERE continent is not null
AND location like '%Poland%'
ORDER BY 2,3

----WORK ON Above because it's grouping 1st, 2nd and 3nd Vaccinations together as a Percentage. Add NEW columns if possable.

SELECT  location, date, total_vaccinations, people_vaccinated, people_fully_vaccinated, total_boosters, people_fully_vaccinated_per_hundred, total_boosters_per_hundred 
FROM  CovidVaccination
WHERE location like '%Poland%'
ORDER BY 1,2;


---looking at smoking rate in countries copaired to covid deaths---

SELECT * 
FROM  CovidVaccination
WHERE location like '%Poland%'
ORDER BY 1,2;
SELECT * 
FROM  CovidDeaths
WHERE location like '%Poland%'
ORDER BY 1,2;

------------------
SELECT location, date, female_smokers, male_smokers, Sum(female_smokers + male_smokers) as total_smokes
FROM  CovidVaccination
WHERE location like '%Poland%'
ORDER BY 1,2;
------------------

----Creating Temp Table to perform Calculation

DROP TABLE IF exists #SmokingRateOfPopulation
Create Table #SmokingRateOfPopulation
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
total_cases numeric,
total_deaths numeric,
female_smokers numeric,
male_smokers   numeric,
)
Insert into #SmokingRateOfPopulation
SELECT D.continent, D.location, D.date, V.population, D.total_cases, D.total_deaths, V.female_smokers, V.male_smokers
FROM CovidDeaths D
JOIN CovidVaccination V
	ON D.location=V.location
	AND D.date=V.date;

SELECT location, MAX(total_cases) as TotalCaseCount, MAX(total_deaths) as TotalDeathCount,
MAX(total_deaths)/MAX(total_cases)*100 as TotalDeathsPerCasePercentage,
(SELECT AVG(c)
        FROM   (VALUES(MAX(female_smokers)),
                      (MAX(male_smokers))) T (c)) AS [PercemtageOfSmokers]
FROM #SmokingRateOfPopulation
WHERE location like '%Poland%'
GROUP BY location

---CREATE VIEW 
----Global numbers---
------1.
CREATE VIEW GlobalNumbers as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2;

----Total deaths per continent---
-------2.
SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is null
AND location not in ('World', 'International', 'European Union')
AND location NOT LIKE '%income%' 
GROUP BY location
ORDER BY TotalDeathCount desc;

----Looking at countries infection rate----
----------3.


----Looking at countries infection rate----
----------------4.
SELECT D.location, V.population, V.date, MAX(D.total_cases) as HighestInfectionCount,  MAX((D.total_cases/V.population))*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
--WHERE D.location not in ('World', 'International', 'European Union')
--AND D.location NOT LIKE '%income%' 
WHERE D.location like '%Poland%'
GROUP BY D.location, V.population, V.date
ORDER BY PercentageOfCasesPerPopulation desc;

----------------
-------------------
---------------------
SELECT TOP 50 *
FROM CovidDeaths
Order by 3,4;

SELECT TOP 50 *
FROM CovidVaccination
Order by 3,4;



SELECT D.location, V.population, D.date, D.total_cases, (D.total_cases/V.population)*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
WHERE D.continent is not null
AND D.location not in ('World', 'International', 'European Union')
AND D.location NOT LIKE '%income%' 
ORDER BY 1,2;

------Table 4

SELECT DISTINCT D.location, V.population, D.date, D.total_cases, (D.total_cases/V.population)*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
WHERE DATEPART(WEEKDAY, D.date) = 1
AND D.continent is not null
AND D.location not in ('World', 'International', 'European Union')
AND D.location NOT LIKE '%income%' 
--AND D.location like '%Poland%'
ORDER BY 1,2;
--ORDER BY 3;

SELECT date
FROM CovidDeaths
WHERE DAYOFWEEK(date) = 1
and location like '%Poland%';

SELECT date
FROM CovidDeaths
WHERE DATEPART(WEEKDAY, date) = 1
AND location like '%Poland%';
----------------------
--------------
----
----Table 5 total deaths vs cases 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeathsPerCase
FROM CovidDeaths
WHERE continent is not null
AND location not in ('World', 'International', 'European Union')
AND location NOT LIKE '%income%' 
ORDER BY 1,2;



---Make table temp with weekly date, because the dateset is very large and will speed up querys,


------Looking at the relationship between Total Deaths and total smokers in populations

SELECT location, MAX(total_cases) as TotalCaseCount, MAX(total_deaths) as TotalDeathCount,
MAX(total_deaths)/MAX(total_cases)*100 as TotalDeathsPerCasePercentage,
(SELECT AVG(c)
        FROM   (VALUES(MAX(female_smokers)),
                      (MAX(male_smokers))) T (c)) AS [PercemtageOfSmokers]
FROM #SmokingRateOfPopulation
---WHERE location like '%Poland%'
GROUP BY location
ORDER BY PercemtageOfSmokers desc;

