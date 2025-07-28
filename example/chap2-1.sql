
-- 합집합 연산
SELECT USER_ID AS "Likes user id", POST_ID, CREATION_DATE FROM LIKES
UNION ALL
SELECT USER_ID AS "Comments user id", COMMENT_ID, CREATION_DATE FROM COMMENTS
ORDER BY 1
;

SELECT USER_ID FROM LIKES
UNION
SELECT USER_ID FROM COMMENTS
;


-- '좋아요'를 누른 사용자의 ID 목록 (중복 제거됨)
SELECT user_id FROM LIKES
INTERSECT
-- '댓글'을 작성한 사용자의 ID 목록 (중복 제거됨)
SELECT user_id FROM COMMENTS
;


-- '좋아요'를 누른 사용자의 ID 목록
SELECT user_id FROM LIKES
MINUS
-- '댓글'을 작성한 사용자의 ID 목록
SELECT user_id FROM COMMENTS
;