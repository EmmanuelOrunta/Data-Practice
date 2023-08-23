-- Loading my datasets


SELECT *
FROM CovidDeaths$
ORDER BY 3, 4

SELECT *
FROM CovidVaccinations$
ORDER BY 3, 4


--Choosing the data to work with
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1, 2 

-- Case Study 1: Total Cases vs Total Deaths - This case study is to find out the death percentage from those who have been infected from Covid from 2020 up until to April 2023 in Nigeria
-- It implies the chances of dieing from Covid if infected in Nigeria
SELECT location, date, CAST(total_cases AS FLOAT) AS total_cases, CAST(total_deaths AS FLOAT) AS total_deaths, (CAST(total_deaths AS FLOAT)/CAST(total_cases AS FLOAT))*100 AS DEATHPERCENTAGE
FROM CovidDeaths$
WHERE location = 'Nigeria'
ORDER BY 1, 2 

-- At the particular year
SELECT location, DATEPART(Year, date) AS YEAR, SUM(CAST(new_cases AS FLOAT)) AS total_cases_for_that_year, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths_for_that_year, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DEATHPERCENTAGE_FOR_THE_YEAR
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date)
--ORDER BY 1, 2  DESC


-- As the year goes by
SELECT location, DATEPART(Year, date) AS YEAR, MAX(CAST(total_cases AS FLOAT)) AS total_cases_at_that_time, MAX(CAST(total_deaths AS FLOAT)) AS total_deaths_at_that_time, MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(total_cases AS FLOAT))*100 AS DEATHPERCENTAGE_AS_THE_YEAR_GOES
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date)
ORDER BY 1, 2  DESC
 -- As the month goes by
SELECT location, DATEPART(Year, date) AS Year, DATEPART(Month, date) AS Month, MAX(CAST(total_cases AS FLOAT)) AS total_cases, MAX(CAST(total_deaths AS FLOAT)) AS total_deaths, MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(total_cases AS FLOAT))*100 AS DEATH_PERCENTAGE_AS_THE_MONTH_GOES
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date), DATEPART(Month, date)
ORDER BY 1, 2  DESC

-- Case Study 2: Total cases vs Population - This illustrates what percentage of the population got COVID any point in time between 2020 and April 2023
-- Percentage of infected people in Nigeria
SELECT location, DATEPART(Year, date) AS YEAR, SUM(CAST(new_cases AS FLOAT)) AS total_cases_for_the_year, CAST(population AS FLOAT) AS population, SUM(CAST(new_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS INFECTED_PERCENTAGE_FOR_THE_YEAR
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date), population
ORDER BY 1, 2  DESC

-- As the year goes by
SELECT location, DATEPART(Year, date) AS Date, CAST(population AS FLOAT) AS POPULATION, MAX(CAST(total_cases AS FLOAT)) AS total_cases_at_the_time , MAX(CAST(total_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS InfectionRateAsTimeGoes
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date), population
ORDER BY 1, 2  DESC


-- GLOBAL NUMBERS
-- Case Study 3: Countries with the Highest Infection Rate 
-- Implies the percentage of infected people in their countries when compared to their population
SELECT continent, location, MAX(CAST(total_cases AS FLOAT)) AS TotalInfectionCount, CAST(population AS FLOAT) AS population, MAX(CAST(total_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS InfectedPopulationRate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, Location, Population
ORDER BY InfectedPopulationRate DESC


-- Case Study 4: Countries with the Highest Death Rate per Population
-- Implies the percentage of people in countries who died from COVID when compared to their population
SELECT continent, location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount, CAST(population AS FLOAT) AS population, MAX(CAST(total_deaths AS FLOAT))/CAST(population AS FLOAT)*100 AS DeathPopulationRate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, Location, Population
ORDER BY DeathPopulationRate DESC

 -- Case Study 5: Continents with the Highest Death Count in a continent
SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Case Study 6: Contries with the Highest Death Rate based on their total cases
-- This illustrates the global numbers of the death rate in the whole world, i.e the rate at which people died from COVID
SELECT continent, location, SUM(CAST(new_cases AS FLOAT))  as total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/
             SUM(CAST(new_cases AS FLOAT))*100  AS DEATHPERCENTAGE
FROM CovidDeaths$
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY continent, location
ORDER BY 1, 5 DESC
  

-- CASE STUDY 7: Total population vs Vacccinations
-- This shows the amount of people vaccinated as the date goes by. It shows that its increases
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
         SUM(CONVERT(FLOAT,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) AS PeopleVaccinatedAsDayGoes
FROM  CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL AND vaccines.new_vaccinations IS NOT NULL
ORDER BY 2,3


-- WITH CTE

WITH PopsVSvac (Continent, Location, date, population, new_vaccinations, PeopleVaccinatedAsDayGoes)
AS
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
         SUM(CONVERT(FLOAT,vaccines.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) AS PeopleVaccinatedAsDayGoes
FROM  CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
)
SELECT *, (PeopleVaccinatedAsDayGoes/population)*100
FROM PopsVSvac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population NUMERIC,
New_vaccinations NUMERIC,
PeopleVaccinatedAsDayGoes numeric
) 
INSERT INTO #PercentPopulationVaccinated 
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
         SUM(CONVERT(FLOAT, vaccines.new_vaccinations)) OVER (PARTITION BY deaths.Location ORDER BY deaths.location, deaths.date) AS PeopleVaccinatedAsDayGoes
FROM  CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
 
SELECT *, (PeopleVaccinatedAsDayGoes/population)*100 AS VACCINATEDPERCENTAGE
FROM #PercentPopulationVaccinated
ORDER BY 2



-- Summary of the COVID Numbers From 2020 to April 2023 in the World
-- WORLD NUMBERS (TOTAL CASES, TOTAL DEATHS, DEATH RATE)
SELECT SUM(CAST(new_cases AS FLOAT)) AS Total_Cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathRate
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL

-- WORLD NUMBERS (WORLD POPULATION, TOTAL VACCINATED PEOPLE, PERCENTAGE OF VACCINATED PEOPLE)
WITH wp AS (
SELECT deaths.continent, deaths.Location, MAX(CAST(population AS FLOAT)) AS Population, MAX(CAST(people_vaccinated AS FLOAT)) AS total_people_vaccines
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL
GROUP BY deaths.continent, deaths.location
)SELECT SUM(Population) AS "WORLD POPULATION", SUM(total_people_vaccines) AS Total_Vaccines, SUM(total_people_vaccines)/SUM(Population) *100 AS VaccinatedRateWorldWide
FROM wp


-- NIGERIA NUMBERS (TOTAL CASES, TOTAL DEATHS, DEATH RATE)
SELECT SUM(CAST(new_cases AS FLOAT)) AS Total_Cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)) AS DeathRate, MAX(CONVERT(FLOAT, vaccines.people_vaccinated)) AS Total_Vaccinations
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL AND deaths.location = 'Nigeria'

-- NIGERIA NUMBERS (NIGERIA'S POPULATION, TOTAL VACCINATED PEOPLE, PERCENTAGE OF VACCINATED PEOPLE)
WITH wp AS (
SELECT deaths.continent, deaths.Location AS Location, MAX(CAST(population AS FLOAT)) AS Population, MAX(CAST(people_vaccinated AS FLOAT)) AS total_vaccines
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL AND deaths.location = 'Nigeria'
GROUP BY deaths.continent, deaths.location
)SELECT Location, Population, SUM(total_vaccines) AS Total_Vaccines, SUM(total_vaccines)/Population *100 AS VaccinatedRateWorldWide
FROM wp
GROUP BY Location, Population


