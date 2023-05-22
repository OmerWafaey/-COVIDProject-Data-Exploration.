select * from CovidDeaths
where continent is not null 
order by 3,4

--select * from CovidVaccinations
--order by 3,4


select Location,date,population,total_cases,(total_cases/population)*100 as percentagepopulationinfected 
from CovidDeaths 
--where location like '%states%'
order by 1,2



--looking at countries with highest infection rate compared to population 

	select Location,population,max(total_cases) as highestinfectioncount,max((total_cases/population))*100 as percentagepopulationinfected
	from CovidDeaths 
	--where location like '%states%'
	group by Location,population
	order by percentagepopulationinfected desc

	

	--showing countries with highest death count per population
	select Location,max(cast(total_deaths as int)) as totaldeathcount 
	from CovidDeaths 
	where continent is not null 
	--where location like '%states%'
	group by Location
	order by totaldeathcount desc



	--let's breal things down my continent 
	-- showing continents with the highest death count per population  

	select continent,max(cast(total_deaths as int)) as totaldeathcount 
	from CovidDeaths 
	where continent is not null 
	--where location like '%states%'
	group by continent
	order by totaldeathcount desc
	

	-- global numbers
	
select  sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from CovidDeaths 
--where location like '%states%'
where continent is not null
--group by date
order by 1,2


--UseCTE

with popVsvac (continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations ))over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from CovidDeaths dea

join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select * , (Rollingpeoplevaccinated/population)*100
from popVsvac



--TEMP TABLE 
Drop table if exists #percentPopulationVaccinated
Create Table #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

insert into #percentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select * , (Rollingpeoplevaccinated/population)*100
from #percentPopulationVaccinated




--Creating view to store data for later visualizations 

Create view percentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date)
as Rollingpeoplevaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select *
from percentPopulationVaccinated