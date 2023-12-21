SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL 

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL

SELECT location, date, population, total_cases,new_cases, total_deaths
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,population

--Total Covid cases & Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location,population

--Total Covid cases & the population in Africa

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Populationpercentage
FROM CovidDeaths
WHERE location = 'Africa' 
ORDER BY location,population

--Countries with the highest infection rate compared to their population

SELECT location, population, Max(total_cases) AS Highest_infection_rate, MAX((total_cases/population))*100 AS Infected_Populationpercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location,population
ORDER BY Infected_Populationpercentage DESC

--Countries with the highest death rate

SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc


--Continent with the highest death rate

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc


--Global Covid cases

SELECT date, SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 AS Deathpercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date


--JOIN BOTH TABLES

SELECT * 
FROM CovidDeaths AS D
JOIN CovidVaccinations AS V
ON D.date = V.date
AND D.location = V.location

--Total Population Vaccinated

SELECT D.continent, D.location, D.date, D.population AS total_population, V.new_vaccinations AS Vaccination, 
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS rollinpgeopleVaccinations  --ADDS UP CONSECUTIVE NUMBERS
FROM CovidDeaths AS D
JOIN CovidVaccinations AS V
ON D.date = V.date
AND D.location = V.location
WHERE D.continent is not null
ORDER BY 1,2,3


--USING CTE

WITH POPULATIONSVSVACCINATIONS(continent, location, date, population, new_vaccinations, rollingpeopleVaccinations)
AS(
SELECT D.continent, D.location, D.date, D.population AS total_population, V.new_vaccinations AS Vaccination, 
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS rollinpgeopleVaccinations  --ADDS UP CONSECUTIVE NUMBERS
FROM CovidDeaths AS D
JOIN CovidVaccinations AS V
ON D.date = V.date
AND D.location = V.location
WHERE D.continent is not null
)
SELECT *, (rollingpeopleVaccinations/population)*100 AS percentage
FROM POPULATIONSVSVACCINATIONS

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
DATE datetime,
Population numeric,
new_vaccinations numeric,
rollingpeopleVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT D.continent, D.location, D.date, D.population AS total_population, V.new_vaccinations AS Vaccination, 
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS rollinpgeopleVaccinations  --ADDS UP CONSECUTIVE NUMBERS
FROM CovidDeaths AS D
JOIN CovidVaccinations AS V
ON D.date = V.date
AND D.location = V.location
WHERE D.continent is not null

SELECT *, (rollingpeopleVaccinations/population)*100 AS percentage
FROM #PercentPopulationVaccinated


--CREATING VIEW FOR VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT D.continent, D.location, D.date, D.population AS total_population, V.new_vaccinations AS Vaccination, 
SUM(cast(v.new_vaccinations as int)) OVER (PARTITION BY D.location ORDER BY D.location,D.date) AS rollinpgeopleVaccinations  --ADDS UP CONSECUTIVE NUMBERS
FROM CovidDeaths AS D
JOIN CovidVaccinations AS V
ON D.date = V.date
AND D.location = V.location
WHERE D.continent is not null

SELECT * 
FROM PercentPopulationVaccinated