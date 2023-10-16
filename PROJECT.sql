--Data from covid deaths table

select location, date, total_cases,new_cases,total_deaths,population
from CovidAnalysis..coviddeaths$
where continent is not null
order by 1,2

--Total cases vs population ( shows likelihood of geting covid in a country)

select location,date,total_cases,population,(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as DeathPercentage
from CovidAnalysis..coviddeaths$

--Total case vs total deaths percentage( shows likelihood of dying if you contract covid in a country)

select location,date,total_cases,total_deaths,(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
from CovidAnalysis..coviddeaths$
order by 1,2


--Highest infection rates countries as comapared to population
 
select location,MAX(total_cases) as HighestInfectionCount,max((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100) as InfectionRate
from CovidAnalysis..coviddeaths$
group by location, population
order by  InfectionRate desc


--countries with highest death count per population

select location,population,max(cast(total_deaths as int)) as HighestDeaths,Max((CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0))*100) as percentagedeath
from CovidAnalysis..coviddeaths$
group by location,population
order by percentagedeath desc

--showing continents with the highest death count per population

select location,max(cast(total_deaths as int)) as HighestDeaths
from CovidAnalysis..coviddeaths$
where continent is null 
group by location
order by HighestDeaths desc


--GLOBAL NUMBERS
select sum(new_cases) as TotalCases,sum(new_deaths) as TotalDeaths,((SUM(new_deaths)) / NULLIF(SUM(CONVERT(float, new_cases)), 0))*100 as deathPercentage
from CovidAnalysis..coviddeaths$
where continent is not null
--group by date  
order by 1,2

--Looking at Total Population vs Vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from CovidAnalysis..coviddeaths$ dea
Join CovidAnalysis..covidvaccinations$ vac
 On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidAnalysis..coviddeaths$ dea
Join CovidAnalysis..covidvaccinations$ vac
 On dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidAnalysis..coviddeaths$ dea
Join CovidAnalysis..covidvaccinations$ vac
 On dea.location=vac.location
 and dea.date=vac.date

--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

drop view dbo.PercentPopulationVaccinated2
Create view dbo.PercentPopulationVaccinated2 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidAnalysis..coviddeaths$ dea
Join CovidAnalysis..covidvaccinations$ vac
 On dea.location=vac.location
 and dea.date=vac.date
where dea.continent is not null 
--order by 2,3
