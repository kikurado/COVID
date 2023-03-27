
--- THE LATEST DATE THIS DATA BASE WAS FULLY UPDATED IN WAS 2023-03-21

--- SELECTING THE COLUMNS TO WORK WITH

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeath
ORDER BY 1,2


--- LOOKING AT THE TOTAL_CASES VS THE TOTAL_DEATHS  IN EGYPT!

--- There is Almost 5 % Death Rate from the Total_cases in Egypt

SELECT location, MAX(date) most_recent_date , Max(total_cases) TOTAL_CASES,
		Max(total_deaths) TOTAL_DEATHS, (MAX(TOTAL_DEATHS)/MAX(TOTAL_CASES)) * 100 AS Death_Percentage
FROM CovidDeath
WHERE LOCATION = 'Egypt'
GROUP BY location
ORDER BY 5 DESC

--- COMPARING THE DEATH RATE BETWEEN EGYPT AND UNITED STATES, UNITED KINGDOM
--- WE CAN NOTICE THAT USA IS ALMOST 1% DEATH RATE, AND UK IS LESS THAN 1% EVEN WITH THEIR HIGH INFECTION RATE

SELECT location, MAX(date) most_recent_date , max(total_cases) total_cases
		, max(total_deaths) total_Deaths, ( MAX(total_deaths)/MAX(total_cases)) * 100 AS Death_Percentage
FROM CovidDeath
WHERE LOCATION IN ('United States', 'Egypt','united kingdom')
GROUP BY location

---- WHAT IS THE INFECTION RATE TO TOTAL EGYPTIAN POPULATION ?

/*Almost 0.5% were infected of the Egyptian Population ( based on patients arrived to public hospitals ) 
actual numbers might differ */

SELECT TOP 1 location, date, total_cases, population, ( total_cases/population) * 100 AS Infection_rate
FROM CovidDeath
WHERE LOCATION = 'EGYPT'
ORDER BY  2 DESC

-- WHAT IS THE LASTEST RECORD FOR THE TOTAL DEATHS FROM COVID IN EGYPT ?
-- THE LATEST UPDATE WAS IN 2023-03-21  AND TOTAL DEATHS WAS 24819

SELECT location, MAX(date) as Most_recent_date, MAX(total_deaths) Total_Deaths
FROM CovidDeath
WHERE LOCATION = 'EGYPT'
GROUP BY location

/* 
	COMPARISON BETWEEN THE INFECTION_RATE IN EGYPT, UNITED STATES, UNITED KINGDOM
	BOTH US AND UK HAVE A HUGE INFECTION_RATE ALMOST 1/3 OF IT'S POPULATION GOT INFECTED
	AGAIN FOR EGYPT THE ONLY DATA PROVIDED WAS BASED ON MINISTRY OF THE HEALTH 
*/
SELECT location, date, total_cases, population, ( total_cases/population) * 100 AS Infection_rate
FROM CovidDeath
WHERE LOCATION IN ('United States', 'Egypt','united kingdom') AND date = '2023-03-21'
ORDER BY 1, 2


--- WHAT IS THE HIGHEST COUNTRY IN THE INFECTION RATE ?
--- the answer is Cyprus with almost 73% infection rate to it's population 

SELECT location, date, total_cases, population, ( total_cases/population) * 100 AS Infection_rate
FROM CovidDeath
WHERE date = '2023-03-21'
ORDER BY 5 DESC


--- WHAT IS THE HIGHEST COUNTRY IN TOTAL DEATHS ?
--- UNITED STATE IS THE HIGHEST COUNTRY IN  OVER ALL TOTAL DEATHS

SELECT TOP(1) LOCATION, MAX(DATE) AS LATEST_TIME, MAX(TOTAL_DEATHS) TOTAL_DEATHS
FROM CovidDeath
WHERE CONTINENT IS NOT NULL
GROUP BY LOCATION
ORDER BY 3 DESC

--- WHAT IS THE HIGHEST COUNTRY IN TOTAL DEATH/TOTAL INFECTION ?
--- THE HIGHEST RATE OF DEATHS HAPPENS IN YEMEN AS ITS 18%

SELECT TOP (1) Location,MAX(TOTAL_CASES) [Total Cases]
		,MAX(TOTAL_DEATHS)[Total Deaths], MAX(total_deaths)/MAX(total_cases)*100 [Death Percentage]
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 4 DESC


--- WHICH CONTINENT HAS THE HIGHEST INFECTION RATE ?
--- The highest continent is Asia with total number of 295 Million case followed by Europe, NA, SA, Oceania and Africa!

SELECT location, continent, MAX(date) MOST_RECENT , MAX(total_cases) TOTAL_CASES
FROM CovidDeath
WHERE continent IS NULL AND location NOT IN ('UPPER MIDDLE INCOME','HIGH INCOME','EUROPEAN UNION','WORLD','LOWER MIDDLE INCOME','LOW INCOME')
GROUP BY location,continent
ORDER BY 4 DESC

