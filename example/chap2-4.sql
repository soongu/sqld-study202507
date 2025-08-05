

-- 전체 조회수 총합 집계
-- 사용자별 조회수 총합 집계
-- 사용자>피드타입별 조회수 총합 집계

-- user_id, post_type을 기준으로 계층적 집계를 수행합니다.
SELECT
    user_id,
    post_type,
    SUM(view_count) AS total_views
FROM
    POSTS
GROUP BY
    ROLLUP(user_id, post_type)
ORDER BY user_id, post_type
;

SELECT
    null,
    null,
    SUM(view_count) AS total_views
FROM
    POSTS
;

SELECT
    user_id,
    null,
    SUM(view_count) AS total_views
FROM
    POSTS
GROUP BY user_id
;

SELECT
    user_id,
    POST_TYPE,
    SUM(view_count) AS total_views
FROM
    POSTS
GROUP BY user_id, post_type
;


SELECT
    user_id,
    post_type,
    SUM(view_count) AS total_views,
    GROUPING(user_id) AS G_USER, -- user_id가 집계되었으면 1
    GROUPING(post_type) AS G_TYPE -- post_type이 집계되었으면 1
FROM
    POSTS
GROUP BY
    ROLLUP(user_id, post_type)
ORDER BY user_id, post_type   
;

SELECT
    CASE WHEN GROUPING(user_id) = 1 THEN '전체 합계' ELSE TO_CHAR(user_id) END AS "사용자",
    CASE WHEN GROUPING(post_type) = 1 THEN '사용자 소계' ELSE post_type END AS "게시물 종류",
    SUM(view_count) AS "총 조회수"
FROM POSTS
GROUP BY ROLLUP(user_id, post_type)
ORDER BY user_id, post_type
;



SELECT
    CASE WHEN GROUPING(user_id) = 1 THEN '전체' ELSE TO_CHAR(user_id) END AS "사용자",
    CASE WHEN GROUPING(post_type) = 1 THEN '소계' ELSE post_type END AS "게시물 종류",
    SUM(view_count) AS "총 조회수",
    GROUPING(user_id) AS G_USER,
    GROUPING(post_type) AS G_TYPE
FROM
    POSTS
GROUP BY
    CUBE(user_id, post_type);


