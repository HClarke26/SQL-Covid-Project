SELECT *
FROM CovidProject..CovidDeaths$
where continent is NOT NULL
ORDER BY 3, 4

--select *
--from CovidVaccinations$

-- select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
where continent is NOT NULL
ORDER BY 1, 2


-- Looking at total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths$
where location like '%united k%'
and continent is NOT NULL
ORDER BY 1, 2


-- Looking at total cases vs population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS CasesPercantage
FROM CovidProject..CovidDeaths$
--where location like '%united k%'
ORDER BY 1, 2


--Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM CovidProject..CovidDeaths$
--where location like '%united k%'
GROUP BY location, population
ORDER BY PercentOfPopulationInfected desc


--Looking at countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths$
--where location like '%united k%'
where continent is NOT NULL
Group by location
order by TotalDeathCount desc


--BY CONTINENT
--Showing the Continenst with the highest death counts
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidProject..CovidDeaths$
--where location like '%united k%'
where continent is NULL
Group by location
order by TotalDeathCount desc



--GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentageGlobal
FROM CovidProject..CovidDeaths$
--where location like '%united k%'
where continent is NOT NULL
group by date
ORDER BY 1, 2



--Looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--ORDER BY 2, 3



-- USE CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
--Looking at total population vs vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--ORDER BY 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--ORDER BY 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating view to store data for later visualisations 

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is NOT NULL
--ORDER BY 2, 3


select *
from PercentPopulationVaccinated