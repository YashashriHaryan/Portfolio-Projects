
SELECT * FROM dbo.CovidDeaths
order by 3,4;


--SELECT * FROM CovidVaccinations
--order by 3,4;

select location, date, population, total_cases, new_cases, total_deaths
from CovidDeaths
order by location, date;

--Looking at the Total Deaths vs Total Cases
--Likelihood of dying if you contract covid in India
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentage_of_deaths
from CovidDeaths
where location like '%India%'
order by location, date;

--Looking at the Total Cases vs Population
--What percentage of population got covid
select location, date, total_cases, population, (total_cases/population)*100 as Case_Percentage
from CovidDeaths
where location like '%states%'
order by location, date;

select location, date, total_cases, population, (total_cases/population)*100 as Case_Percentage
from CovidDeaths
where location like '%Canada%'
order by location, date;


--Looking for the countries with the highest infected rate against the population
select location,population, MAX(total_cases) as HighestInfectedRate, MAX((total_cases/population))*100 as PercentagePopulationInfected
from CovidDeaths
group by location, population
order by PercentagePopulationInfected desc;

--Looking for the countries with the highest death rate compared to the population
select location, MAX(cast(total_deaths as int)) as HighestDeathRate
from CovidDeaths
where continent is not null
group by location
order by HighestDeathRate desc;

--Looking for continents with the highest death rate compared to the population
select continent, MAX(cast(total_deaths as int)) as HighestDeathRate
from CovidDeaths
where continent is not null
group by continent
order by HighestDeathRate desc;

--Showing the Total Cases and Total Deaths each day across the world
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2;

--Showing the Total Cases and Total Deaths across the world
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2;

---Looking at the total population vs Vaccinations across the world
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations 
from CovidDeaths cd
join CovidVaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 1,2,3;

--Calculating the vaccinations rolling on daily basis location wise  
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(cast (cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
order by 2,3;

--Using CTE(Common Table Expressions) to check the percent of vaccinations done.

WITH PopvsVac (continent,location,date,population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(cast (cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100 
from PopvsVac


--Creating view to store data  for later visualizations

create view PercentPopulationVaccinated as
select cd.continent, cd.location, cd.date,cd.population, cv.new_vaccinations, 
SUM(cast (cv.new_vaccinations as int)) OVER (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths cd
join CovidVaccinations cv 
on cd.location = cv.location
and cd.date = cv.date
where cd.continent is not null

select * from PercentPopulationVaccinated;

