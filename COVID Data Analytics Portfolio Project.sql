SELECT * 
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..covidVaccinations$
ORDER BY 3,4

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 as DeathPercentage
FROM PortfolioProject..covidDeaths$
WHERE location like '%paraguay%' and continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
SELECT location, date, population,total_cases, (CAST(total_cases AS decimal)/CAST(population AS decimal))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths$
--WHERE location like '%paraguay%'
 WHERE continent is not null
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(CAST(total_cases AS decimal)) AS HighestInfectionCount, MAX(CAST(total_cases AS decimal)/CAST(population AS decimal))*100 as PercentPopulationInfected
FROM PortfolioProject..covidDeaths$
--WHERE location like '%paraguay%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths AS decimal)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths$
--WHERE location like '%paraguay%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS decimal)) AS TotalDeathCount
FROM PortfolioProject..covidDeaths$
--WHERE location like '%paraguay%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(CAST(new_cases AS decimal)) AS TotalCases, SUM(CAST(new_deaths AS decimal)) AS TotalDeaths, SUM(CAST(new_deaths as decimal))/NULLIF(SUM(CAST(new_cases AS decimal)),0)*100 as DeathPercentage
FROM PortfolioProject..covidDeaths$
--WHERE location like '%paraguay%' and 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE vac.new_vaccinations is not null AND dea.continent is not null
ORDER BY 1,2,3

-- Use CTE

WITH PopVsVac (continen, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE vac.new_vaccinations is not null AND dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE vac.new_vaccinations is not null AND dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population) *100
FROM #PercentPopulationVaccinated

-- Creating VIEW to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(decimal,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE vac.new_vaccinations is not null AND dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated