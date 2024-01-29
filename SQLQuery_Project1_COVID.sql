--COVID ANALYTIC

--*********************************************************************************

--Loking at total_cases vs total_deaths. Finding global death percentage.

SELECT Location, date, CAST(total_cases AS FLOAT), total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeathes
ORDER BY 1,2

SELECT SUM(CAST(new_cases AS FLOAT)) as TotalCases, SUM(cast(new_deaths AS FLOAT)) as TotalDeaths, SUM(cast(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeathes
WHERE continent is not NULL
--GROUP BY date
--ORDER BY date DESC


--**********************************************************************************


-- Looking at Total cases vs Population

SELECT location, date, population, total_cases, (CAST(total_cases AS FLOAT)/CONVERT(float, population)*100) AS CasesPercentagePopul
FROM PortfolioProject..CovidDeathes
WHERE location = 'Ukraine'
ORDER BY 1,2

SELECT location, SUM(CAST(new_deaths AS FLOAT)) as TotalDeaths, CAST(population AS FLOAT) AS population, SUM(CAST(new_deaths AS FLOAT))/CAST(population AS FLOAT)*100 AS DeathPercentagePopul
FROM PortfolioProject..CovidDeathes
WHERE continent is not NULL
GROUP BY location, population
ORDER BY 4 DESC




--*********************************************************************************


--Looking at Total Population vs Vacctination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeathes dea
INNER JOIN PortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE. Finding percentage of people that were vaccinated across countries.
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeathes dea
INNER JOIN PortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac

--TEMP TABLE

DROP Table IF EXISTS #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeathes dea
INNER JOIN PortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
--WHERE dea.continent is not null
ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--CREATE VIEW TO STORE DATA FOR LATER VISUALISATIONS


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS float)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeathes dea
INNER JOIN PortfolioProject..CovidVaccinations vac
ON dea.date = vac.date AND dea.location = vac.location
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
