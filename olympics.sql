--1. how many olympic games have been

select count(distinct games) from athlete_events


--2. List down all Olympics games held so far.

select distinct games, city from athlete_events
order by games


--3. Mention the total no of nations who participated in each olympics game?

select games, count(distinct region) as num_of_nations from noc_regions
join athlete_events
on athlete_events.noc=noc_regions.noc
group by games
order by games


--4. Which year saw the highest and lowest no of countries participating in olympics

with cte_participating as(
	select games, count(distinct region) as num_of_nations from noc_regions
	join athlete_events
	on athlete_events.noc=noc_regions.noc
	group by games
)


select concat((select top 1 games from cte_participating order by num_of_nations),' - ',
				(SELECT MIN(num_of_nations) FROM cte_participating)) as lowest_countries, 
			concat((select top 1 games from cte_participating order by num_of_nations desc),' - ',
				(SELECT max(num_of_nations) FROM cte_participating)) as highest_countries;


--5. Which nation has participated in all of the olympic games

select region, count(distinct games) as num_of_games from noc_regions
	join athlete_events
	on athlete_events.noc=noc_regions.noc
	group by region 
	having count(distinct games)=(select count(distinct games) from athlete_events)


--6. Identify the sport which was played in all summer olympics.

select distinct sport, count(distinct Games) as num_of_games, (select count(distinct games) 
from athlete_events
	where Games like '%Summer%') as total_games from athlete_events
	where Games like '%Summer%'
	group by sport
	having count(distinct Games)=(select count(distinct games) from athletes..athlete_events
	where Games like '%Summer%')


--7. Which Sports were just played only once in the olympics.

select distinct sport, count(distinct Games) as num_of_games
from athlete_events
	group by sport
	having count(distinct Games)=1
	order by sport


--8. Fetch the total no of sports played in each olympic games.

select distinct games, count(distinct sport) as num_of_sports
from athlete_events
	group by games
	order by num_of_sports desc


--9. Fetch oldest athletes to win a gold medal

select * from athlete_events 
	where age=(select max(age) from athletes..athlete_events WHERE medal = 'gold') and medal='gold'


--10. Find the Ratio of male and female athletes participated in all olympic games.

select concat('1 : ',round(convert(float, sum( CASE WHEN sex = 'm' THEN 1 END))/
convert(float, sum(CASE WHEN sex = 'f' THEN 1 END)),2)) as ratio
from athlete_events 


--11. Fetch the top 5 athletes who have won the most gold medals.

select top 5 name, team, count(medal) as total_gold_medals from athlete_events 
where medal='gold'
group by name, team
order by total_gold_medals  desc


--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

select top 5 name, team, count(medal) as total_medals from athlete_events 
where medal in('gold', 'silver', 'bronze')
group by name, team
order by total_medals desc


--13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

select top 5 region, count(medal) as number_of_medals from noc_regions
join athlete_events
on noc_regions.noc=athlete_events.noc
where medal in('gold', 'silver', 'bronze')
group by region
order by number_of_medals desc


--14. List down total gold, silver, bronze and total medals won by each country.

select region,
	   sum(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
	   SUM(CASE WHEN medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze' THEN 1 ELSE 0 END) AS total
	   from noc_regions
join athlete_events
on noc_regions.noc=athlete_events.noc
GROUP BY region
ORDER BY total DESC


--15. List down total, total gold, silver and bronze medals won by each country corresponding to each olympic games.

select games, region,
	   sum(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold,
       SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver,
       SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze,
	   SUM(CASE WHEN medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze' THEN 1 ELSE 0 END) AS total
	   from noc_regions
join athlete_events
on noc_regions.noc=athlete_events.noc
GROUP BY games, region
order by games, region



--16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

WITH 
  cte_gold AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  ),
  
  cte_silver AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  ),
  
  cte_bronze AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  )
  
SELECT
  g.games,
  CONCAT(g.region, ' - ', g.gold) AS max_gold,
  CONCAT(s.region, ' - ', s.silver) AS max_silver,
  CONCAT(b.region, ' - ', b.bronze) AS max_bronze
FROM cte_gold g
JOIN cte_silver s ON g.games = s.games
JOIN cte_bronze b ON g.games = b.games
WHERE g.gold = (SELECT MAX(gold) FROM cte_gold WHERE games = g.games)
  AND s.silver = (SELECT MAX(silver) FROM cte_silver WHERE games = s.games)
  AND b.bronze = (SELECT MAX(bronze) FROM cte_bronze WHERE games = b.games)
ORDER BY g.games;


--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

WITH 
  cte_gold AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  ),
  
  cte_silver AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS silver
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  ),
  
  cte_bronze AS (
    SELECT games, region, SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS bronze
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  ),

    cte_total AS (
    SELECT games, region, SUM(CASE WHEN medal IN ('Gold', 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total
    FROM noc_regions
    JOIN athlete_events ON noc_regions.noc = athlete_events.noc
    GROUP BY games, region
  )
  
SELECT
  g.games,
  CONCAT(g.region, ' - ', g.gold) AS max_gold,
  CONCAT(s.region, ' - ', s.silver) AS max_silver,
  CONCAT(b.region, ' - ', b.bronze) AS max_bronze,
  CONCAT(t.region, ' - ', t.total) AS max_total
FROM cte_gold g
JOIN cte_silver s ON g.games = s.games
JOIN cte_bronze b ON g.games = b.games
JOIN cte_total t ON g.games = t.games
WHERE g.gold = (SELECT MAX(gold) FROM cte_gold WHERE games = g.games)
  AND s.silver = (SELECT MAX(silver) FROM cte_silver WHERE games = s.games)
  AND b.bronze = (SELECT MAX(bronze) FROM cte_bronze WHERE games = b.games)
  AND t.total = (SELECT MAX(total) FROM cte_total WHERE games = t.games)
ORDER BY g.games;


--18. Which countries have never won gold medal but have won silver/bronze medals?

select region as country, sum(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS gold, 
	sum(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END) AS silver,
	sum(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END) AS bronze
	from noc_regions
	join athlete_events
		on noc_regions.noc=athlete_events.noc
		group by region
		having sum(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END)=0 and (sum(CASE WHEN medal = 'silver' THEN 1 ELSE 0 END)>0
		or sum(CASE WHEN medal = 'bronze' THEN 1 ELSE 0 END)>0)


--19. In which Sport/event, Georgia has won highest medals.

select top 1 region, sport, SUM(CASE WHEN medal in ('Gold', 'Silver','Bronze') THEN 1 ELSE 0 END) AS total_medals
from noc_regions
	join athlete_events
		on noc_regions.noc=athlete_events.noc
		where region = 'georgia'
		group by region, sport
		order by total_medals desc


--20. Break down all olympic games where Georgia won medal and how many medals in each olympic games

select region, sport, games, SUM(CASE WHEN medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze' THEN 1 ELSE 0 END) AS total_medals
from noc_regions
	join athlete_events
		on noc_regions.noc=athlete_events.noc
			where region = 'Georgia' and sport='wrestling'
			group by region, sport, games
			having SUM(CASE WHEN medal = 'Gold' OR medal = 'Silver' OR medal = 'Bronze' THEN 1 ELSE 0 END)>0
			order by total_medals desc

