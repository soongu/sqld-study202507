-- 계층형 질의
SELECT USER_ID, USERNAME, MANAGER_ID
FROM USERS
;

SELECT
    LEVEL,
    LPAD(' ', (LEVEL-1) * 4) || username AS "사용자 (조직도)", 
    user_id,
    manager_id
FROM
    USERS
START WITH
    user_id = 11
CONNECT BY
     user_id = PRIOR manager_id
; -- 2. 연결 규칙: 나의 user_id가 다른 사람의 manager_id와 같다면, 그 사람은 나의 부하직원이다.

-- PRIOR가 자식쪽에 붙으면 순방향 전개
-- PRIOR가 부모쪽에 붙으면 역방향 전개
SELECT USER_ID, MANAGER_ID
FROM USERS
ORDER BY USER_ID
;


SELECT 
  COMMENT_ID,
  -- COMMENT_TEXT,
  PARENT_COMMENT_ID
FROM COMMENTS;

SELECT
    LPAD('└> ', (LEVEL-1) * 4) || comment_text AS "댓글 내용",
    LEVEL,
    comment_id,
    parent_comment_id
FROM
    COMMENTS
START WITH
    parent_comment_id IS NULL 
CONNECT BY
    PRIOR comment_id = parent_comment_id
; 

