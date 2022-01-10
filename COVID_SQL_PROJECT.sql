SELECT * 
FROM portfolioproject.coviddeaths 
WHERE location like 'World'
ORDER BY 3,4

-- Select Data that we are going to be using
-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolioproject.coviddeaths
WHERE location like '%korea%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM portfolioproject.coviddeaths
WHERE location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM portfolioproject.coviddeaths
GROUP by Location, population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
SELECT Location, MAX(CONVERT(total_deaths, SIGNED)) as TotalDeadCount
FROM portfolioproject.coviddeaths
WHERE continent <> '0' -- where continent is not 0 (NULL)
GROUP by Location
order by TotalDeadCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT continent, MAX(CONVERT(total_deaths, SIGNED)) as TotalDeadCount
FROM portfolioproject.coviddeaths
WHERE continent <> '0'
GROUP by continent
order by TotalDeadCount desc


-- SHOWING CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
SELECT continent, MAX(CONVERT((total_deaths/population), FLOAT)) as TotalDeadPerPopulation
FROM portfolioproject.coviddeaths
WHERE continent <> '0'
GROUP by continent
order by TotalDeadPerPopulation desc

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS Total_Cases, SUM(CONVERT(new_deaths, FLOAT)) AS Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 AS Death_Percentage
FROM portfolioproject.coviddeaths
WHERE continent <> '0'
GROUP BY date
order by 1,2

-- Total number not grouping by date
SELECT SUM(new_cases) AS Total_Cases, SUM(CONVERT(new_deaths, FLOAT)) AS Total_Deaths, SUM(CONVERT(new_deaths, FLOAT))/SUM(new_cases)*100 AS Death_Percentage
FROM portfolioproject.coviddeaths
WHERE continent <> '0'
order by 1,2

-- Looking at Total Population vs Vaccinations 
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent <> '0' and dea.location like '%albania%'
ORDER by 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
FROM PopvsVac

-- TEMP TABLE

CREATE TABLE PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent <> '0'
ORDER by 1,2,3

SELECT *, (RollingPeopleVaccinated/population)*100 as VaccinatedPopulationPercentage
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated2 as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(vac.new_vaccinations, FLOAT)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
FROM portfolioproject.coviddeaths dea
JOIN portfolioproject.covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent <> '0'
-- ORDER by 1,2,3


