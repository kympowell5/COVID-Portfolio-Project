--View CovidDeaths and CovidVaccinations tables sorted by location and date columns
-- Exclude rows that show null for continent

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

-- Select the data

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Explore Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_death
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2

-- Explore Total Cases vs Population
-- What percentage of the population got Covid?

Select Location, date, total_cases, population, (total_cases/population)*100 as percent_population
From PortfolioProject..CovidDeaths
Where continent is not null
Where location like '%states%'
order by 1,2

Select Location, date, total_cases, population, (total_cases/population)*100 as percent_population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

-- Explore Countries with highest infection rate per population

Select Location, population, MAX(total_cases) as total_infection_count, MAX((total_cases/population))*100 as percent_total_cases
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location, population
order by percent_population desc

-- Explore Countries with highest death count per population

Select Location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by total_death_count desc

-- Explore continents with highest death count per population

Select location, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by total_death_count desc

-- Explore continents with highest death count per population

Select continent, MAX(cast(total_deaths as int)) as total_death_count
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by total_death_count desc


-- Explore total number of cases, total number of deaths, and percent deaths per day globally

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as percent_death
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2

-- Calculate total number of cases, total number of deaths, and percent deaths globally

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as percent_death
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2


-- Joining CovidDeaths and CovidVaccinations tables

Select *
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date

-- Explore total population vs vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 1, 2, 3

-- Rolling count of new vaccinations

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(Cast(vacc.new_vaccinations as bigint)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2, 3

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2, 3

-- Create CTE table for rolling_vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, rolling_vaccinations)
as 
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
Select *, (rolling_vaccinations/population)*100 as percent_rolling_vaccinations
From PopvsVac

-- Create TEMP table

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null

Select *, (rolling_vaccinations/population)*100 as percent_rolling_vaccinations
From #PercentPopulationVaccinated

-- Drop pre-existing table and create new one

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_vaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date

Select *, (rolling_vaccinations/population)*100 as percent_rolling_vaccinations
From #PercentPopulationVaccinated


-- Create view to store data for visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, SUM(CONVERT(bigint, vacc.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.date) as rolling_vaccinations
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vacc
	On death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null

Select *
From PercentPopulationVaccinated