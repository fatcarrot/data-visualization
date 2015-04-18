SELECT
    x1
    ,y1
    ,x2
    ,y2
    ,COUNT(*)
FROM
    (SELECT
        t2_1.longitude AS x1
        ,t2_1.latitude  AS y1
        ,t2_2.longitude AS x2
        ,t2_2.latitude  AS y2
    FROM
        flight_base_info_new  t1
        INNER JOIN
        airport_base_info_new t2_1
        INNER JOIN
        airport_base_info_new t2_2
    ON
        t1.first_airport_id = t2_1.airport_id
        AND t1.final_airport_id = t2_2.airport_id
    WHERE
        t1.is_international_flight != 1
        AND t2_1.country_code = 'CN'
        AND t2_2.country_code = 'CN') tt
GROUP BY
    x1, y1, x2, y2
