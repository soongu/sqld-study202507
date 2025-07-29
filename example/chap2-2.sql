
-- 라이언이 작성한 모든 게시물을 조회
SELECT *
FROM POSTS 
WHERE USER_ID = (
  SELECT USER_ID
  FROM USERS 
  WHERE USERNAME = 'ryan'
)
;

SELECT USER_ID
FROM USERS 
WHERE USERNAME = 'ryan'
;


-- 우리 피드 데이터에서 평균조회수보다 높은 조회수를 가진 게시물 조회
-- 평균조회수를 구해봄
SELECT AVG(VIEW_COUNT)
FROM POSTS
;

SELECT * 
FROM POSTS
WHERE VIEW_COUNT  > (
  SELECT AVG(VIEW_COUNT)
  FROM POSTS
)
;


-- 카카오그룹에 있는 사용자의 모든 아이디를 조회
SELECT user_id          
FROM USERS
WHERE manager_id = 1
;
-- 카카오그룹에 있는 사용자들이 작성한 모든 피드 조회
SELECT * 
FROM POSTS 
WHERE USER_ID IN (
  SELECT user_id          
  FROM USERS
  WHERE manager_id = 1
)
;

-- ANY는 서브쿼리의 결과 중 하나라도 만족하는 경우를 찾음
SELECT * 
FROM POSTS
WHERE VIEW_COUNT > ANY (
  SELECT AVG(VIEW_COUNT)
  FROM POSTS
  GROUP BY USER_ID
)
;

-- ALL은 서브쿼리의 결과 전체를 만족하는 경우를 찾음
SELECT * 
FROM POSTS
WHERE VIEW_COUNT > ALL (
  SELECT AVG(VIEW_COUNT)
  FROM POSTS
  GROUP BY USER_ID
)
;

-- =, <>, <, >, <= , >= 단일행 연산자는 단일행 서브쿼리에만 가능
-- IN, ANY, ALL 다중행 연산자는 다중행 서브쿼리에만 가능

SELECT * 
FROM POSTS
;

SELECT TAG_ID FROM HASHTAGS
WHERE TAG_NAME = '#포켓몬';

SELECT POST_ID FROM POST_TAGS
WHERE TAG_ID = 1003;

SELECT * 
FROM POSTS
WHERE POST_ID IN (
  SELECT POST_ID 
  FROM POST_TAGS
  WHERE TAG_ID = (
    SELECT TAG_ID 
    FROM HASHTAGS
    WHERE TAG_NAME = '#포켓몬'
  )
)
;

SELECT P.*, U.USERNAME
FROM POSTS P
LEFT JOIN USERS U
ON P.USER_ID = U.USER_ID
WHERE P.POST_ID IN (
  SELECT POST_ID 
  FROM POST_TAGS
  WHERE TAG_ID = (
    SELECT TAG_ID 
    FROM HASHTAGS
    WHERE TAG_NAME = '#포켓몬'
  )
)
;

-- 피카츄가 올린 피드에 좋아요찍은 사람들의 이름을 조회
SELECT * FROM LIKES;



-- 피카츄 유저 아이디 찾기
SELECT USER_ID 
FROM USERS
WHERE USERNAME = 'pikachu';

-- 피카츄가 올린 피드의 POST_ID를 찾음
SELECT POST_ID 
FROM POSTS
WHERE USER_ID = 21;

-- 피카츄가 올린 피드에 좋아요 찍은 내용들을 필터링
SELECT USERNAME 
FROM LIKES L
JOIN USERS U
ON L.USER_ID = U.USER_ID
WHERE POST_ID IN (54, 55, 56, 57)
;

SELECT USERNAME 
FROM LIKES L
JOIN USERS U
ON L.USER_ID = U.USER_ID
WHERE POST_ID IN (
  SELECT POST_ID 
  FROM POSTS
  WHERE USER_ID = (
    SELECT USER_ID 
    FROM USERS
    WHERE USERNAME = 'pikachu'
  )
)
;