--- THE CONTINENT WITH THE HIGHEST DEATH RATE 
--- Europe has the Most Death rates with almost 203 Million case, followed by Asia, NA, SA, Africa, Oceania

SELECT location, continent, MAX(date) MOST_RECENT , MAX(total_deaths) TOTAL_DEATHS
FROM CovidDeath
WHERE continent IS NULL AND location NOT IN ('UPPER MIDDLE INCOME','HIGH INCOME','EUROPEAN UNION','WORLD','LOWER MIDDLE INCOME','LOW INCOME')
GROUP BY location,continent
ORDER BY 4 DESC


--- Global Numbers  the Total Number of Infections around the world
--- The Agg. Total cases are roughly 761 Million Cases!

SELECT location, continent, MAX(date) MOST_RECENT , MAX(total_cases) TOTAL_CASES
FROM CovidDeath
WHERE location = 'World'
GROUP BY location,continent
ORDER BY 4 DESC

--- Global Number Total Number of Death Cases around the world
--- roughly 6.8 Million Death case!

SELECT location, continent, MAX(date) MOST_RECENT , MAX(total_deaths) TOTAL_DEATHS
FROM CovidDeath
WHERE location = 'WORLD'
GROUP BY location,continent
ORDER BY 4 DESC


--- TOTAL DEATH PERCENTAGE IS 0.9% FROM THE TOTAL CASES

SELECT MAX(TOTAL_CASES) TOTAL_CASES, MAX(TOTAL_DEATHS) TOTAL_DEATHS, MAX(TOTAL_DEATHS)/MAX(TOTAL_CASES) * 100 DEATH_PERCENTAGE
FROM coviddeath

--- TOTAL VACCINATION PER TOTAL POPULATION IN UNITED STATES.

WITH POPvsVAC (continent, location, date, population, new_vaccinations, total_vac)
as
(
		SELECT CV.continent, CV.location, CV.date, CD.population, CV.new_vaccinations,
				SUM(CAST(CV.NEW_VACCINATIONS AS float)) OVER (PARTITION BY CV.LOCATION ORDER BY CV.DATE) TOTAL_VAC
		FROM coviddeath CD
			INNER JOIN CovidVaccination CV
			ON CD.iso_code = CV.iso_code AND CD.location = CV.location AND CD.date = CV.date
		WHERE CV.continent IS NOT NULL
		--ORDER BY 2,3 
)

SELECT *, (TOTAL_VAC/POPULATION) * 100 TotalVac_per_PoP
FROM popvsvac
WHERE LOCATION = 'United STATES'
ORDER BY 2,3

--- PERCENTAGE OF VACCINATED CITIZEN PER THE POPULATION OF THE COUNTRY.

SELECT CV.CONTINENT, CV.LOCATION, CD.POPULATION, MAX(CAST(CV.PEOPLE_VACCINATED AS BIGINT))[TOTAL PEOPLE VACCINATED], 
		MAX(CAST (CV.PEOPLE_FULLY_VACCINATED AS BIGINT))[TOTAL FULLY VACCINATED],
		MAX(CAST (CV.PEOPLE_FULLY_VACCINATED AS BIGINT))/MAX(CD.POPULATION) * 100 [PERCENTAGE OF VACC PER COUNTRY'S POP]

FROM CovidVaccination CV
	INNER JOIN coviddeath CD
	ON CV.iso_code = CD.iso_code AND CV.location = CD.location AND CV.date = CD.date
WHERE CV.continent IS NOT NULL
GROUP BY CV.continent, CV.location,CD.population



--- WHAT IS THE PERCENTAGE OF VACCINATED PEOPLE IN 'UNITED STATES' AND 'UNITED KINGDOM'?

---  STEP 1.. CREATING A VIEW TO HAVE THAT PREVIOUS TABLE AS REFERENCE 

CREATE VIEW PERCENT_VAC_PER_POP AS 

SELECT CV.location, CV.continent, CD.POPULATION, MAX(CAST(CV.PEOPLE_VACCINATED AS BIGINT))[TOTAL PEOPLE VACCINATED], 
		MAX(CAST (CV.PEOPLE_FULLY_VACCINATED AS BIGINT))[TOTAL FULLY VACCINATED],
		MAX(CAST (CV.PEOPLE_FULLY_VACCINATED AS BIGINT))/MAX(CD.POPULATION) * 100 [PERCENTAGE OF VACC PER COUNTRY'S POP]

FROM CovidVaccination CV
	INNER JOIN coviddeath CD
	ON CV.iso_code = CD.iso_code AND CV.location = CD.location AND CV.date = CD.date
WHERE CV.continent IS NOT NULL
GROUP BY CV.continent, CV.location,CD.population

--- STEP 2. QUERING THE SPACIFIC DATA WE WANT TO EXTRACT FROM THE VIEW TABLE.
--- we can find there is 68% of USA's population is vaccinated while in UK it is 75%
SELECT *
FROM PERCENT_VAC_PER_POP
WHERE location IN ('UNITED STATES', 'UNITED KINGDOM')