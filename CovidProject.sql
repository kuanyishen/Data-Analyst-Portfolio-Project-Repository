## Use Mac Command Line

cd desktop
cd DataProject
sqlite3 CovidProject.db

drop table if exists Death;
drop table if exists Vaccination;

create table Death(
	iso_code integer,	
	continent text,
	location text,
	date text,
	population integer,
	total_cases	real,
	new_cases integer,
	new_cases_smoothed integer,	
	total_deaths real,
	new_deaths integer,	
	new_deaths_smoothed integer,	
	total_cases_per_million integer,
	new_cases_per_million integer,
	new_cases_smoothed_per_million integer,	
	total_deaths_per_million integer,
	new_deaths_per_million integer,
	new_deaths_smoothed_per_million integer,	
	reproduction_rate integer,
	icu_patients integer,
	icu_patients_per_million integer,	
	hosp_patients integer,
	hosp_patients_per_million integer,	
	weekly_icu_admissions integer,
	weekly_icu_admissions_per_million integer,	
	weekly_hosp_admissions integer,
	weekly_hosp_admissions_per_million integer
);


create table Vaccination(
	iso_code integer,
	continent text,
	location text,
	date datetime,
	new_tests integer,
	total_tests_per_thousand integer,	
	new_tests_per_thousand integer,
	new_tests_smoothed integer,
	new_tests_smoothed_per_thousand integer,	
	positive_rate integer,
	tests_per_case integer,
	tests_units integer,
	total_vaccinations integer,
	people_vaccinated integer,
	people_fully_vaccinated integer,
	total_boosters integer,
	new_vaccinations integer,
	new_vaccinations_smoothed integer,	
	total_vaccinations_per_hundred integer,
	people_vaccinated_per_hundred integer,
	people_fully_vaccinated_per_hundred integer,
	total_boosters_per_hundred integer,
	new_vaccinations_smoothed_per_million integer,	
	new_people_vaccinated_smoothed integer,
	new_people_vaccinated_smoothed_per_hundred integer,	
	stringency_index integer,
	population_density integer,
	median_age integer,
	aged_65_older integer,
	aged_70_older integer,
	gdp_per_capita integer,
	extreme_poverty integer,
	cardiovasc_death_rate integer,
	diabetes_prevalence	integer,
	female_smokers integer,
	male_smokers integer,
	handwashing_facilities integer,	
	hospital_beds_per_thousand integer,
	life_expectancy integer,
	human_development_index integer,
	excess_mortality_cumulative_absolute integer,	
	excess_mortality_cumulative integer,
	excess_mortality integer,
	excess_mortality_cumulative_per_million integer
);

.separator ','

.import CovidDeath.csv Death
.import CovidVaccination.csv Vaccination

.mode column

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Death
where location like '%states%'
order by 1,2;

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid

select location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
from Death
where location like '%states%';

-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from Death
group by location, population
order by PercentPopulationInfected desc;

-- Show Countries with Highest Death Count per 

select location, population, max(cast(total_deaths as int)) as HighestDeathCount, max((total_deaths/population))*100 as PercentPopulationDied
from Death
group by location
order by PercentPopulationDied desc;

-- Exclude continent and world data, only keep country data

select location, max(cast(total_deaths as int)) as HighestDeathCount
from Death
where continent is not ''
group by location
order by HighestDeathCount desc;

-- Show continents with highest death count
select location, max(cast(total_deaths as int)) as HighestDeathCount
from Death
where continent is ''
group by location
order by HighestDeathCount desc;

-- Global data (order by date failed!)
select date as date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from Death
where continent is not ''
group by date
order by date;

-- Looking at Total Population vs Vaccinations

select Death.continent, Death.location, Death.date, Death.population, 
Vaccination.new_vaccinations, 
sum(Vaccination.new_vaccinations) over (partition by Death.location order by Death.location, Death.date) as RollingVaccination,
from Death
join Vaccination
on Death.location=Vaccination.location
and Death.date=Vaccination.date
where Death.continent is not ''
order by 2,3;

-- Use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccination) as
(select Death.continent, Death.location, Death.date, Death.population, Vaccination.new_vaccinations, 
sum(Vaccination.new_vaccinations) over (partition by Death.location order by Death.location, Death.date) as RollingVaccination
from Death
join Vaccination
on Death.location=Vaccination.location
and Death.date=Vaccination.date
where Death.continent is not ''
order by 2,3
)
select *, (RollingVaccination/population)*100 as VaccinationRate
from PopvsVac;

