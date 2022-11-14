/*

Queries used for Tableau Project

*/



-- 1. 

.output TableauTable1.csv

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Death
where continent is not null 
order by 1,2;

.output stdout

-- 2. 

.output TableauTable2.csv

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From Death
--Where location like '%states%'
Where continent is '' 
and location not in ('World', 'European Union', 'International','High income', 'Upper middle income','Lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc;

.output stdout

-- 3.

.output TableauTable3.csv

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Death
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;

.output stdout

-- 4.

.output TableauTable4.csv

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Death
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;

.output stdout



