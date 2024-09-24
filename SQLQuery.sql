SELECT * FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null order by 3,4

--SELECT * FROM PortfolioProject.dbo.CovidVaccinations

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shoes Likelihood of dying if are infected by covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location LIKE '%india%'
order by 1,2

--Total Cases vs Population
--Shoes what percentage of population got covid
SELECT Location, date,  Population, total_cases, (total_cases/population) * 100 as InfectedPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
order by 1,2


--Countries with highest infection rate compared to population

SELECT Location,  Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as InfectedPopulationPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
group by location, population
order by InfectedPopulationPercentage desc


--Countries with highest Death Count per Population

SELECT Location,  Population, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
WHERE continent is not null 
group by location, population
order by TotalDeathCount desc

--W.R.T Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
WHERE continent is  not null 
group by continent
order by TotalDeathCount desc

--continent with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
WHERE continent is  not null 
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

SELECT   SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location LIKE '%india%'
where continent is not null
--group by date
order by 1,2


--Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
  ON dea.location =vac.location 
  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USING CTE

with PopVsVac(continent, location, date, population, new_vaccinations, PeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
  ON dea.location =vac.location 
  and dea.date = vac.date
where dea.continent is not null
)
select *, (PeopleVaccinated/population) * 100 from PopVsVac


--TEMP TABLE
DROP TABLE IF EXISTS #percentPopulationVaccinated
create table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccination numeric,
PeopleVaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
  ON dea.location =vac.location 
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select * ,(PeopleVaccinated/population) * 100 from #percentPopulationVaccinated


--creating view to store data for later visulizations

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as PeopleVaccinated
from PortfolioProject..CovidVaccinations vac
JOIN PortfolioProject..CovidDeaths dea
  ON dea.location =vac.location 
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select * from PercentPopulationVaccinated