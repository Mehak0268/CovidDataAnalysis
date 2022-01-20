--select *
--from ProfolioProject..CovidDeaths$
--order by 3,4

--select *
--from ProfolioProject..CovidVaccination$
--order by 3,4

select Location,date,total_cases,new_cases,total_deaths,population
from ProfolioProject..CovidDeaths$
order by 3,4

--Looking at total cases vs total deaths

select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProfolioProject..CovidDeaths$
where location like 'India'
order by 1,2

--Looking at the total cases vs population

select Location,date,total_cases,population ,(total_cases/population)*100 as CasePercentage
from ProfolioProject..CovidDeaths$
where location like 'India'
order by 1,2

--Looking at the countried with Highest Infection Rate compared to Population

select Location,MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as CasePercentage
from ProfolioProject..CovidDeaths$
--where location like 'India'
Group by Location,Population
order by CasePercentage desc

--showing countries with highest death count per population

select Location,MAX(cast (total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeaths$
where continent is not null
Group by Location,Population
order by TotalDeathCount desc

--Showing continents with highest death count

select continent,MAX(cast (total_deaths as int)) as TotalDeathCount
from ProfolioProject..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

select sum(new_cases)as totalCases, sum(cast (new_deaths as int)) as totalDeaths,sum(cast (new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from ProfolioProject..CovidDeaths$
--where location like 'India'
where continent is not null
--group by date
order by 1,2

--Totla population vs vaccinations

select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(convert (int,v.new_vaccinations)) OVER (Partition by v.location order by d.location,d.date) as TotalVaccinations

from ProfolioProject..CovidDeaths$ as d
join ProfolioProject..CovidVaccination$ as v
 on  d.location = v.location
 and  d.date = v.date
where d.continent is not null
order by 2,3


--USE CTE

with popVSvac (continent,location ,date , population ,new_vaccinations, TotalVaccinations)
as
(select d.continent,d.location,d.date,d.population,v.new_vaccinations
,sum(convert (int,v.new_vaccinations)) OVER (Partition by v.location order by d.location,d.date) as TotalVaccinations

from ProfolioProject..CovidDeaths$ as d
join ProfolioProject..CovidVaccination$ as v
 on  d.location = v.location
 and  d.date = v.date
where d.continent is not null
--order by 2,3
)
select * , (TotalVaccinations/population)*100 as percentVaccination
from popVSvac


--Temp Table

Drop Table if exists #PercentPopulatiionVaccinated
Create Table #PercentPopulatiionVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,New_vaccinations numeric,
TotalVaccinations numeric)

Insert Into #PercentPopulatiionVaccinated

select d.continent,d.location,d.date,d.population,v.new_vaccinations
,
sum(cast (v.new_vaccinations as bigint)) OVER (Partition by v.location order by d.location,d.date) as TotalVaccinations
from ProfolioProject..CovidDeaths$ as d
join ProfolioProject..CovidVaccination$ as v
 on  d.location = v.location
 and  d.date = v.date
--where d.continent is not null
--order by 2,3
select * , (TotalVaccinations/Population)*100 as percentVaccination
from #PercentPopulatiionVaccinated

--creating view

create view PercentPopulationVaccinated1 as
select d.continent,d.location,d.date,d.population,v.new_vaccinations
,
sum(cast (v.new_vaccinations as bigint)) OVER (Partition by v.location order by d.location,d.date) as TotalVaccinations
from ProfolioProject..CovidDeaths$ as d
join ProfolioProject..CovidVaccination$ as v
 on  d.location = v.location
 and  d.date = v.date
where d.continent is not null
--order by 2,3






