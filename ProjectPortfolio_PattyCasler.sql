--Create table CovidVaccinations
--(iso_code varchar(50),
--continent varchar(50),
--location varchar(50),
--date_reported Date,
--new_tests int,
--total_tests int,
--total_tests_per_thousand int,
--new_tests_per_thousand int,
--new_tests_smoothed int,
--new_tests_smoothed_per_thousand int,
--positive_rate int,
--tests_per_case int,
--tests_units varchar(50),
--total_vaccinations int,
--people_vaccinated int,
--people_fully_vaccinated int,
--new_vaccinations int,
--new_vaccinations_smoothed int,
--total_vaccinations_per_hundred int,
--people_vaccinated_per_hundred int,
--people_fully_vaccinated_per_hundred int,
--new_vaccinations_smoothed_per_million int,
--stringency_index int,
--population_density int,
--median_age int,
--aged_65_older int,
--aged_70_older int,
--gdp_per_capita int,
--extreme_poverty int,
--cardiovasc_death_rate int,
--diabetes_prevalence int,
--female_smokers int,
--male_smokers int,
--handwashing_facilities int,
--hospital_beds_per_thousand int,
--life_expectancy int,
--human_development_index int)

--select *
--From Project.dbo.CovidVaccinations

--Select *
--From Project.dbo.CovidDeaths

Select *
From Project.dbo.CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From Project.dbo.CovidVaccinations
--Order by 3,4


Select location, date_reported, total_cases, new_cases, total_deaths, population
From Project.dbo.CovidDeaths
Order by 1,2

--Looking at Total cases vs total deaths

Select location, date_reported, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From Project.dbo.CovidDeaths
where location like '%states%'
Order by 1,2

--Looking at Total Cases vs. Population
--Shows what percentage of Population got Covid

Select location, date_reported, population, total_cases, (total_cases/Population)*100 as Percentinfected
From Project.dbo.CovidDeaths
where location like '%states%'
Order by 1,2


--Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HigestInfectionCount, Max((total_cases/Population))*100 as PercentPopulationInfected
From Project.dbo.CovidDeaths
--where location like '%states%'
Group by Location, population
Order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population

Select location, Max(Cast(Total_deaths as int)) as TotalDeathCount
From Project.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break things down by Continent
--Showing continents with the highest death count per population

Select continent, Max(Cast(Total_deaths as int)) as TotalDeathCount
From Project.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select date_reported, Sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totaldeaths, sum(Cast(new_deaths as int))/Sum(New_cases)*100 as deathpercentage
From Project.dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
group by date_reported
Order by 1,2

Select date_reported, Sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths
From Project.dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
group by date_reported
Order by 1,2

Select date_reported, sum(cast(new_deaths as int))/Sum(new_cases)*100 as deathpercentage
From Project.dbo.CovidDeaths
--where location like '%states%'
--Where continent is not null
group by date_reported
Order by 1,2


--Looking at Total Population vs. Vaccinations

Select dea.continent, dea.location, dea.date_reported, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date_reported) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project.dbo.CovidDeaths dea
Join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date_reported = vac.date_reported
where dea.continent is not null
Order by 2,3

--Use CTE

with PopvsVac (continent, Location, Date_reported, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date_reported, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date_reported) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project.dbo.CovidDeaths dea
Join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date_reported = vac.date_reported
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date_reported datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date_reported, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date_reported) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project.dbo.CovidDeaths dea
Join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date_reported = vac.date_reported
where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date_reported, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date_reported) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from Project.dbo.CovidDeaths dea
Join Project.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date_reported = vac.date_reported
where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated