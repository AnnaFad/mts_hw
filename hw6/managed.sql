CREATE TABLE gameandgrade_managed (
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
INSERT INTO  gameandgrade_managed SELECT * FROM  gameandgrade_external;