CREATE TABLE team32_managed (
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
);
INSERT INTO  team32_managed SELECT * FROM  team32_external;
