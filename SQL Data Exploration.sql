--select * 
--from CovidDeaths
--order by 3,4

select location,
       date,
	   total_cases,
	   new_cases,
	   total_deaths,
	   population
from CovidDeaths where continent is not null order by 1,2

--Looking at the total cases vs total deaths
--Shows the likelihood of dying should you contract Covid
select location,
       date,
	   total_cases,
	   total_deaths,
	   (total_deaths/total_cases) *100 as DeathPercentage
from CovidDeaths 
where location = 'South Africa' and continent is not null
order by 1,2


--Total Cases vs Population
-- Shows the % of population that got COVID
select location,
       date,
	   Population,
	   total_cases,
	   (total_cases/Population) *100 as InfectedPopulationPercent
from CovidDeaths 
where location = 'South Africa' and continent is not null
order by 1,2

--Countries with highest infection rate compared to population
select location,
       Population,
	   MAX(total_cases) as HighestInfections,
	   MAX((total_cases/Population)) *100 as InfectedPopulationPercent
from CovidDeaths 
where continent is not null
group by location,
       Population
order by InfectedPopulationPercent desc

--Countries with highest death rate compared to population
select location,
       Population,
       MAX(CAST(total_deaths as int)) as HighestDeaths,
	   MAX((CAST(total_deaths as int)/Population)) *100 as DeathsPopulationPercent
from CovidDeaths 
where continent is not null
group by location,Population
 order by DeathsPopulationPercent desc


--Totals Deaths by Continent
select continent,
       MAX(CAST(total_deaths as int)) as DeathCount
from CovidDeaths 
where continent is not null
group by continent
order by DeathCount desc

--Global Numbers by date
select date,
	   sum(new_cases) as total_cases,
	   sum(cast(new_deaths as int)) as total_deaths,
	   (sum(cast(new_deaths as int))/sum(new_cases)) *100 as DeathPercentage
from CovidDeaths 
where  continent is not null
group by date
order by 1,2

--Global Numbers Summary
select sum(new_cases) as total_cases,
	   sum(cast(new_deaths as int)) as total_deaths,
	   (sum(cast(new_deaths as int))/sum(new_cases)) *100 as DeathPercentage
from CovidDeaths 
where  continent is not null
order by 1,2

--Global Numbers by continent
select continent,
       sum(new_cases) as total_cases,
	   sum(cast(new_deaths as int)) as total_deaths,
	   (sum(cast(new_deaths as int))/sum(new_cases)) *100 as DeathPercentage
from CovidDeaths 
where  continent is not null
group by continent
order by 1,2


--Looking at total population vs vaccination
Select a.continent, 
       a.location, 
	   a.date, 
	   a.population, 
	   b.new_vaccinations,
	   SUM(CONVERT(bigint, b.new_vaccinations)) 
	          OVER (Partition by a.location order by a.location, a.date) as RollingVaccinatedPeople	   
from CovidDeaths a
join CovidVaccinations b
	On a.location = b.location
	and a.date = b.date
where  a.continent is not null
order by 2,3


--USE CTE
With PopVersusVacc (Continent, Location, date, population, new_vaccinations, RollingVaccinatedPeople)
AS
(Select a.continent, 
       a.location, 
	   a.date, 
	   a.population, 
	   b.new_vaccinations,
	   SUM(CONVERT(bigint, b.new_vaccinations)) 
	          OVER (Partition by a.location order by a.location, a.date) as RollingVaccinatedPeople	   
from CovidDeaths a
join CovidVaccinations b
	On a.location = b.location
	and a.date = b.date
where  a.continent is not null
--order by 2,3
) 
Select *,
       (RollingVaccinatedPeople/population)*100
from PopVersusVacc


--USE TEMP TABLE

Drop table if exists #PertentVaccinatedPeople
Select a.continent, 
       a.location, 
	   a.date, 
	   a.population, 
	   b.new_vaccinations,
	   SUM(CONVERT(bigint, b.new_vaccinations)) 
	          OVER (Partition by a.location order by a.location, a.date) as RollingVaccinatedPeople	  
into #PertentVaccinatedPeople
from CovidDeaths a
join CovidVaccinations b
	On a.location = b.location
	and a.date = b.date
where  a.continent is not null


--select * from #PertentVaccinatedPeople

Select *,
       (RollingVaccinatedPeople/population)*100
from #PertentVaccinatedPeople
