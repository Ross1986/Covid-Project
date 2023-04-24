
----Covid 19 Database: Data Exploration--- 
/*
Skills Utized: Joins, Windows Functions, 
Aggregate Functions, Creating Views, Converting Data Types
*/

SELECT TOP 50 *
FROM CovidDeaths
Order by 3,4;

SELECT *
FROM CovidVaccination
where location = 'poland'
Order by 3,4;

---Selecting Data to use---

SELECT DISTINCT top 50 D.location, D.date, D.total_cases, D.new_cases, D.total_deaths, V.people_vaccinated, V.population
FROM CovidDeaths D
LEFT JOIN CovidVaccination V ON D.location = V.location
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

----Countries death count per total death count---

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
Where continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

----Total deaths per continent---

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is null
AND location not in ('World', 'International', 'European Union')
AND location not like '%income%' 
GROUP BY location

----Global numbers---
 
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
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


---- Creating View to store data for later visualizations

----Table 1 Global numbers---

CREATE VIEW GlobalNumbers as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
--ORDER BY 1,2;
 

----Table 2 Total deaths per continent---

CREATE VIEW TotalDeathsPerContinent as
SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths
WHERE continent is null
AND location not in ('World', 'International', 'European Union')
AND location NOT LIKE '%income%' 
GROUP BY location
ORDER BY TotalDeathCount desc;

----Table 3 Looking at countries infection rate----

CREATE VIEW InfectionRates as
SELECT D.location, V.population, V.date, MAX(D.total_cases) as HighestInfectionCount,  MAX((D.total_cases/V.population))*100 as PercentageOfCasesPerPopulation
FROM CovidDeaths AS D
INNER JOIN CovidVaccination AS V ON D.location = V.location
--WHERE D.location not in ('World', 'International', 'European Union')
--AND D.location NOT LIKE '%income%' 
WHERE D.location like '%Poland%'
GROUP BY D.location, V.population, V.date
ORDER BY PercentageOfCasesPerPopulation desc;


----Table 4 total deaths vs cases 

CREATE VIEW DeathsVsCases as
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageOfDeathsPerCase
FROM CovidDeaths
WHERE continent is not null
AND location not in ('World', 'International', 'European Union')
AND location NOT LIKE '%income%' 
ORDER BY 1,2;
