Select *
From PortfolioProject..CovidDeath$
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
Where continent is not null
From PortfolioProject..CovidDeath$
Order by 1,2
------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths / CAST(total_cases as decimal(38,2)))*100 as DeathPercentage
From PortfolioProject..CovidDeath$
Where location like '%states%'
Order by 1,2
------------------------------------------------------------------------------------------------------------------------

--Looking at Total Cases vs Population
Select location, date, total_cases, population, (total_cases / population)*100 as TotalCasePercentage
From PortfolioProject..CovidDeath$
Where location like '%states'
Order by 1,2
------------------------------------------------------------------------------------------------------------------------

--Looking at Countries with Highest Infection Rate compared to Population
Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath$
Group by location, population
Order by 4 desc
------------------------------------------------------------------------------------------------------------------------

-- Showing Countries with Highest Death Count per Population
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
Where continent is not null
Group by Location
Order by TotalDeathCount desc
------------------------------------------------------------------------------------------------------------------------

-- Showing continents with the highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
Where continent is not null
Group by continent
Order by TotalDeathCount desc
------------------------------------------------------------------------------------------------------------------------

--Global Numbers
Select SUM(new_cases) as TotalCases, 
	SUM(new_deaths) as TotalDeaths, 
	CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100 ELSE NULL END AS DeathPercentage
From PortfolioProject..CovidDeath$
Where continent is not null
Order by 1, 2
------------------------------------------------------------------------------------------------------------------------

-- Looking at Total Population vs Vaccinations
-- Use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal (38,2))) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac

------------------------------------------------------------------------------------------------------------------------
-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal (38,2))) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
------------------------------------------------------------------------------------------------------------------------

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as decimal (38,2))) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeath$ dea
Join PortfolioProject..CovidVaccination$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
------------------------------------------------------------------------------------------------------------------------

-- TABLES USED FOR TABLEAU DASHBOARD

-- Global Covid-19 Cases (As of 4/30/23)
1.
Select SUM(new_cases) as TotalCases, 
	SUM(new_deaths) as TotalDeaths, 
	CASE WHEN SUM(new_cases) > 0 THEN SUM(new_deaths)/SUM(new_cases)*100 ELSE NULL END AS DeathPercentage
From PortfolioProject..CovidDeath$
Where continent is not null
Order by 1, 2
------------------------------------------------------------------------------------------------------------------------

-- Total Deaths by Continent from Covid-19 (As of 4/30/23)
2.
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeath$
Where continent is null
and location not in ('World', 'European Union', 'International', 'High income', 'Upper middle income', 'Lower middle income', 'Low income')
Group by location
Order by TotalDeathCount desc
------------------------------------------------------------------------------------------------------------------------

-- Percent of Population Infected Per Country (As of 4/30/23) - World Map
3. 
Select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath$
Group by location, population
Order by PercentPopulationInfected desc

-- Percent of Population Infected (As of 4/30/23) - Filtered Countries with Projections
4.
Select location, population, date, max(total_cases) as HighestInfectionCount, Max((total_cases / population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeath$
Group by location, population, date
Order by PercentPopulationInfected desc




