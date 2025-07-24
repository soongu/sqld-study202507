
SELECT
  USERNAME,
  REGISTRATION_DATE
FROM USERS
ORDER BY REGISTRATION_DATE DESC
;

-- creation_date를 기준으로 내림차순 정렬합니다.
SELECT
    post_id,
    user_id,
    content,
    creation_date
FROM
    POSTS
ORDER BY creation_date DESC
;

-- 1차: post_type 오름차순, 2차: creation_date 내림차순으로 정렬
SELECT
    post_id,
    post_type,
    creation_date
FROM
    POSTS
ORDER BY POST_TYPE, CREATION_DATE DESC
; 


-- 별칭으로도 정렬 가능
SELECT
  USERNAME AS UNAME,
  REGISTRATION_DATE
FROM USERS
ORDER BY UNAME DESC
;

-- 순번으로도 정렬 가능
SELECT
  USERNAME AS UNAME, -- 1번
  REGISTRATION_DATE  -- 2번
FROM USERS
ORDER BY 1
;

SELECT
  USERNAME AS UNAME, -- 1번
  REGISTRATION_DATE  -- 2번
FROM USERS
ORDER BY UNAME DESC, 2 ASC
;

-- 5강에서 배운 GROUP BY를 활용해 사용자별 게시물 수를 구하고,
-- 그 결과(별명: post_count)를 기준으로 내림차순 정렬합니다.
SELECT
    user_id,
    COUNT(*) AS post_count
FROM
    POSTS
GROUP BY
    user_id
-- ORDER BY COUNT(*) DESC
ORDER BY post_count DESC, USER_ID DESC
;

-- user_id가 1이면 1순위, 나머지는 2순위로 정렬 우선순위를 부여하고,
-- 같은 순위 내에서는 creation_date를 기준으로 내림차순 정렬합니다.
SELECT
    post_id,
    user_id,
    content,
    creation_date
FROM
    POSTS
ORDER BY
    CASE
        WHEN user_id = 21 THEN 1 -- user_id가 1이면 1순위
        ELSE 2                   -- 나머지는 2순위
    END,
    creation_date DESC 
;

