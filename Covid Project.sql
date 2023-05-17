SELECT *
FROM PortfolioProject..CovidDeath$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
WHERE continent IS NOT NULL
From PortfolioProject..CovidDeath$
ORDER BY 1,2
------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths / CAST(total_cases as decimal(38,2)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeath$
WHERE location LIKE '%states%'
ORDER BY 1,2
------------------------------------------------------------------------------------------------------------------------
--Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases / population)*100 AS TotalCasePercentage
FROM PortfolioProject..CovidDeath$
WHERE location LIKE '%states'
ORDER BY 1,2
------------------------------------------------------------------------------------------------------------------------
--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath$
GROUP BY location, population
ORDER BY 4 desc
------------------------------------------------------------------------------------------------------------------------
-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
------------------------------------------------------------------------------------------------------------------------
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC
------------------------------------------------------------------------------------------------------------------------
--Global Numbers

SELECT SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100 ELSE NULL END AS DeathPercentage
FROM PortfolioProject..CovidDeath$
WHERE continent IS NOT NULL
ORDER BY 1, 2
------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Population vs Vaccinations using CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal (38,2))) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

------------------------------------------------------------------------------------------------------------------------
-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS DECIMAL (38,2))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
------------------------------------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS DECIMAL (38,2))) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeath$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
------------------------------------------------------------------------------------------------------------------------
-- TABLES USED FOR TABLEAU DASHBOARD
-- Global Covid-19 Cases (As of 4/30/23)

1.
SELECT SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100 ELSE NULL END AS DeathPercentage
FROM PortfolioProject..CovidDeath$
WHERE continent IS NOT NULL
ORDER BY 1, 2
------------------------------------------------------------------------------------------------------------------------
-- Total Deaths by Continent from Covid-19 (As of 4/30/23)

2.
SELECT location, SUM(CAST(new_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeath$
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
GROUP BY location
ORDER BY TotalDeathCount DESC
------------------------------------------------------------------------------------------------------------------------
-- Percent of Population Infected Per Country (As of 4/30/23) - World Map

3. 
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath$
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC
------------------------------------------------------------------------------------------------------------------------
-- Percent of Population Infected (As of 4/30/23) - Filtered Countries with Projections

4.
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeath$
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

