-- COVID VIEWS

-- Nigeria Numbers
CREATE VIEW Nigeria_Stats AS
SELECT SUM(CAST(new_cases AS FLOAT)) AS Total_Cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)) AS DeathRate, MAX(CONVERT(FLOAT, vaccines.people_vaccinated)) AS Total_Vaccinations
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL AND deaths.location = 'Nigeria'

CREATE VIEW Nigeria_Stats_1 AS 
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

CREATE VIEW Death_Rate_Nigeria_Particular_Year AS
SELECT location, DATEPART(Year, date) AS YEAR, SUM(CAST(new_cases AS FLOAT)) AS total_cases_for_that_year, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths_for_that_year, SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DEATHPERCENTAGE_FOR_THE_YEAR
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date)
--ORDER BY 1, 2  DESC

CREATE VIEW Death_Rate_Nigeria_AsTheYearGoes AS
SELECT location, DATEPART(Year, date) AS YEAR, MAX(CAST(total_cases AS FLOAT)) AS total_cases_at_that_time, MAX(CAST(total_deaths AS FLOAT)) AS total_deaths_at_that_time, MAX(CAST(total_deaths AS FLOAT))/MAX(CAST(total_cases AS FLOAT))*100 AS DEATHPERCENTAGE_AS_THE_YEAR_GOES
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date)
--ORDER BY 1, 2  DESC

 
CREATE VIEW Infected_Rate_Particular_Year AS 
SELECT location, DATEPART(Year, date) AS YEAR, SUM(CAST(new_cases AS FLOAT)) AS total_cases_for_the_year, CAST(population AS FLOAT) AS population, SUM(CAST(new_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS INFECTED_PERCENTAGE_FOR_THE_YEAR
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date), population
--ORDER BY 1, 2  DESC

CREATE VIEW Infected_Rate_AsTheYearGoes AS
SELECT location, DATEPART(Year, date) AS Date, CAST(population AS FLOAT) AS POPULATION, MAX(CAST(total_cases AS FLOAT)) AS total_cases_at_the_time , MAX(CAST(total_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS InfectionRateAsTimeGoes
FROM CovidDeaths$
WHERE location = 'Nigeria'
GROUP BY location, DATEPART(Year, date), population
--ORDER BY 1, 2  DESC


-- Global Numbers
CREATE VIEW Global_Stats AS
SELECT SUM(CAST(new_cases AS FLOAT)) AS Total_Cases, SUM(CAST(new_deaths AS FLOAT)) AS Total_Deaths, 
SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT))*100 AS DeathRate
FROM CovidDeaths$ deaths
JOIN CovidVaccinations$ vaccines

  ON deaths.location = vaccines.location
  AND deaths.date = vaccines.date
WHERE deaths.continent is NOT NULL

CREATE VIEW Global_Stats_1 AS
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

CREATE VIEW Continent_DeathCount AS
SELECT continent, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


CREATE VIEW Countries_InfectionRate AS
SELECT continent, location, MAX(CAST(total_cases AS FLOAT)) AS TotalInfectionCount, CAST(population AS FLOAT) AS population, MAX(CAST(total_cases AS FLOAT))/CAST(population AS FLOAT)*100 AS InfectedPopulationRate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, Location, Population
--ORDER BY InfectedPopulationRate DESC

CREATE VIEW Countries_DeathRate AS
SELECT continent, location, SUM(CAST(new_cases AS FLOAT))  as total_cases, SUM(CAST(new_deaths AS FLOAT)) AS total_deaths, SUM(CAST(new_deaths AS FLOAT))/
             SUM(CAST(new_cases AS FLOAT))*100  AS DEATHPERCENTAGE
FROM CovidDeaths$
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY continent, location
--ORDER BY 1, 5 DESC

CREATE VIEW Countries_DeathRate_Per_Population AS
SELECT continent, location, MAX(CAST(total_deaths AS FLOAT)) AS TotalDeathCount, CAST(population AS FLOAT) AS population, MAX(CAST(total_deaths AS FLOAT))/CAST(population AS FLOAT)*100 AS DeathPopulationRate
FROM CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent, Location, Population
--ORDER BY DeathPopulationRate DESC