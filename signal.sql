SET mapred.job.queue.name=rp-product;
SET mapred.job.name="skyeye_signal_data_obtain_${hivevar:date}";
SET mapred.reduce.tasks=7;
INSERT OVERWRITE DIRECTORY '${hivevar:path}'
SELECT
    regexp_replace(client_id, '\0', '') AS id
    ,flight_lon
    ,flight_lat
    ,server_time
FROM
    trends_bl_skyeye_basic_data
WHERE
    event_day = "${hivevar:date}"
    AND flight_lon != ''
    AND CAST(flight_lon AS FLOAT) > 60
    AND CAST(flight_lon AS FLOAT) < 140
    AND flight_lat != ''
    AND CAST(flight_lat AS FLOAT) > 0
    AND CAST(flight_lat AS FLOAT) < 60
DISTRIBUTE BY
    id
SORT BY
    id
    ,server_time
