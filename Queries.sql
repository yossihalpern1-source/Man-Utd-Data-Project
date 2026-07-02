--Team Stats Data Table
CREATE TABLE team_match_stats (
    manager VARCHAR(100),
    match_id INTEGER PRIMARY KEY,
    opponent VARCHAR(100),
    opponent_league_position INTEGER,
    league_position INTEGER,
    home VARCHAR(3), 
    result CHAR(1),
    goals_at_half_time INTEGER,
    goals_at_full_time INTEGER,
    possession_pct REAL,
    total_shots INTEGER,
    shots_on_target INTEGER,
    shots_inside_box INTEGER,
    shots_outside_box INTEGER,
    woodwork INTEGER,
    total_crosses INTEGER,
    crosses_success_pct REAL,
    total_passes INTEGER,
    pass_success_pct REAL,
    backward_passes INTEGER,
    forward_passes INTEGER,
    long_passes INTEGER,
    long_passes_succes_pct REAL,
    touches_in_box INTEGER,
    tackles_won INTEGER,
    tackle_succes_pct REAL,
    interceptions INTEGER,
    clearances INTEGER,
    total_dribbles INTEGER,
    dribbles_success INTEGER,
    fouls_committed INTEGER,
    offsides INTEGER,
    yellow_cards INTEGER,
    red_cards INTEGER,
    distance_covered_km DOUBLE PRECISION,
    walking_pct REAL,
    jogging_pct REAL,
    sprinting_pct REAL,
    xg DOUBLE PRECISION,
    xg_openplay DOUBLE PRECISION,
    xg_setplay DOUBLE PRECISION,
    xa DOUBLE PRECISION,
    aerials_won INTEGER,
    aerials_won_pct REAL,
    corners INTEGER,
    corner_accuracy_pct REAL,
    dispossessed INTEGER,
    errors INTEGER,
    -- Opponent Stats Start Here (Column 49)
    goals_at_half_time_opp INTEGER,
    goals_at_full_time_opp INTEGER,
    possession_opp_pct REAL,
    total_shots_opp INTEGER,
    shots_on_target_opp INTEGER,
    shots_inside_box_opp INTEGER,
    shots_outside_box_opp INTEGER,
    woodwork_opp INTEGER,
    total_crosses_opp INTEGER,
    crosses_success_opp_pct REAL,
    total_passes_opp INTEGER,
    pass_success_opp_pct REAL,
    backward_passes_opp INTEGER,
    forward_passes_opp INTEGER,
    long_passes_opp INTEGER,
    long_passes_succes_opp_pct REAL,
    touches_in_box_opp INTEGER,
    tackles_won_opp INTEGER,
    tackle_succes_opp_pct REAL,
    interceptions_opp INTEGER,
    clearances_opp INTEGER,
    total_dribbles_opp INTEGER,
    dribbles_success_opp INTEGER,
    fouls_committed_opp INTEGER,
    offsides_opp INTEGER,
    yellow_cards_opp INTEGER,
    red_cards_opp INTEGER,
    distance_covered_opp_km DOUBLE PRECISION,
    walking_pct_opp REAL,
    jogging_pct_opp REAL,
    sprinting_pct_opp REAL,
    xg_opp DOUBLE PRECISION,
    xg_openplay_opp DOUBLE PRECISION,
    xg_setplay_opp DOUBLE PRECISION,
    xa_opp DOUBLE PRECISION,
    aerials_won_opp INTEGER,
    aerials_won_opp_pct REAL,
    corners_opp INTEGER,
    corner_accuracy_pct_opp REAL,
    dispossessed_opp INTEGER,
    errors_opp INTEGER);

--Player Stats Data Table
CREATE TABLE player_match_stats (
    match_id INT,
    player_id INT,
    opponent TEXT,
    player_name TEXT,
    position TEXT,
    goals INT,
    "xG" FLOAT,
    assists INT,
    "xA" FLOAT,
    chances_created INT,
    distance_covered_km FLOAT,
    total_tackles INT,
    tackles_won INT,
    tackle_success_pct FLOAT,
    yellow_card INT,
    red_card INT,
    touches INT,
    shots INT,
    shots_on_target INT,
    fouls_won INT,
    offsides INT,
    dispossessed INT,
    interceptions INT,
    clearances INT,
    blocked_shots INT,
    fouls_committed INT,
    total_passes INT,
    pass_accuracy_pct FLOAT,
    crosses INT,
    accurate_crosses INT,
    woodwork INT,
    dribbles_won INT,
    dribbles_attempted INT,
    dribbled_past INT,
    dribble_success_pct FLOAT,
    total_aerials INT,
    aerials_won INT,
    aerial_success_pct FLOAT,
    errors INT);

--Lineups Data Table
CREATE TABLE lineup (
    match_id INTEGER,
    player_id INTEGER,
    player_name VARCHAR(100), 
    minutes_played INTEGER,
    subbed_on_min INTEGER,
    subbed_off_min INTEGER,
    position_played VARCHAR(10),
    starter VARCHAR(3),     
    substitute VARCHAR(3),   
    
-- Composite primary key since a player appears in multiple matches
PRIMARY KEY (match_id, player_id),
CONSTRAINT fk_match FOREIGN KEY(match_id) 
REFERENCES team_match_stats(match_id));

  
--Top 10 players with most goal contributions 
SELECT player_name, SUM(assists) + SUM(goals) AS goal_contributions 
FROM player_match_stats
GROUP BY player_name
HAVING SUM(assists) IS NOT NULL and SUM(goals) IS NOT NULL
ORDER BY goal_contributions DESC
LIMIT 10;

