select *
from dbo.CovidDeaths
Where continent is not null
order by 3,4

--select *
--from dbo.CovidVaccinations
--order by 3,4 (order is by the column)


select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
Where continent is not null
order by 1,2

-- looking at total cases vs total deaths
-- shows likelihood of dying from Covid contraction
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from dbo.CovidDeaths
Where location like '%states%'
 and continent is not null
order by 1,2


--looking at total cases vs population
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from dbo.CovidDeaths
Where continent is not null
--Where location like '%states%'
order by 1,2

--countries with highest infection rate compared to population
select location, population, Max(total_cases)as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from dbo.CovidDeaths
--Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc


--- countries with highest deathcount per population
select location,  Max(cast(total_deaths as Int))as TotalDeathCount
from dbo.CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc


--Break data down by continent--
select location,  Max(cast(total_deaths as Int))as TotalDeathCount
from dbo.CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--showing continents with hightest death count
select location,  Max(cast(total_deaths as Int))as TotalDeathCount
from dbo.CovidDeaths
--Where location like '%states%'
Where continent is null
Group by location
order by TotalDeathCount desc


--global numbers showing per date
select date, sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from dbo.CovidDeaths
--Where location like '%states%'
 where continent is not null
 group by date
order by 1,2


-- death % per new deaths over new cases
select sum(new_cases) as new_cases, sum(cast(new_deaths as int)) as new_deaths, Sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from dbo.CovidDeaths
--Where location like '%states%'
 where continent is not null
 --group by date
order by 1,2


--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated, --(RollingPeopleVaccinated/dea.population) * 100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  order by 2,3

  --Use CTE

  With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
  as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population) * 100
 From dbo.CovidDeaths dea
 join dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  )
  select *, (RollingPeopleVaccinated/population) * 100
  from PopvsVac


  --Use Temp table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population) * 100
 From dbo.CovidDeaths dea
 join dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3
  
  select *, (RollingPeopleVaccinated/population) * 100
  from #PercentPopulationVaccinated



  --Create view to store data for visualization later

 create view PercentPopulationVaccinated as
  select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date)
  as RollingPeopleVaccinated --(RollingPeopleVaccinated/dea.population) * 100
  From dbo.CovidDeaths dea
  join dbo.CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
  where dea.continent is not null
  --order by 2,3

  select *
  from PercentPopulationVaccinated