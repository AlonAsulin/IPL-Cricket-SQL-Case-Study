select *
from IPLPlayers

--Q1 Find the total spending on players for each team:
use [SQL Case Studies]
SELECT Team, Sum(Price_in_cr) as 'Total Spending'
from IPLPlayers
Group by Team
Order by 'Total Spending' DESC

-- Q2 Find the top 3 highest-paid 'ALL-rounders across all teams:
use [SQL Case Studies]
SELECT Top 3 Player, Team, Price_in_cr
from IPLPlayers 
where Role = 'All-rounder'
order by Price_in_cr DESC

-- Q3 Find the highest-priced player in each team:
WITH CTE_MP AS(
	Select Team, Max(Price_in_cr) as MaxPrice
	From IPLPlayers
	Group By Team
)
select i.Team, i.Player, c.MaxPrice
from IPLPlayers as i
join CTE_MP as c ON i.Team = c.Team
WHERE i.Price_in_cr=c.MaxPrice

-- Q4 Rank players by their price within each team and list the top 2 for every team:
WITH RankedPlayers as (
SELECT Player, Team, Price_in_cr, 
ROW_NUMBER() OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
FROM IPLPlayers
)
SELECT Player, Team, Price_in_cr, RankWithinTeam
FROM RankedPlayers 
Where RankWithinTeam <=2

--Q5 Find the most expensive player from each team, along with the second-most expensive player's name and price:
WITH RankedPlayers as (
SELECT Player, Team, Price_in_cr, 
ROW_NUMBER() OVER(PARTITION BY Team ORDER BY Price_in_cr DESC) AS RankWithinTeam
FROM IPLPlayers
)
SELECT Team, 
MAX(CASE WHEN RankWithinTeam = 1 THEN Player End) AS 'MostExpensivePlayer',
MAX(CASE WHEN RankWithinTeam = 1 THEN Price_in_cr End) AS 'HighestPrice',
MAX(CASE WHEN RankWithinTeam = 2 THEN Player End) AS 'SecondMostExpensivePlayer',
MAX(CASE WHEN RankWithinTeam = 2 THEN Price_in_cr End) AS 'SecondHighestPrice'
FROM RankedPlayers
GROUP BY Team

--Q6 Calculate the percentage contribution of each player's price to their team's total spending
SELECT Player, Team,Price_in_cr, 
	CAST(Price_in_cr/ (SUM(Price_in_cr) OVER (PARTITION BY Team)) * 100 as DECIMAL (10,2)) AS 'Contribution%'
FROM IPLPlayers

-- Q7 Classify the players as 'High, 'Medium' or 'Low' priced based on the following:
-- High: >15, Medium: between 5-15, Low: under 5
-- and find out the number of players in each bracket

use [SQL Case Studies];

WITH CTE_BR AS (
	SELECT Team, Player,Price_in_cr,
		CASE
			WHEN Price_in_cr > 15 THEN 'High'
			WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium'
			ELSE 'Low'
		END AS PlayersClass
	FROM IPLPlayers
)
SELECT Team,PlayersClass, Count(*) as 'NoInClass'
FROM CTE_BR
GROUP BY PlayersClass, Team
ORDER BY Team

--Q8 Find the average price of Indin players and compare it with overseas players using a subquery:
use [SQL Case Studies]
SELECT 'Indian' as PlayerType, 
(SELECT AVG(Price_in_cr) 
FROM IPLPlayers 
WHERE Type Like 'Indian%' ) as AVGPrice
UNION 
SELECT 'Overseas' as PlayerType,
(SELECT AVG(Price_in_cr) 
FROM IPLPlayers 
WHERE Type Like 'Overseas%' ) as AVGPrice

--Q9 Identify players who earn more than the average price in the team:
SELECT Player, Team, Price_in_cr
FROM IPLPlayers as p
WHERE Price_in_cr > (
	SELECT AVG(Price_in_cr) as AVGTeamPrice
	FROM IPLPlayers
	WHERE Team =p.Team)

--Q10 For each role, find the most expensive player and their price using a correlated subquery

SELECT Player, Team, Role, Price_in_cr
FROM IPLPlayers as p
WHERE Price_in_cr = (
						SELECT MAX(Price_in_cr)
						FROM IPLPlayers
						WHERE Role = p.Role
					)