-- Top 15 players with lowest/highest contributions per 90
WITH player_season_totals AS 
(SELECT p.player_name,
SUM(p.goals) AS total_goals,
SUM(p.assists)AS total_assists,
p.position,
SUM(l.minutes_played)AS minutes_played
FROM player_match_stats p
JOIN lineup l 
ON p.player_id = l.player_id AND p.match_id = l.match_id
GROUP BY p.player_name,p.position)

SELECT 
    player_name,
    minutes_played,
    total_goals + total_assists AS total_contributions,
    ROUND(
        CAST((total_goals + total_assists) * 90.0 / minutes_played AS NUMERIC), 
        2
    ) AS contributions_per_90
FROM player_season_totals
WHERE position IN ('F','M','D') AND minutes_played >90
ORDER BY contributions_per_90 DESC 
LIMIT 15;

-- Shooting efficiency
SELECT player_name, SUM(shots) AS total_shots, SUM(shots_on_target) AS total_shots_on_target,SUM(goals) AS Total_goals,ROUND(CAST(SUM("xG")AS NUMERIC),2) AS xG,ROUND(SUM(goals)*100*1.0/SUM(shots)) AS shot_conversion_rate, ROUND(SUM(goals)*100*1.0/SUM(shots_on_target)) AS shots_on_target_conversion_rate, ROUND(CAST(SUM(goals) - SUM("xG")AS NUMERIC),2) AS above_Xg 
FROM player_match_stats
GROUP BY player_name
HAVING SUM(shots)>10
ORDER BY shot_conversion_rate DESC, shots_on_target_conversion_rate DESC
LIMIT 15;

--xA vs assists 
SELECT player_name,SUM(assists) AS total_assists,ROUND(CAST(SUM("xA")AS NUMERIC),2) AS total_xA,ROUND(CAST(SUM(assists) - SUM("xA")AS NUMERIC),2) AS Above_Xa
From player_match_stats
GROUP BY player_name
HAVING SUM(assists) - SUM("xA") IS NOT NULL AND SUM("xA") > 0.3
ORDER BY total_assists DESC;

-- Players with the best pass accuracy with at least 200 passes in the the season and their position
SELECT player_name, position, SUM(total_passes) AS total_passes,
ROUND(CAST(AVG(pass_accuracy_pct)AS NUMERIC),2) AS avg_pass_accuracy,
(SELECT ROUND(CAST(AVG(pass_accuracy_pct)AS NUMERIC),2)FROM player_match_stats WHERE position = 'D' )AS avg_pass_def,
(SELECT ROUND(CAST(AVG(pass_accuracy_pct)AS NUMERIC),2)FROM player_match_stats WHERE position = 'M' )AS avg_pass_mid,
(SELECT ROUND(CAST(AVG(pass_accuracy_pct)AS NUMERIC),2)FROM player_match_stats WHERE position = 'F' ) AS avg_pass_for
FROM player_match_stats
GROUP BY player_name, position
HAVING SUM(total_passes) > 200
ORDER BY position,AVG(pass_accuracy_pct) DESC, SUM (total_passes) DESC;

--Defensive leaders (D and M) - most tackles, clearances, interceptions and blocked shots 
SELECT player_name, position, SUM(tackles_won)+ SUM(interceptions) + SUM(clearances) +SUM(blocked_shots) AS d_contributions
FROM player_match_stats
WHERE position IN ('D','M') 
GROUP BY player_name, position
HAVING SUM(tackles_won+interceptions+clearances+blocked_shots)IS NOT NULL
ORDER BY d_contributions DESC
LIMIT 12;

-- Defensive contributions per 90
WITH defensive_totals AS(
SELECT p.player_name,
SUM (p.tackles_won) AS total_tackles_won,
SUM (p.interceptions)AS total_interceptions,
SUM (p.clearances) AS total_clearances,
SUM (p.blocked_shots) AS total_blocked_shots,
SUM (l.minutes_played)AS total_minutes_played
FROM player_match_stats p
JOIN lineup l
ON p.player_id = l.player_id AND p.match_id = l.match_id
GROUP BY p.player_name)

SELECT player_name, 
total_minutes_played, 
total_tackles_won + total_interceptions + total_clearances + total_blocked_shots AS total_contributions,
ROUND(CAST((total_tackles_won + total_interceptions + total_clearances+total_blocked_shots)*90.0/total_minutes_played AS NUMERIC),2) AS contributions_per_90
FROM defensive_totals
WHERE total_minutes_played > 180
ORDER BY contributions_per_90 DESC;


--Dribbling
SELECT 
    p.player_name,
    SUM(l.minutes_played) AS total_minutes,
    SUM(p.dribbles_attempted) AS total_attempts,
    SUM(p.dribbles_won) AS successful_dribbles,
    ROUND(CAST(SUM(p.dribbles_won) AS Numeric) / NULLIF(SUM(p.dribbles_attempted), 0) * 100, 2) AS dribble_success_pct,
    ROUND((CAST(SUM(p.dribbles_won) AS Numeric) / SUM(l.minutes_played)) * 90, 2) AS dribbles_won_per_90
FROM player_match_stats p
JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
GROUP BY p.player_name
HAVING SUM(l.minutes_played) > 90 
ORDER BY dribbles_won_per_90 DESC;



-- Aerials
SELECT 
    p.player_name,
    SUM(l.minutes_played) AS total_minutes,
    SUM(p.total_aerials) AS total_contests,
    SUM(p.aerials_won) AS aerials_won,
    ROUND(CAST(SUM(p.aerials_won) AS Numeric) / NULLIF(SUM(p.total_aerials), 0) * 100, 2) AS aerial_win_pct,
    ROUND((CAST(SUM(p.aerials_won) AS Numeric) / SUM(l.minutes_played)) * 90, 2) AS aerials_won_per_90
FROM player_match_stats p
JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
GROUP BY p.player_name
HAVING SUM(l.minutes_played) > 90
ORDER BY aerial_win_pct DESC;


-- AI Assisted 
-- Best attacker improvements
WITH ForwardStats AS (
    -- Step 1: Calculate expanded core metrics strictly for FORWARDS
    SELECT 
        p.player_name,
        SUM(l.minutes_played) AS total_minutes,
        SUM(p.goals) + SUM(p.assists) AS total_contributions,
        SUM(p.goals) - SUM(p."xG") AS xg_delta, -- Finishing efficiency
        CAST(SUM(p.shots_on_target) AS Numeric) / NULLIF(SUM(p.shots), 0) * 100 AS shot_accuracy_pct,
        CAST(SUM(p.dribbles_won) AS Numeric) / NULLIF(SUM(p.dribbles_attempted), 0) * 100 AS dribble_success_pct,
        -- Weighted pass accuracy based on volume
        SUM(p.total_passes * (p.pass_accuracy_pct / 100.0)) / NULLIF(SUM(p.total_passes), 0) * 100 AS pass_accuracy_pct,
        -- Aerial Win % based on total contests and successful challenges
        CAST(SUM(p.aerials_won) AS Numeric) / NULLIF(SUM(p.total_aerials), 0) * 100 AS aerial_win_pct,
		SUM(p.distance_covered_km) / (SUM(l.minutes_played) / 90.0) AS distance_per_90
    FROM player_match_stats p
    JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
    WHERE p.position = 'F' -- RESTRICTED TO FORWARDS ONLY
    GROUP BY p.player_name
    HAVING SUM(l.minutes_played) > 270 -- Parity filter (min 3 full matches)
),
ForwardAverages AS (
    -- Step 2: Calculate the standard baseline for Forwards ONLY
    SELECT 
        AVG(xg_delta) AS avg_xg_delta,
        AVG(shot_accuracy_pct) AS avg_shot_accuracy,
        AVG(dribble_success_pct) AS avg_dribble_success,
        AVG(pass_accuracy_pct) AS avg_pass_accuracy,
        AVG(aerial_win_pct) AS avg_aerial_success,
		AVG(distance_per_90) AS avg_distance_per_90
    FROM ForwardStats
),
TopForward AS (
    -- Step 3: Automatically isolate the most productive Forward
    SELECT * FROM ForwardStats
    ORDER BY total_contributions DESC
    LIMIT 1 -- (Note: Use 'TOP 1' if on SQL Server)
)
-- Step 4: Map the gaps. Only metrics below the Forward average are returned.
SELECT 
    t.player_name AS best_forward,
    'Finishing (xG Delta)' AS technical_gap_to_improve,
    ROUND(CAST(t.xg_delta AS NUMERIC), 2) AS player_stat,
    ROUND(CAST(s.avg_xg_delta AS NUMERIC), 2) AS forward_avg,
    ROUND(CAST(ABS(t.xg_delta - s.avg_xg_delta) * 100.0 / NULLIF(ABS(t.xg_delta + s.avg_xg_delta) / 2.0, 0) AS NUMERIC), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.xg_delta < s.avg_xg_delta 

UNION ALL

SELECT 
    t.player_name,
    'Shot Accuracy %',
    ROUND(t.shot_accuracy_pct, 2),
    ROUND(s.avg_shot_accuracy, 2),
    ROUND(ABS(t.shot_accuracy_pct - s.avg_shot_accuracy) * 100.0 / NULLIF(ABS(t.shot_accuracy_pct + s.avg_shot_accuracy) / 2.0, 0), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.shot_accuracy_pct < s.avg_shot_accuracy

UNION ALL

SELECT 
    t.player_name,
    'Dribble Success %',
    ROUND(t.dribble_success_pct, 2),
    ROUND(s.avg_dribble_success, 2),
    ROUND(ABS(t.dribble_success_pct - s.avg_dribble_success) * 100.0 / NULLIF(ABS(t.dribble_success_pct + s.avg_dribble_success) / 2.0, 0), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.dribble_success_pct < s.avg_dribble_success

UNION ALL

SELECT 
    t.player_name,
    'Pass Accuracy %',
    ROUND(CAST(t.pass_accuracy_pct AS NUMERIC), 2),
    ROUND(CAST(s.avg_pass_accuracy AS NUMERIC), 2),
    ROUND(CAST(ABS(t.pass_accuracy_pct - s.avg_pass_accuracy) * 100.0 / NULLIF(ABS(t.pass_accuracy_pct + s.avg_pass_accuracy) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.pass_accuracy_pct < s.avg_pass_accuracy

UNION ALL

-- Final Comparison block for Aerials
SELECT 
    t.player_name,
    'Aerial Win % (Physicality)',
    ROUND(t.aerial_win_pct, 2),
    ROUND(s.avg_aerial_success, 2),
    ROUND(ABS(t.aerial_win_pct - s.avg_aerial_success) * 100.0 / NULLIF(ABS(t.aerial_win_pct + s.avg_aerial_success) / 2.0, 0), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.aerial_win_pct < s.avg_aerial_success

UNION ALL

SELECT 
    t.player_name,
    'Distance Covered Per 90 (km)',
    ROUND(CAST(t.distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(s.avg_distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(ABS(t.distance_per_90 - s.avg_distance_per_90) * 100.0 / NULLIF(ABS(t.distance_per_90 + s.avg_distance_per_90) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopForward t CROSS JOIN ForwardAverages s
WHERE t.distance_per_90 < s.avg_distance_per_90;


-- AI Assisted
-- What areas do best midfielder need to improve on
WITH MidfieldStats AS (
    -- Step 1: Calculate expanded core metrics strictly for FORWARDS
    SELECT 
        p.player_name,
        SUM(l.minutes_played) AS total_minutes,
        SUM(p.goals) + SUM(p.assists) AS total_contributions,
        SUM(p.goals) - SUM(p."xG") AS xg_delta, -- Finishing efficiency
        CAST(SUM(p.shots_on_target) AS Numeric) / NULLIF(SUM(p.shots), 0) * 100 AS shot_accuracy_pct,
        CAST(SUM(p.dribbles_won) AS Numeric) / NULLIF(SUM(p.dribbles_attempted), 0) * 100 AS dribble_success_pct,
        -- Weighted pass accuracy based on volume
        SUM(p.total_passes * (p.pass_accuracy_pct / 100.0)) / NULLIF(SUM(p.total_passes), 0) * 100 AS pass_accuracy_pct,
        -- Aerial Win % based on total contests and successful challenges
        CAST(SUM(p.aerials_won) AS Numeric) / NULLIF(SUM(p.total_aerials), 0) * 100 AS aerial_win_pct,
		SUM(p.distance_covered_km) / (SUM(l.minutes_played) / 90.0) AS distance_per_90
    FROM player_match_stats p
    JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
    WHERE p.position = 'M' -- RESTRICTED TO MIDFIELDERS ONLY
    GROUP BY p.player_name
    HAVING SUM(l.minutes_played) > 270 -- Parity filter (min 3 full matches)
),
MidfieldAverages AS (
    -- Step 2: Calculate the standard baseline for Forwards ONLY
    SELECT 
        AVG(xg_delta) AS avg_xg_delta,
        AVG(shot_accuracy_pct) AS avg_shot_accuracy,
        AVG(dribble_success_pct) AS avg_dribble_success,
        AVG(pass_accuracy_pct) AS avg_pass_accuracy,
        AVG(aerial_win_pct) AS avg_aerial_success,
		AVG(distance_per_90) AS avg_distance_per_90
    FROM MidfieldStats
),
TopMidfielder AS (
    -- Step 3: Automatically isolate the most productive Forward
    SELECT * FROM MidfieldStats
    ORDER BY total_contributions DESC
    LIMIT 1 -- (Note: Use 'TOP 1' if on SQL Server)
)
-- Step 4: Map the gaps. Only metrics below the Forward average are returned.
SELECT 
    t.player_name AS best_forward,
    'Finishing (xG Delta)' AS technical_gap_to_improve,
    ROUND(CAST(t.xg_delta AS NUMERIC), 2) AS player_stat,
    ROUND(CAST(s.avg_xg_delta AS NUMERIC), 2) AS midfield_avg,
    ROUND(CAST(ABS(t.xg_delta - s.avg_xg_delta) * 100.0 / NULLIF(ABS(t.xg_delta + s.avg_xg_delta) / 2.0, 0) AS NUMERIC), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.xg_delta < s.avg_xg_delta 

UNION ALL

SELECT 
    t.player_name,
    'Shot Accuracy %',
    ROUND(t.shot_accuracy_pct, 2),
    ROUND(s.avg_shot_accuracy, 2),
    ROUND(ABS(t.shot_accuracy_pct - s.avg_shot_accuracy) * 100.0 / NULLIF(ABS(t.shot_accuracy_pct + s.avg_shot_accuracy) / 2.0, 0), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.shot_accuracy_pct < s.avg_shot_accuracy

UNION ALL

SELECT 
    t.player_name,
    'Dribble Success %',
    ROUND(t.dribble_success_pct, 2),
    ROUND(s.avg_dribble_success, 2),
    ROUND(ABS(t.dribble_success_pct - s.avg_dribble_success) * 100.0 / NULLIF(ABS(t.dribble_success_pct + s.avg_dribble_success) / 2.0, 0), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.dribble_success_pct < s.avg_dribble_success

UNION ALL

SELECT 
    t.player_name,
    'Pass Accuracy %',
    ROUND(CAST(t.pass_accuracy_pct AS NUMERIC), 2),
    ROUND(CAST(s.avg_pass_accuracy AS NUMERIC), 2),
    ROUND(CAST(ABS(t.pass_accuracy_pct - s.avg_pass_accuracy) * 100.0 / NULLIF(ABS(t.pass_accuracy_pct + s.avg_pass_accuracy) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.pass_accuracy_pct < s.avg_pass_accuracy

UNION ALL

-- Final Comparison block for Aerials
SELECT 
    t.player_name,
    'Aerial Win % (Physicality)',
    ROUND(t.aerial_win_pct, 2),
    ROUND(s.avg_aerial_success, 2),
    ROUND(ABS(t.aerial_win_pct - s.avg_aerial_success) * 100.0 / NULLIF(ABS(t.aerial_win_pct + s.avg_aerial_success) / 2.0, 0), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.aerial_win_pct < s.avg_aerial_success

UNION ALL

SELECT 
    t.player_name,
    'Distance Covered Per 90 (km)',
    ROUND(CAST(t.distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(s.avg_distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(ABS(t.distance_per_90 - s.avg_distance_per_90) * 100.0 / NULLIF(ABS(t.distance_per_90 + s.avg_distance_per_90) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopMidfielder t CROSS JOIN MidfieldAverages s
WHERE t.distance_per_90 < s.avg_distance_per_90;


-- AI Assisted
-- Areas to improve for top defender 
WITH DefenderStats AS (
    -- Step 1: Calculate expanded core metrics strictly for FORWARDS
    SELECT 
        p.player_name,
        SUM(l.minutes_played) AS total_minutes,
        SUM(tackles_won)+ SUM(interceptions) + SUM(clearances) +SUM(blocked_shots) AS total_contributions,
        SUM(p.goals) - SUM(p."xG") AS xg_delta, -- Finishing efficiency
        CAST(SUM(p.shots_on_target) AS Numeric) / NULLIF(SUM(p.shots), 0) * 100 AS shot_accuracy_pct,
        CAST(SUM(p.dribbles_won) AS Numeric) / NULLIF(SUM(p.dribbles_attempted), 0) * 100 AS dribble_success_pct,
        -- Weighted pass accuracy based on volume
        SUM(p.total_passes * (p.pass_accuracy_pct / 100.0)) / NULLIF(SUM(p.total_passes), 0) * 100 AS pass_accuracy_pct,
        -- Aerial Win % based on total contests and successful challenges
        CAST(SUM(p.aerials_won) AS Numeric) / NULLIF(SUM(p.total_aerials), 0) * 100 AS aerial_win_pct,
		SUM(p.distance_covered_km) / (SUM(l.minutes_played) / 90.0) AS distance_per_90
    FROM player_match_stats p
    JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
    WHERE p.position = 'D' -- RESTRICTED TO MIDFIELDERS ONLY
    GROUP BY p.player_name
    HAVING SUM(l.minutes_played) > 270 -- Parity filter (min 3 full matches)
),
DefenderAverages AS (
    -- Step 2: Calculate the standard baseline for Forwards ONLY
    SELECT 
        AVG(xg_delta) AS avg_xg_delta,
        AVG(shot_accuracy_pct) AS avg_shot_accuracy,
        AVG(dribble_success_pct) AS avg_dribble_success,
        AVG(pass_accuracy_pct) AS avg_pass_accuracy,
        AVG(aerial_win_pct) AS avg_aerial_success,
		AVG(distance_per_90) AS avg_distance_per_90
    FROM DefenderStats
),
TopDefender AS (
    -- Step 3: Automatically isolate the most productive Forward
    SELECT * FROM DefenderStats
    ORDER BY total_contributions DESC
    LIMIT 1 -- (Note: Use 'TOP 1' if on SQL Server)
)
-- Step 4: Map the gaps. Only metrics below the Forward average are returned.
SELECT 
    t.player_name AS best_defender,
    'Finishing (xG Delta)' AS technical_gap_to_improve,
    ROUND(CAST(t.xg_delta AS NUMERIC), 2) AS player_stat,
    ROUND(CAST(s.avg_xg_delta AS NUMERIC), 2) AS defence_avg,
    ROUND(CAST(ABS(t.xg_delta - s.avg_xg_delta) * 100.0 / NULLIF(ABS(t.xg_delta + s.avg_xg_delta) / 2.0, 0) AS NUMERIC), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.xg_delta < s.avg_xg_delta 

UNION ALL

SELECT 
    t.player_name,
    'Shot Accuracy %',
    ROUND(t.shot_accuracy_pct, 2),
    ROUND(s.avg_shot_accuracy, 2),
    ROUND(ABS(t.shot_accuracy_pct - s.avg_shot_accuracy) * 100.0 / NULLIF(ABS(t.shot_accuracy_pct + s.avg_shot_accuracy) / 2.0, 0), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.shot_accuracy_pct < s.avg_shot_accuracy

UNION ALL

SELECT 
    t.player_name,
    'Dribble Success %',
    ROUND(t.dribble_success_pct, 2),
    ROUND(s.avg_dribble_success, 2),
    ROUND(ABS(t.dribble_success_pct - s.avg_dribble_success) * 100.0 / NULLIF(ABS(t.dribble_success_pct + s.avg_dribble_success) / 2.0, 0), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.dribble_success_pct < s.avg_dribble_success

UNION ALL

SELECT 
    t.player_name,
    'Pass Accuracy %',
    ROUND(CAST(t.pass_accuracy_pct AS NUMERIC), 2),
    ROUND(CAST(s.avg_pass_accuracy AS NUMERIC), 2),
    ROUND(CAST(ABS(t.pass_accuracy_pct - s.avg_pass_accuracy) * 100.0 / NULLIF(ABS(t.pass_accuracy_pct + s.avg_pass_accuracy) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.pass_accuracy_pct < s.avg_pass_accuracy

UNION ALL

-- Final Comparison block for Aerials
SELECT 
    t.player_name,
    'Aerial Win % (Physicality)',
    ROUND(t.aerial_win_pct, 2),
    ROUND(s.avg_aerial_success, 2),
    ROUND(ABS(t.aerial_win_pct - s.avg_aerial_success) * 100.0 / NULLIF(ABS(t.aerial_win_pct + s.avg_aerial_success) / 2.0, 0), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.aerial_win_pct < s.avg_aerial_success

UNION ALL

SELECT 
    t.player_name,
    'Distance Covered Per 90 (km)',
    ROUND(CAST(t.distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(s.avg_distance_per_90 AS NUMERIC), 2),
    ROUND(CAST(ABS(t.distance_per_90 - s.avg_distance_per_90) * 100.0 / NULLIF(ABS(t.distance_per_90 + s.avg_distance_per_90) / 2.0, 0)AS NUMERIC), 2) AS pct_difference
FROM TopDefender t CROSS JOIN DefenderAverages s
WHERE t.distance_per_90 < s.avg_distance_per_90;


-- Who has made the best impact of the bench?
-- only 3 percent of goals scored were from the bench placing 15th in prem for goals off the bench

SELECT 
    p.player_name,
    SUM(p.goals) AS total_goals,
    SUM(p.assists) AS total_assists,
    (SUM(p.goals) + SUM(p.assists)) AS total_goal_contributions,
    SUM(l.minutes_played) AS total_minutes_played,
    ROUND(CAST((SUM(p.goals) + SUM(p.assists)) AS NUMERIC) / 
          NULLIF(SUM(l.minutes_played), 0) * 90, 2) AS impact_per_90
FROM player_match_stats p
INNER JOIN lineup l ON p.match_id = l.match_id AND p.player_id = l.player_id
WHERE l.substitute = 'Yes'
  AND l.minutes_played > 0
GROUP BY p.player_name
HAVING SUM(l.minutes_played) >= 90
ORDER BY impact_per_90 DESC;


--Total goals and assists by position
SELECT position, SUM(goals) + sum(assists) AS position_contributions
FROM player_match_stats
GROUP BY position
ORDER BY position_contributions DESC;

--Season record count and percentage with distance covered
SELECT result,COUNT(result),100*COUNT(result)/ (SELECT COUNT(match_id) FROM team_match_stats) AS pct, ROUND(CAST(AVG(distance_covered_km)AS NUMERIC),2)
FROM team_match_stats
WHERE RESULT IS NOT NULL
GROUP BY result;

--Home Form VS Away
SELECT home, result,COUNT(result), SUM(goals_at_full_time) AS goals_Scored, ROUND(CAST(AVG(possession_pct )AS NUMERIC),2) AS avg_possession,ROUND(CAST(AVG(distance_covered_km)AS NUMERIC),2) AS avg_distance_covered
FROM team_match_stats
WHERE result IS NOT NULL
GROUP BY home, result
ORDER BY home DESC,result DESC;

--Performance vs different opposition groups
SELECT CASE WHEN  opponent_league_position <= 6 THEN 'Top 6' 
WHEN  opponent_league_position BETWEEN 7 AND 14 THEN 'Midtable' 
ELSE 'Bottom 6' END AS leagueOpposition ,result,COUNT(result)AS number, SUM(goals_at_full_time) - SUM(goals_at_full_time_opp ) AS goals_difference, ROUND(CAST(AVG(possession_pct )AS NUMERIC),2) AS avgpossession,ROUND(CAST(AVG(distance_covered_km)AS NUMERIC),2) AS avgdistance
FROM team_match_stats
GROUP BY leagueOpposition, result
ORDER BY leagueopposition DESC,result DESC, number DESC;

SELECT CASE WHEN  opponent_league_position <= 6 THEN 'Top 6' 
WHEN  opponent_league_position BETWEEN 7 AND 14 THEN 'Midtable' 
ELSE 'Bottom 6' END AS leagueOpposition , SUM(goals_at_full_time) - SUM(goals_at_full_time_opp ) AS goals_difference, ROUND(CAST(AVG(possession_pct )AS NUMERIC),2) AS avgpossession,ROUND(CAST(AVG(distance_covered_km)AS NUMERIC),2) AS avgdistance
FROM team_match_stats
GROUP BY leagueOpposition 
ORDER BY leagueopposition DESC;

-- Matches where posession was 55 + and still losses
SELECT match_id,opponent, possession_pct, goals_at_full_time, total_shots, Xg
FROM team_match_stats
WHERE possession_pct >=55 AND result = 'L';

-- How many times did we outrun the opponent whole distance (no red cards) and did it result in a win?
SELECT match_id, opponent, result ,(SELECT COUNT(match_id) AS total_wins FROM team_match_stats WHERE result = 'W' ),possession_pct
FROM team_match_stats
WHERE distance_covered_km >= distance_covered_opp_km AND red_cards = 0 AND red_cards_opp = 0;

-- Results when losing at halftime
SELECT COUNT(CASE WHEN goals_at_half_time < goals_at_half_time_opp AND result = 'L' THEN 1 END) AS Nocomeback, 
COUNT(CASE WHEN goals_at_half_time < goals_at_half_time_opp AND result = 'D' THEN 1 END) AS coming_back_to_draw, 
COUNT(CASE WHEN goals_at_half_time < goals_at_half_time_opp AND result = 'W' THEN 1 END) AS fullcomeback
FROM team_match_stats;

-- Results by Manager
SELECT manager, result, COUNT(result)
FROM team_match_stats
GROUP BY manager, result
ORDER BY manager, result DESC;

--Is team efficient against Xg
SELECT manager,ROUND(CAST(SUM(goals_at_full_time) - SUM(Xg)AS NUMERIC),2) AS Above_Xg
From team_match_stats
GROUP BY manager;

-- Manager comparison
SELECT manager,
    ROUND(AVG(goals_at_half_time), 2) AS avg_goals_at_half_time,
    ROUND(AVG(goals_at_full_time), 2) AS avg_goals_at_full_time,
    ROUND(CAST(AVG(possession_pct)AS NUMERIC), 2) AS avg_possession_pct,
    ROUND(AVG(total_shots), 2) AS avg_total_shots,
    ROUND(AVG(shots_on_target), 2) AS avg_shots_on_target,
    ROUND(AVG(shots_inside_box), 2) AS avg_shots_inside_box,
    ROUND(AVG(shots_outside_box), 2) AS avg_shots_outside_box,
    ROUND(AVG(woodwork), 2) AS avg_woodwork,
    ROUND(AVG(total_crosses), 2) AS avg_total_crosses,
    ROUND(CAST(AVG(crosses_success_pct)AS NUMERIC), 2) AS avg_crosses_success_pct,
    ROUND(AVG(total_passes), 2) AS avg_total_passes,
    ROUND(CAST(AVG(pass_success_pct)AS NUMERIC), 2) AS avg_pass_success_pct,
    ROUND(AVG(backward_passes), 2) AS avg_backward_passes,
    ROUND(AVG(forward_passes), 2) AS avg_forward_passes,
    ROUND(AVG(long_passes), 2) AS avg_long_passes,
    ROUND(CAST(AVG(long_passes_succes_pct)AS NUMERIC), 2) AS avg_long_passes_succes_pct,
    ROUND(AVG(touches_in_box), 2) AS avg_touches_in_box,
    ROUND(AVG(tackles_won), 2) AS avg_tackles_won,
    ROUND(CAST(AVG(tackle_succes_pct)AS NUMERIC), 2) AS avg_tackle_succes_pct,
    ROUND(AVG(interceptions), 2) AS avg_interceptions,
    ROUND(AVG(clearances), 2) AS avg_clearances,
    ROUND(AVG(total_dribbles), 2) AS avg_total_dribbles,
    ROUND(AVG(dribbles_success), 2) AS avg_dribbles_success,
    ROUND(AVG(fouls_committed), 2) AS avg_fouls_committed,
    ROUND(AVG(offsides), 2) AS avg_offsides,
    ROUND(AVG(yellow_cards), 2) AS avg_yellow_cards,
    ROUND(AVG(red_cards), 2) AS avg_red_cards,
    ROUND(CAST(AVG(distance_covered_km)AS NUMERIC), 2) AS avg_distance_covered_km,
    ROUND(CAST(AVG(walking_pct)AS NUMERIC), 2) AS avg_walking_pct,
    ROUND(CAST(AVG(jogging_pct)AS NUMERIC), 2) AS avg_jogging_pct,
    ROUND(CAST(AVG(sprinting_pct)AS NUMERIC), 2) AS avg_sprinting_pct,
    ROUND(CAST(AVG(xg)AS NUMERIC), 2) AS avg_xg,
    ROUND(CAST(AVG(xg_openplay)AS NUMERIC), 2) AS avg_xg_openplay,
    ROUND(CAST(AVG(xg_setplay)AS NUMERIC), 2) AS avg_xg_setplay,
    ROUND(CAST(AVG(xa)AS NUMERIC), 2) AS avg_xa,
    ROUND(AVG(aerials_won), 2) AS avg_aerials_won,
    ROUND(CAST(AVG(aerials_won_pct)AS NUMERIC), 2) AS avg_aerials_won_pct,
    ROUND(AVG(corners), 2) AS avg_corners,
    ROUND(CAST(AVG(corner_accuracy_pct)AS NUMERIC), 2) AS avg_corner_accuracy_pct,
    ROUND(AVG(dispossessed), 2) AS avg_dispossessed,
    ROUND(AVG(errors), 2) AS avg_errors,
    -- Opponent Stats
    ROUND(AVG(goals_at_half_time_opp), 2) AS avg_goals_at_half_time_opp,
    ROUND(AVG(goals_at_full_time_opp), 2) AS avg_goals_at_full_time_opp,
    ROUND(CAST(AVG(possession_opp_pct)AS NUMERIC), 2) AS avg_possession_opp_pct,
    ROUND(AVG(total_shots_opp), 2) AS avg_total_shots_opp,
    ROUND(AVG(shots_on_target_opp), 2) AS avg_shots_on_target_opp,
    ROUND(AVG(shots_inside_box_opp), 2) AS avg_shots_inside_box_opp,
    ROUND(AVG(shots_outside_box_opp), 2) AS avg_shots_outside_box_opp,
    ROUND(AVG(woodwork_opp), 2) AS avg_woodwork_opp,
    ROUND(AVG(total_crosses_opp), 2) AS avg_total_crosses_opp,
    ROUND(CAST(AVG(crosses_success_opp_pct)AS NUMERIC), 2) AS avg_crosses_success_opp_pct,
    ROUND(AVG(total_passes_opp), 2) AS avg_total_passes_opp,
    ROUND(CAST(AVG(pass_success_opp_pct)AS NUMERIC), 2) AS avg_pass_success_opp_pct,
    ROUND(AVG(backward_passes_opp), 2) AS avg_backward_passes_opp,
    ROUND(AVG(forward_passes_opp), 2) AS avg_forward_passes_opp,
    ROUND(AVG(long_passes_opp), 2) AS avg_long_passes_opp,
    ROUND(CAST(AVG(long_passes_succes_opp_pct)AS NUMERIC), 2) AS avg_long_passes_succes_opp_pct,
    ROUND(AVG(touches_in_box_opp), 2) AS avg_touches_in_box_opp,
    ROUND(AVG(tackles_won_opp), 2) AS avg_tackles_won_opp,
    ROUND(CAST(AVG(tackle_succes_opp_pct)AS NUMERIC), 2) AS avg_tackle_succes_opp_pct,
    ROUND(AVG(interceptions_opp), 2) AS avg_interceptions_opp,
    ROUND(AVG(clearances_opp), 2) AS avg_clearances_opp,
    ROUND(AVG(total_dribbles_opp), 2) AS avg_total_dribbles_opp,
    ROUND(AVG(dribbles_success_opp), 2) AS avg_dribbles_success_opp,
    ROUND(AVG(fouls_committed_opp), 2) AS avg_fouls_committed_opp,
    ROUND(AVG(offsides_opp), 2) AS avg_offsides_opp,
    ROUND(AVG(yellow_cards_opp), 2) AS avg_yellow_cards_opp,
    ROUND(AVG(red_cards_opp), 2) AS avg_red_cards_opp,
    ROUND(CAST(AVG(distance_covered_opp_km)AS NUMERIC), 2) AS avg_distance_covered_opp_km,
    ROUND(CAST(AVG(walking_pct_opp)AS NUMERIC), 2) AS avg_walking_pct_opp,
    ROUND(CAST(AVG(jogging_pct_opp)AS NUMERIC), 2) AS avg_jogging_pct_opp,
    ROUND(CAST(AVG(sprinting_pct_opp)AS NUMERIC), 2) AS avg_sprinting_pct_opp,
    ROUND(CAST(AVG(xg_opp)AS NUMERIC), 2) AS avg_xg_opp,
    ROUND(CAST(AVG(xg_openplay_opp)AS NUMERIC), 2) AS avg_xg_openplay_opp,
    ROUND(CAST(AVG(xg_setplay_opp)AS NUMERIC), 2) AS avg_xg_setplay_opp,
    ROUND(CAST(AVG(xa_opp)AS NUMERIC), 2) AS avg_xa_opp,
    ROUND(AVG(aerials_won_opp), 2) AS avg_aerials_won_opp,
    ROUND(CAST(AVG(aerials_won_opp_pct)AS NUMERIC), 2) AS avg_aerials_won_opp_pct,
    ROUND(AVG(corners_opp), 2) AS avg_corners_opp,
    ROUND(CAST(AVG(corner_accuracy_pct_opp)AS NUMERIC), 2) AS avg_corner_accuracy_pct_opp,
    ROUND(AVG(dispossessed_opp), 2) AS avg_dispossessed_opp,
    ROUND(AVG(errors_opp), 2) AS avg_errors_opp
	FROM team_match_stats
	GROUP BY manager
	ORDER BY manager ASC;













 
