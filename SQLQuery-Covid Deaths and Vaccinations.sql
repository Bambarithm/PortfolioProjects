Select * 
from PortfolioProject..CovidDeaths$
where location is not null
order by 3,4



-- Show the death percentage
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
where location like '%senegal%'
order by 1,2

-- Looking at total cases vs population
-- Show the Infection population percentage
Select location, date, total_cases,population, (total_cases/population)*100 as InfectionPercentage
from PortfolioProject..CovidDeaths$
where location like '%senegal%'
order by 1,2


Select location, population,  MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths$
--where location like '%senegal%'
group by location, Population
order by InfectedPopulationPercentage desc

-- Show country with highest death count per population

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%senegal%'
where continent is not null
group by location
order by TotalDeathCount desc



-- Show total death count by continent
Select continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
--where location like '%senegal%'
 where continent is not null
group by continent
order by TotalDeathCount desc




-- GLOBAL NUMBERS

Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%senegal%' 
where continent is not null 
group by date
order by 1,2


-- Showing All total cases & death percentage regardless of location
Select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
--where location like '%senegal%' 
where continent is not null 
--group by date
order by 1,2


-- JOIN TABLES 


Select *
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location, dea.date)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location, dea.date)
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

with PopsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location,
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopsVac


-- OR USE TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location,
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--CREATE VIEW TO STORE DATA FOR DASHBOARDS/VIZZES


Creat View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by  dea.location,
	dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
on dea.location= vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * 
From PercentPopulationVaccinated