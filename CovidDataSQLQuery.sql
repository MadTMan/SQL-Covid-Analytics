/*
select *
from PortfolioProject..CovidDeaths
order by 3,4

select * 
from PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--total cases vs total deaths
-- probability of death if covid is contracted

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%desh%'
order by 1,2


--total cases vs Population

Select Location, date, total_cases, population, (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as CaseByPopulation
From PortfolioProject..CovidDeaths
where location like '%desh%'
order by 1,2


--Highest Infection by Population for a country

Select Location, max(total_cases) as HighestInfectionCount, population, max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100) as CaseByPopulation
From PortfolioProject..CovidDeaths
--where location like '%desh%'
group by Location, population
order by CaseByPopulation desc


--Highest Death by country

Select Location, max(cast(total_deaths as int)) as total_deaths
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by total_deaths desc

--Highest death per million

Select  location, max(cast(total_deaths_per_million as float)) as DeathsPerMillion
From PortfolioProject..CovidDeaths
--where continent is not null
group by location, total_deaths_per_million
order by DeathsPerMillion desc


--Highest death as per Percentage of Population

Select Location, population, cast(total_deaths as int), (cast(total_deaths as int)/population)*100 as  PercentageOfPopulation
From PortfolioProject..CovidDeaths
--where continent is not null
group by Location, population, total_deaths
order by total_deaths desc 


--DeathCount by location

Select location, max(cast(total_deaths as int)) as  TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc 

--DeathCount by continent

Select continent, max(cast(total_deaths as int)) as  TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc 

*/
--COVID-VACCINATIONS NUMBERS


--New Vaccination in Bangladesh
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalNewVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.location like '%desh%'
order by 2,3 

--Accross Continents

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalNewVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Percentage of People Vaccinated 
--Using CTE for Bangladesh

With PopvsVac(Continent, location, Date, Population, New_Vaccinations, TotalNewVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalNewVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.location like '%desh%'
--order by 2,3
)

Select * , (TotalNewVaccinations/population)*100 as Percentage_Population_Vaccinated 
from PopvsVac
order by Percentage_Population_Vaccinated desc

--For Rest of The World

With PopvsVac(Continent, location, Date, Population, New_Vaccinations, TotalNewVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalNewVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , (TotalNewVaccinations/Population)*100 as Percentage_Population_Vaccinated 
from PopvsVac
order by Percentage_Population_Vaccinated desc

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric, 
New_Vaccinatios numeric,  
TotalNewVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations as NewVaccinations, sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalNewVaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent is not null

Select * , (TotalNewVaccinations/Population)*100 as Percentage_Population_Vaccinated 
from #PercentPopulationVaccinated


--Creating View For Data Visualizations