-- USERS 테이블에서 username을 다양한 형태로 변환해봅시다.
SELECT
    username,
    UPPER(username) AS "대문자로 변환",
    LOWER(username) AS "소문자로 변환",
    INITCAP(username) AS "첫 글자만 대문자"
FROM
    USERS
WHERE
    user_id IN (1, 9, 21); -- 라이언, 헬로키티, 피카츄만 예시로 볼게요!

-- USER_PROFILES 테이블에서 자기소개의 길이와 특정 단어의 위치를 찾아봅시다.
SELECT
    user_id,
    bio,
    LENGTH(bio) AS "자기소개 길이",
    INSTR(bio, '고양이') AS "'고양이'의 위치"
FROM
    USER_PROFILES
WHERE
    user_id IN (2, 8); -- 춘식이와 네오의 프로필을 예시로 볼게요!


-- COMMENTS 테이블에서 댓글 미리보기를 만들어봅시다.
-- comment_text.substring(0, 10)
SELECT
    comment_text AS "원본 댓글",
    SUBSTR(comment_text, 1, 10) || '...' AS "댓글 미리보기",
    CONCAT(user_id, '번 사용자의 댓글') AS "작성자 정보"
    , user_id || '번 사용자의 댓글' AS "작성자 정보 (|| 연산자)"
FROM
    COMMENTS
WHERE
    comment_id = 20001; -- "춘식이 너무 귀여워요! >_<" 댓글을 예시로 볼게요!



SELECT
    LPAD(u.user_id, 5, '0') AS "5자리 사용자 ID",
    RPAD(u.username, 15, '*') AS "오른쪽 채우기",
    REPLACE(p.content, '#일상', '#데일리') AS "해시태그 교체",
    p.CONTENT AS "원본 게시글"
FROM
    USERS u, POSTS p
WHERE
    u.user_id = p.user_id
    AND p.content LIKE '%일상%'
  ; 


-- 가상의 인기 점수를 만들고, user_id를 이용해 짝/홀수를 구분해봅시다.
SELECT
    user_id,
    -- 가상의 인기 점수 (3.141592)
    ROUND(3.141592, 4) AS "인기점수 (반올림)",
    TRUNC(3.141592, 4) AS "인기점수 (버림)",
    CEIL(3.14) AS "인기점수 (올림)",
    FLOOR(3.14) AS "인기점수 (내림)",
    MOD(user_id, 2) AS "짝홀 구분 (0이면 짝수, 1이면 홀수)"
FROM
    USERS
WHERE
    user_id BETWEEN 1 AND 5; -- 1~5번 사용자만 예시로 볼게요!


-- 1번 게시물이 등록된 시점을 기준으로 날짜 연산을 해봅시다.
-- SYSDATE는 현재 시스템의 날짜와 시간을 반환하는 함수입니다.
SELECT
    creation_date AS "게시물 등록 시각",
    creation_date + 1 AS "24시간 뒤 (하루 뒤)",
    creation_date + (1/24) AS "1시간 뒤",
    SYSDATE - creation_date AS "등록 후 흐른 시간 (일 단위)"
FROM
    POSTS
WHERE
    post_id = 1;

  -- TO_CHAR 함수로 날짜를 예쁜 문자로 바꿔봅시다.
SELECT
    username,
    registration_date,
    TO_CHAR(registration_date, 'YYYY"년" MM"월" DD"일" MI"분"') AS "가입일 (상세)",
    TO_CHAR(registration_date, 'YYYY-MM-DD (DY)') AS "가입일 (요일포함)"
FROM
    USERS
WHERE
    user_id = 1; -- 1번 사용자 '라이언'을 예시로 볼게요!

-- TO_DATE 함수로 문자열을 날짜로 바꿔서 WHERE절에 사용해봅시다.
SELECT *
FROM POSTS
WHERE creation_date > TO_DATE('2024-05-20', 'YYYY-MM-DD');

-- 춘식이(bio 있음)와 케로피(bio 없음)의 프로필을 예시로 NULL 함수를 써봅시다.

SELECT
    u.username,
    p.bio,
    NVL(p.bio, '자기소개가 없습니다.') AS "NVL 처리",
    NVL2(p.bio, '✅ 프로필 있음', '❌ 프로필 없음') AS "NVL2 처리"
FROM
    USERS u, USER_PROFILES p
WHERE
    u.user_id = p.user_id(+) AND u.user_id IN (2, 14);


SELECT NULLIF('손흥민', '손흥민') AS "NULLIF 예시",
       NULLIF('손흥민', '박지성') AS "NULLIF 예시 (같은 값)"
FROM DUAL 
; 

SELECT 
  COALESCE(null, null, 50, 100, 999, 1000) A,
  COALESCE(900, null, null, 100) B,
  COALESCE(null, 888, 50, null) C
FROM DUAL
; 

-- 가입 연도에 따라 등급을 나누고, 게시물 종류를 한글로 바꿔봅시다.
SELECT
    username,
    registration_date,
    CASE
        WHEN TO_CHAR(registration_date, 'YYYY') >= '2023' THEN '🌱 새싹 유저'
        WHEN TO_CHAR(registration_date, 'YYYY') >= '2021' THEN '🌳 기존 유저'
        ELSE '💎 고인물 유저'
    END AS "유저 등급",
    p.post_type,

    CASE p.POST_TYPE
        WHEN 'photo' THEN '사진'
        WHEN 'video' THEN '영상'
        ELSE '기타'
    END AS "게시물 종류"
FROM
    USERS u, POSTS p
WHERE
    u.user_id = p.user_id;

