-- 사용자이름이 'ryan'인 사용자의 모든 주문을 조회하는 쿼리
SELECT *
FROM USERS
WHERE USERNAME = 'ryan'
;

-- 유저의 아이디가 1번인 사용자가 올린 비디오 게시물
SELECT *
FROM POSTS
WHERE USER_ID = 1 AND POST_TYPE = 'video'
;

-- 유저아이디가 1번인 유저의 모든 피드게시물 또는 모든 유저의 비디오 게시물
SELECT *
FROM POSTS
WHERE USER_ID = 1 OR POST_TYPE = 'video'
;

SELECT *
FROM POSTS
WHERE USER_ID <> 1
;

-- 가입일이 2022년도인 사용자를 찾기
SELECT *
FROM USERS
WHERE REGISTRATION_DATE >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
  AND REGISTRATION_DATE <= TO_DATE('2022-12-31', 'YYYY-MM-DD')
;

-- BETWEEN A AND B
-- A와 B 사이의 값을 조회 (이상 이하 개념)
SELECT *
FROM USERS
WHERE REGISTRATION_DATE BETWEEN TO_DATE('2022-01-01', 'YYYY-MM-DD') 
                            AND TO_DATE('2022-12-31', 'YYYY-MM-DD')
  
;

-- 가입일이 2022년도가 아닌 사용자를 찾기
-- NOT BETWEEN A AND B
-- A와 B 사이의 값을 제외한 나머지 값을 조회 (이상 이하 개념)
SELECT *
FROM USERS
WHERE REGISTRATION_DATE NOT BETWEEN TO_DATE('2022-01-01', 'YYYY-MM-DD') 
                            AND TO_DATE('2022-12-31', 'YYYY-MM-DD')
  
;


-- 유저 아이디가 1 또는 9 또는 21인 사용자 정보 조회
SELECT *
FROM USERS
WHERE USER_ID = 1 OR USER_ID = 9 OR USER_ID = 21
;

-- IN : 특정 값의 집합에 포함되는지 확인
SELECT *
FROM USERS
WHERE USER_ID IN (1, 9, 21)
;

-- NOT IN : 특정 값의 집합에 포함되지 않는지 확인
SELECT *
FROM USERS
WHERE USER_ID NOT IN (1, 9, 21)
;

-- LIKE : 특정 패턴과 일치하는 값을 조회
-- % : 0개 이상의 문자
-- _ : 1개의 문자
-- USERNAME이 'p'으로 시작하는 사용자 조회
SELECT *
FROM USERS
WHERE USERNAME LIKE 'p%'
;

SELECT *
FROM USERS
WHERE USERNAME LIKE '%chu'
;

SELECT *
FROM USERS
WHERE USERNAME LIKE 'r_an' -- ryan, roan, rian
;

-- 해시태그에서 일상이 들어간 해시태그 전체조회
SELECT *
FROM HASHTAGS
WHERE TAG_NAME LIKE '%일상%'
;

-- manager_id가 null인 사용자 조회  
SELECT *
FROM USERS
WHERE MANAGER_ID IS NULL
;

-- IS NULL의 반대는 NOT IS NULL이 아니라 IS NOT NULL
SELECT *
FROM USERS
WHERE MANAGER_ID IS NOT NULL
;