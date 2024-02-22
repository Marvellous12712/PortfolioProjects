SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3, 4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select the Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND location LIKE '%nigeria%'
ORDER BY 1, 2 DESC

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

SELECT location, date, population,total_cases,  (total_cases/population)*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND location LIKE '%nigeria%'
ORDER BY 1, 2 DESC

-- Looking at countries with Highest Infection Rate compared to population 

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL AND location LIKE '%nigeria%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with Highest Death Count Per Population

SELECT location, MAX(Total_Deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
--AND location LIKE '%nigeria%'
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS UP BY CONTINENT 

-- Showing continent with the Highest Death Count per population

SELECT continent, MAX(Total_Deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
--AND location LIKE '%nigeria%'
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS 

SELECT SUM(New_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL 
--AND location LIKE '%nigeria%'
--GROUP BY date
ORDER BY 1, 2 DESC

--Looking at Total Population vs Vaccination 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
WHERE dea.Continent IS NOT NULL 
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
WHERE dea.Continent IS NOT NULL 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac


--TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
--WHERE dea.Continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON  dea.location = vac.location
WHERE dea.Continent IS NOT NULL 
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated