select * 
from PortfolioProject..CovidVaccinations

--GlobalNumbers 
--total population vs vaccination 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
from PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations AS vac 
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2, 3 

--rolling average of total_vaccinations 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) AS total_new_vaccinations  
from PortfolioProject..CovidDeaths$ AS dea
Join PortfolioProject..CovidVaccinations AS vac 
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null and vac.new_vaccinations is not null 
order by 2, 3


--rolling sum vs population 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--temp table

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--create a view

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
