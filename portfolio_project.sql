SELECT * 
FROM portfolio_project.coviddeaths;

SELECT * 
FROM portfolio_project.coviddeaths
ORDER BY population ASC;

-- Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio_project.coviddeaths
ORDER BY location ASC, STR_TO_DATE(date, '%Y-%m-%d') ASC;

-- Looking at total cases vs total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS 'Death %'
FROM portfolio_project.coviddeaths
WHERE location = 'United States'
ORDER BY location ASC, STR_TO_DATE(date, '%Y-%m-%d') ASC;

-- Looking at total cases vs the population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, total_deaths, population, (total_cases/population)*100 AS 'Case %'
FROM portfolio_project.coviddeaths
WHERE location = 'United States'
ORDER BY location ASC, STR_TO_DATE(date, '%Y-%m-%d') ASC;

-- Country with maximum covid cases

SELECT location, total_cases
FROM portfolio_project.coviddeaths
ORDER BY total_cases DESC
LIMIT 1;

-- Countries with highest infection rate compared to population

SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX((total_cases/population))*100 AS population_infected
FROM portfolio_project.coviddeaths
-- WHERE location = 'United States'
GROUP BY location, population
ORDER BY population_infected DESC;

-- Countries with highest death count per population

SELECT location, MAX(total_deaths) AS total_death_count 
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'United States'
GROUP BY location
ORDER BY total_death_count DESC;

-- LETS BREAK THING DOWN BY CONTINENT 

SELECT continent, MAX(total_deaths) AS total_death_count 
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'United States'
GROUP BY continent
ORDER BY total_death_count DESC;

-- Showing the continents with highest death count

SELECT continent, MAX(total_deaths) AS total_death_count 
FROM portfolio_project.coviddeaths
WHERE continent IS NOT NULL
-- WHERE location = 'United States'
GROUP BY continent
ORDER BY total_death_count DESC;

-- GLOBAL NUMBERS

SELECT 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_new_deaths, 
    SUM(new_deaths) / SUM(new_cases) * 100 AS `Death %`
FROM 
    portfolio_project.coviddeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
	STR_TO_DATE(date, '%m/%d/%Y') ASC;

SELECT * 
FROM
	portfolio_project.covidvaccinations
WHERE continent = 'Asia';

SELECT *
FROM portfolio_project.coviddeaths d
JOIN portfolio_project.covidvaccinations v
ON d.location = v.location
AND d.date = v.date;

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS
    
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
-- SUM(v.new_vaccinations) OVER (PARTITION BY d.location) AS Rolling_sum
FROM 
	portfolio_project.coviddeaths d
JOIN
	portfolio_project.covidvaccinations v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- Total number of vaccinations everyday 

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_sum_people_vaccinated
FROM 
	portfolio_project.coviddeaths d
JOIN
	portfolio_project.covidvaccinations v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY d.location, d.date;

-- USE CTE

WITH rolling_sum_people_vaccinated AS (
	SELECT 
		d.continent,
		d.location,
		d.date,
		d.population,
		v.new_vaccinations,
		SUM(v.new_vaccinations) OVER (
			PARTITION BY d.location ORDER BY d.date
		) AS total_people_vaccinated
	FROM 
		portfolio_project.coviddeaths d
	JOIN
		portfolio_project.covidvaccinations v 
		ON d.location = v.location AND d.date = v.date
	WHERE d.continent IS NOT NULL
),
vaccination_percentage AS (
	SELECT 
		continent,
		location,
		date,
		population,
		new_vaccinations,
		total_people_vaccinated,
		(total_people_vaccinated / population) * 100 AS percent_people_vaccinated
	FROM rolling_sum_people_vaccinated
),
ranked_vaccinations AS (
	SELECT 
		continent,
		location,
		date,
		population,
		new_vaccinations,
		total_people_vaccinated,
		percent_people_vaccinated,
		ROW_NUMBER() OVER (
			PARTITION BY location ORDER BY location, percent_people_vaccinated DESC
		) AS row_num
	FROM vaccination_percentage
)

SELECT 
	continent,
	location,
	date,
	population,
	total_people_vaccinated,
	ROUND(percent_people_vaccinated, 2) AS `%_people_vaccinated`
FROM ranked_vaccinations
WHERE row_num = 1
ORDER BY continent, location, `%_people_vaccinated` DESC;

-- Creating views for storing data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(v.new_vaccinations) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_sum_people_vaccinated
FROM 
	portfolio_project.coviddeaths d
JOIN
	portfolio_project.covidvaccinations v 
ON d.location = v.location 
AND d.date = v.date
WHERE d.continent IS NOT NULL;
-- ORDER BY d.location, d.date

SELECT *
FROM
	percentpopulationvaccinated;