CREATE EXTERNAL TABLE gameandgrade_external (
    Sex BOOLEAN,
    School_code INT,
    Playing_years INT,
    Playing_often INT,
    Playing_hours INT,
    Playing_games INT,
    Parent_revenue INT,
    Father_education INT,
    Mother_education INT,
    Grade DOUBLE PRECISION
)
LOCATION ('gpfdist://91.185.85.179:8080/team32_fadeeva/gameandgrade.csv')
FORMAT 'CSV' (HEADER);