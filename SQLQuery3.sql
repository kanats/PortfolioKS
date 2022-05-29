select *
from CovidDeathsNEW
order by 3,4

--Select data that we are going to be using

Select location, DATE, total_cases, new_cases, total_deaths, population
From CovidDeathsNEW
order by 1,2

-- Looking at total cases vs total deaths
-- ADDING ALIAS 'AS' DEATHPERCENTAGE

Select location, DATE, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From CovidDeathsNEW
order by 1,2

-- Location USA - Shosws the likelihood of dying if you contract covid in your country

Select location, DATE, total_cases, total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
From CovidDeathsNEW
Where location like '%states%'
order by 1,2

--Looking at total cases vs population
-- Shows the percentage of population got covid

Select location, DATE, total_cases,population, (total_cases/population)*100 as DeathPercentage
From CovidDeathsNEW
Where location like '%states%'
order by 1,2

-- Location like Kyrgyzstan

Select location, DATE, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From CovidDeathsNEW
 --re location like '%Kyrgyzstan%'
order by 1,2

--Looking at countries with highest infection rate vs population

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeathsNEW
Group by population, location
order by 1,2 

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeathsNEW
Group by population, location
order by PercentPopulationInfected desc

-- Looking at how many people died - countries with the highest deathcount per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is not null
Group by location
order by TotalDeathCount desc

Select *
From CovidDeathsNEW
Where continent is not null
order by 3,4 

-- Lets break things down by continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is not null
Group by continent
order by TotalDeathCount desc

Select location,  MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidDeathsNEW
Where continent is not null
Group by continent
order by TotalDeathCount desc



Select date, SUM(new_cases)-- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeathsNEW
Where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases), SUM(cast(new_deaths as int)) -- total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeathsNEW
Where continent is not null
Group by date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeathsNEW
Where continent is not null
Group by date
order by 1,2

-- Total cases vs total deaths + Percentage

Select SUM(total_cases) as total_cases, SUM(cast(total_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidDeathsNEW
Where continent is not null
Group by date
order by 1,2


-- Looking at total population vs total vaccinations

Select *
From CovidDeathsNEW dea
Join CovidVaccinationsNEW vac
	 On dea.location = vac.location
	 and dea.date = vac.date


	 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeathsNEW dea
Join CovidVaccinationsNEW vac
	 On dea.location = vac.location
	 and dea.date = vac.date
	 Where dea.continent is not null
	 order by 2,3
-- 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 , (RollingPeopleVaccinated
From CovidDeathsNEW dea
Join CovidVaccinationsNEW vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent, location, date,population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated
From CovidDeathsNEW dea
Join CovidVaccinationsNEW vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
 --order by 2,3
) 
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Create Table #PercentPopulationVac
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVac
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
 -- (RollingPeopleVaccinated
From CovidDeathsNEW dea
Join CovidVaccinationsNEW vac
	 On dea.location = vac.location
	 and dea.date = vac.date
Where dea.continent is not null
 --order by 2,3

 Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVac