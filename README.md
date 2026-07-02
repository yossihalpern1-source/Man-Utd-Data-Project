# Asset Performance & Tactical Attribution Framework :
A Manchester United Case Study


A comprehensive data analytics project leveraging PostgreSQL and Google Sheets to evaluate team performance, manager efficiency, and player metrics across a full season.

## 📊 Project Components
* **SQL Queries:** Check out the [queries.sql](https://github.com/yossihalpern1-source/Man-Utd-Data-Project/blob/main/Queries.sql) file in this repository to see the relational database schema, CTEs, and aggregate functions used for the analysis.
* **Executive Presentation:** View the project slide deck directly in GitHub via the [Project PDF](./Man Utd 25-26 Analysis.pdf) or access the live interactive [Google Slides Presentation](https://docs.google.com/presentation/d/17RxRufmURvLoZLcDbwGeiSuNLEgvYgKZvt2DIcwGXj0/edit?usp=sharing).

## 🗃️ Data Sources (Google Sheets)
The dataset is split across four relational structures:
* [Player Match Stats](https://docs.google.com/spreadsheets/d/1d480W5GpQLpkiru3xirIfncY7Fvd5TwPl-ee97QpRt8/edit?usp=sharing
) — Individual player performance metrics per match.
* [Team Match Stats](https://docs.google.com/spreadsheets/d/1Gdg4qGftOVx5LLUoB2LDeLm345_YN6w2kuRAkYfknaM/edit?usp=sharing) — Team-wide and opponent metrics, including xG, possession, and distance covered.
* [Lineups](https://docs.google.com/spreadsheets/d/1uoa0f36-AMRkKfMPNXn3y2h0-M0duiig4zoMeZmtidY/edit?usp=sharing) — Matchday squads, minutes played, and substitution tracking.
* [Source Sheet](https://docs.google.com/document/d/1QKX2kqWzGR1ywaggXU0lC24urafXKE0lhu97MVcYkiQ/edit?usp=sharing) — Full game and player stats from numerous sources.

## 🔑 Key Insights Discovered
* **Player Efficiency:** Benchmarking efficiency (Per 90) and identifying  production gaps in the rotation.
* **Manager Tactics:** Comparison of tactical shifts and result volatility between managerial tenures.
* **Team Impact:** Scrutinizing opposition groups, physical Intensity, home vs away and team resilience.
