-- =====================================================================
-- SQLD 자격증 대비 교육용 스키마 (Instagram 모델)
-- 데이터베이스: Oracle
-- 작성자: Soongu Hong
-- 최종 수정일: 2025-06-23
-- =====================================================================

-- =====================================================================
-- 파트 A: 스키마 정리 (Housekeeping)
-- 기존 테이블 및 제약조건을 깨끗하게 삭제합니다.
-- CASCADE CONSTRAINTS 옵션은 외래 키 종속성 순서에 상관없이 삭제를 가능하게 합니다.
-- =====================================================================
-- 최종 수정 코드 (가장 확실한 버전)
BEGIN
    FOR c IN (SELECT object_name 
              FROM all_objects
              WHERE owner = USER 
                AND object_type = 'TABLE'
                AND oracle_maintained = 'N')
    LOOP
        -- 테이블 이름에 혹시 모를 특수문자나 대소문자 구분이 포함될 경우를 대비해 큰따옴표로 감싸줍니다.
        EXECUTE IMMEDIATE 'DROP TABLE "' || c.object_name || '" CASCADE CONSTRAINTS';
    END LOOP;
END;
/

-- =====================================================================
-- 파트 B: 스키마 생성 (DDL - Tables and Primary Keys)
-- 8개의 테이블을 생성하고 기본 키, 고유 키, Not Null 제약조건을 정의합니다.
-- =====================================================================

-- 테이블 1: USERS (사용자)
CREATE TABLE USERS (
    user_id           NUMBER          CONSTRAINT pk_users PRIMARY KEY,
    username          VARCHAR2(50)    CONSTRAINT uq_users_username UNIQUE NOT NULL,
    email             VARCHAR2(100)   CONSTRAINT uq_users_email UNIQUE NOT NULL,
    registration_date DATE            NOT NULL,
    last_login_date   DATE,
    manager_id        NUMBER          -- 자기참조 외래 키
);
COMMENT ON TABLE USERS IS '애플리케이션 사용자 정보를 저장하는 테이블';
COMMENT ON COLUMN USERS.user_id IS '사용자 고유 ID (PK)';
COMMENT ON COLUMN USERS.manager_id IS '관리자 ID (자기참조용)';


-- 테이블 2: USER_PROFILES (사용자 프로필) - USERS와 1:1 관계
CREATE TABLE USER_PROFILES (
    user_id             NUMBER          CONSTRAINT pk_user_profiles PRIMARY KEY,
    full_name           VARCHAR2(100),
    bio                 VARCHAR2(255),
    profile_picture_url VARCHAR2(255)
);
COMMENT ON TABLE USER_PROFILES IS '사용자의 부가적인 프로필 정보를 저장하는 테이블 (USERS와 1:1)';


-- 테이블 3: POSTS (게시물)
CREATE TABLE POSTS (
    post_id       NUMBER          CONSTRAINT pk_posts PRIMARY KEY,
    user_id       NUMBER          NOT NULL,
    content       VARCHAR2(1000),
    post_type     VARCHAR2(10)    CONSTRAINT chk_posts_type CHECK (post_type IN ('photo', 'video')),
    creation_date TIMESTAMP       NOT NULL
);
COMMENT ON TABLE POSTS IS '사용자가 작성한 게시물 정보를 저장하는 테이블';


-- 테이블 4: COMMENTS (댓글)
CREATE TABLE COMMENTS (
    comment_id        NUMBER          CONSTRAINT pk_comments PRIMARY KEY,
    post_id           NUMBER          NOT NULL,
    user_id           NUMBER          NOT NULL,
    comment_text      VARCHAR2(1000)  NOT NULL,
    creation_date     DATE            NOT NULL,
    parent_comment_id NUMBER          -- 계층 구조를 위한 자기참조 외래 키
);
COMMENT ON TABLE COMMENTS IS '게시물에 달린 댓글 정보를 저장하는 테이블';
COMMENT ON COLUMN COMMENTS.parent_comment_id IS '부모 댓글 ID (계층형 쿼리용)';


-- 테이블 5: HASHTAGS (해시태그)
CREATE TABLE HASHTAGS (
    tag_id    NUMBER          CONSTRAINT pk_hashtags PRIMARY KEY,
    tag_name  VARCHAR2(100)   CONSTRAINT uq_hashtags_name UNIQUE NOT NULL
);
COMMENT ON TABLE HASHTAGS IS '고유한 해시태그 목록을 관리하는 조회용 테이블';


-- 테이블 6: LIKES (좋아요) - USERS와 POSTS의 N:M 관계 해소
CREATE TABLE LIKES (
    user_id       NUMBER,
    post_id       NUMBER,
    creation_date DATE    NOT NULL,
    CONSTRAINT pk_likes PRIMARY KEY (user_id, post_id)
);
COMMENT ON TABLE LIKES IS '사용자와 게시물 간의 "좋아요" 관계를 나타내는 연결 테이블';


-- 테이블 7: FOLLOWS (팔로우) - USERS와 USERS의 N:M 관계 해소
CREATE TABLE FOLLOWS (
    follower_id   NUMBER,
    following_id  NUMBER,
    creation_date DATE    NOT NULL,
    CONSTRAINT pk_follows PRIMARY KEY (follower_id, following_id)
);
COMMENT ON TABLE FOLLOWS IS '사용자 간의 "팔로우" 관계를 나타내는 연결 테이블';


-- 테이블 8: POST_TAGS (게시물-태그) - POSTS와 HASHTAGS의 N:M 관계 해소
CREATE TABLE POST_TAGS (
    post_id NUMBER,
    tag_id  NUMBER,
    CONSTRAINT pk_post_tags PRIMARY KEY (post_id, tag_id)
);
COMMENT ON TABLE POST_TAGS IS '게시물과 해시태그의 관계를 나타내는 교차 테이블';



-- =====================================================================
-- 파트 D-1: 사용자 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: 카카오프렌즈, 산리오, 포켓몬스터 캐릭터 (총 40명)
-- 계층 구조를 포함하여 다양한 쿼리 실습이 가능하도록 설계되었습니다.
-- =====================================================================

INSERT ALL
    -- 카카오프렌즈 (8명) - 대표: 라이언(1)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (1, 'ryan', 'ryan@example.com', TO_DATE('2020-02-08', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), 40)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (2, 'choonsik', 'choonsik@example.com', TO_DATE('2021-07-21', 'YYYY-MM-DD'), TO_DATE('2024-05-18', 'YYYY-MM-DD'), 1)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (3, 'apeach', 'apeach@example.com', TO_DATE('2020-03-15', 'YYYY-MM-DD'), TO_DATE('2024-05-19', 'YYYY-MM-DD'), 1)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (4, 'little_apeach', 'little_apeach@example.com', TO_DATE('2022-08-01', 'YYYY-MM-DD'), TO_DATE('2024-05-15', 'YYYY-MM-DD'), 3)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (5, 'muzi', 'muzi@example.com', TO_DATE('2020-04-10', 'YYYY-MM-DD'), TO_DATE('2024-04-30', 'YYYY-MM-DD'), 1)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (6, 'con', 'con@example.com', TO_DATE('2020-04-11', 'YYYY-MM-DD'), TO_DATE('2023-12-31', 'YYYY-MM-DD'), 5)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (7, 'frodo', 'frodo@example.com', TO_DATE('2020-05-01', 'YYYY-MM-DD'), TO_DATE('2024-05-01', 'YYYY-MM-DD'), 1)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (8, 'neo', 'neo@example.com', TO_DATE('2020-05-02', 'YYYY-MM-DD'), TO_DATE('2024-05-17', 'YYYY-MM-DD'), 7)

    -- 산리오 (12명) - 대표: 헬로키티(9)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (9, 'hello_kitty', 'kitty@example.com', TO_DATE('2020-01-10', 'YYYY-MM-DD'), TO_DATE('2024-05-21', 'YYYY-MM-DD'), 40)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (10, 'my_melody', 'melody@example.com', TO_DATE('2020-06-01', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), 9)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (11, 'kuromi', 'kuromi@example.com', TO_DATE('2020-06-02', 'YYYY-MM-DD'), TO_DATE('2024-05-19', 'YYYY-MM-DD'), 9)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (12, 'cinnamoroll', 'cinnamoroll@example.com', TO_DATE('2020-07-01', 'YYYY-MM-DD'), TO_DATE('2024-05-18', 'YYYY-MM-DD'), 9)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (13, 'pompompurin', 'pompompurin@example.com', TO_DATE('2020-07-05', 'YYYY-MM-DD'), TO_DATE('2024-05-17', 'YYYY-MM-DD'), 9)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (14, 'keroppi', 'keroppi@example.com', TO_DATE('2021-01-15', 'YYYY-MM-DD'), TO_DATE('2024-05-16', 'YYYY-MM-DD'), 12)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (15, 'badtz_maru', 'badtz_maru@example.com', TO_DATE('2021-02-20', 'YYYY-MM-DD'), TO_DATE('2024-05-15', 'YYYY-MM-DD'), 11)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (16, 'gudetama', 'gudetama@example.com', TO_DATE('2021-03-10', 'YYYY-MM-DD'), TO_DATE('2023-11-11', 'YYYY-MM-DD'), 13)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (17, 'kiki', 'kiki@example.com', TO_DATE('2021-08-10', 'YYYY-MM-DD'), TO_DATE('2024-05-10', 'YYYY-MM-DD'), 12)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (18, 'lala', 'lala@example.com', TO_DATE('2021-08-10', 'YYYY-MM-DD'), TO_DATE('2024-05-10', 'YYYY-MM-DD'), 12)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (19, 'pochacco', 'pochacco@example.com', TO_DATE('2022-04-05', 'YYYY-MM-DD'), TO_DATE('2024-05-09', 'YYYY-MM-DD'), 14)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (20, 'hangyodon', 'hangyodon@example.com', TO_DATE('2022-05-15', 'YYYY-MM-DD'), TO_DATE('2024-05-08', 'YYYY-MM-DD'), 15)

    -- 포켓몬스터 (20명) - 대표: 뮤츠(32)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (21, 'pikachu', 'pikachu@example.com', TO_DATE('2020-09-01', 'YYYY-MM-DD'), TO_DATE('2024-05-21', 'YYYY-MM-DD'), 32)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (22, 'charmander', 'charmander@example.com', TO_DATE('2020-09-02', 'YYYY-MM-DD'), TO_DATE('2024-05-20', 'YYYY-MM-DD'), 21)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (23, 'squirtle', 'squirtle@example.com', TO_DATE('2020-09-03', 'YYYY-MM-DD'), TO_DATE('2024-05-19', 'YYYY-MM-DD'), 21)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (24, 'bulbasaur', 'bulbasaur@example.com', TO_DATE('2020-09-04', 'YYYY-MM-DD'), TO_DATE('2024-05-18', 'YYYY-MM-DD'), 21)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (25, 'jigglypuff', 'jigglypuff@example.com', TO_DATE('2020-10-10', 'YYYY-MM-DD'), TO_DATE('2024-05-17', 'YYYY-MM-DD'), 31)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (26, 'snorlax', 'snorlax@example.com', TO_DATE('2020-10-15', 'YYYY-MM-DD'), TO_DATE('2024-03-20', 'YYYY-MM-DD'), 31)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (27, 'eevee', 'eevee@example.com', TO_DATE('2020-11-01', 'YYYY-MM-DD'), TO_DATE('2024-05-16', 'YYYY-MM-DD'), 21)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (28, 'meowth', 'meowth@example.com', TO_DATE('2020-11-05', 'YYYY-MM-DD'), TO_DATE('2024-05-15', 'YYYY-MM-DD'), 39)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (29, 'psyduck', 'psyduck@example.com', TO_DATE('2020-12-01', 'YYYY-MM-DD'), TO_DATE('2024-05-14', 'YYYY-MM-DD'), 39)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (30, 'gengar', 'gengar@example.com', TO_DATE('2020-12-10', 'YYYY-MM-DD'), TO_DATE('2024-05-13', 'YYYY-MM-DD'), 39)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (31, 'dragonite', 'dragonite@example.com', TO_DATE('2021-01-20', 'YYYY-MM-DD'), TO_DATE('2024-05-12', 'YYYY-MM-DD'), 32)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (32, 'mewtwo', 'mewtwo@example.com', TO_DATE('2020-01-01', 'YYYY-MM-DD'), TO_DATE('2024-05-21', 'YYYY-MM-DD'), 40)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (33, 'mew', 'mew@example.com', TO_DATE('2020-01-02', 'YYYY-MM-DD'), TO_DATE('2024-05-11', 'YYYY-MM-DD'), 32)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (34, 'ditto', 'ditto@example.com', TO_DATE('2022-02-02', 'YYYY-MM-DD'), TO_DATE('2024-05-10', 'YYYY-MM-DD'), 33)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (35, 'magikarp', 'magikarp@example.com', TO_DATE('2022-03-03', 'YYYY-MM-DD'), TO_DATE('2024-05-09', 'YYYY-MM-DD'), 33)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (36, 'gyarados', 'gyarados@example.com', TO_DATE('2023-04-04', 'YYYY-MM-DD'), TO_DATE('2024-05-08', 'YYYY-MM-DD'), 35)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (37, 'togepi', 'togepi@example.com', TO_DATE('2023-05-05', 'YYYY-MM-DD'), TO_DATE('2024-05-07', 'YYYY-MM-DD'), 25)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (38, 'piplup', 'piplup@example.com', TO_DATE('2023-06-06', 'YYYY-MM-DD'), TO_DATE('2024-05-06', 'YYYY-MM-DD'), 23)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (39, 'lucario', 'lucario@example.com', TO_DATE('2021-02-25', 'YYYY-MM-DD'), TO_DATE('2024-05-05', 'YYYY-MM-DD'), 32)
    INTO USERS (user_id, username, email, registration_date, last_login_date, manager_id) VALUES (40, 'prof_oak', 'prof_oak@example.com', TO_DATE('2019-12-25', 'YYYY-MM-DD'), TO_DATE('2024-05-21', 'YYYY-MM-DD'), NULL)
SELECT 1 FROM DUAL;

COMMIT; -- 최종 확정

-- USER_PROFILES 테이블 더미 데이터 (OUTER JOIN 실습용)
-- 전체 40명의 사용자 중 30명에게만 프로필 정보를 부여합니다.
INSERT ALL
    -- Kakao Friends (8명)
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (1, 'Ryan the Lion', '갈기가 없어도 사자입니다. 모두의 든든한 조언자, 라이언.', '/img/profile/ryan.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (2, 'Choonsik the Cat', '라이언이 키우는 길고양이, 춘식이입니다. 고구마를 제일 좋아해요.', '/img/profile/choonsik.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (3, 'Cutie Apeach', '뒤태가 매력적인 악동 복숭아 어피치!', '/img/profile/apeach.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (4, 'Little Mischief Apeach', '어피치를 쏙 빼닮은 리틀어피치!', '/img/profile/little_apeach.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (5, 'Muzi Rabbit-Tume', '토끼 옷을 입은 단무지 무지. 콘은 나의 가장 친한 친구!', '/img/profile/muzi.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (6, 'Mysterious Con', '무지를 키워낸 미스터리한 악어, 콘입니다.', '/img/profile/con.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (7, 'Frodo the City Dog', '부잣집 도시개 프로도. 네오를 사랑해요.', '/img/profile/frodo.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (8, 'Neo the Cat', '새침한 패셔니스타 고양이 네오. 내 단발머리의 비결이 궁금해?', '/img/profile/neo.png')

    -- Sanrio (8명) - 케로피, 키키, 라라, 포차코는 프로필 없음
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (9, 'Hello Kitty White', '밝고 상냥한 마음을 가진 리본이 잘 어울리는 친구, 헬로키티예요.', '/img/profile/hello_kitty.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (10, 'My Melody', '솔직하고 명랑한 마이멜로디. 모두와 사이좋게 지내는 게 꿈이야.', '/img/profile/my_melody.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (11, 'Kuromi', '내 이름은 쿠로미! 내가 최고라고! 멜로디는 나의 라이벌!', '/img/profile/kuromi.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (12, 'Cinnamoroll', '먼 하늘 구름 위에서 태어난 강아지, 시나모롤. 카페 시나몬에서 기다릴게!', '/img/profile/cinnamoroll.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (13, 'Pompompurin', '흐물흐물~ 느긋하고 여유로운 골든 리트리버, 폼폼푸린입니다.', '/img/profile/pompompurin.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (15, 'Badtz-Maru', '심술궂어 보이지만 사실은 좋은 녀석, 배드바츠마루.', '/img/profile/badtz_maru.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (16, 'Gudetama the Lazy Egg', '어차피 할 거 내일 하자... 흐물흐물 게으른 계란 구데타마...', '/img/gudetama.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (20, 'Hangyodon', '사실은 외로움을 많이 타는 로맨티스트, 한교동.', '/img/hangyodon.png')

    -- Pokemon (14명) - 싸이덕, 갱도라, 잉어킹, 토게피, 팽도리, 루카리오는 프로필 없음
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (21, 'Pikachu', '피카피카! 언제나 지우와 함께! 백만볼트가 특기야!', '/img/profile/pikachu.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (22, 'Charmander', '내 꼬리의 불꽃이 꺼지지 않게 조심해줘! 파이리!', '/img/profile/charmander.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (23, 'Squirtle', '등껍질에 숨는 걸 좋아해. 물대포 발사! 꼬부기!', '/img/profile/squirtle.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (24, 'Bulbasaur', '씨앗을 등에 지고 태어났어. 햇빛을 받으면 기운이 나! 이상해씨!', '/img/profile/bulbasaur.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (25, 'Jigglypuff', '내 노래를 끝까지 들은 포켓몬은 아무도 없지. 자장자장~ 푸푸린~', '/img/profile/jigglypuff.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (26, 'Snorlax', '먹고 자는 게 세상에서 제일 좋아... Zzzz... 잠만보...', '/img/profile/snorlax.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (27, 'Eevee', '다양한 모습으로 진화할 수 있는 잠재력을 가진 이브이!', '/img/profile/eevee.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (28, 'Meowth', '로켓단의 아이돌! 말하는 나옹이다옹~', '/img/profile/meowth.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (31, 'Dragonite', '바다의 화신이라 불리는 상냥한 포켓몬, 망나뇽입니다.', '/img/profile/dragonite.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (32, 'Mewtwo', '나는 누구인가. 나는 왜 여기에 있는가... 최강의 포켓몬 뮤츠.', '/img/profile/mewtwo.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (33, 'Mew', '모든 포켓몬의 유전자를 가졌다고 전해지는 환상의 포켓몬 뮤.', '/img/profile/mew.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (34, 'Ditto', '메타몽! 어떤 포켓몬으로든 변신할 수 있어!', '/img/profile/ditto.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (36, 'Gyarados', '잉어킹 시절의 설움을 기억하라! 흉포한 포켓몬 갸라도스.', '/img/profile/gyarados.png')
    INTO USER_PROFILES (user_id, full_name, bio, profile_picture_url) VALUES (40, 'Professor Samuel Oak', '모든 포켓몬의 비밀을 연구하는 오박사라네. 포켓몬 도감을 채워보지 않겠나?', '/img/profile/prof_oak.png')
SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-2: 팔로우 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: 사용자 간의 팔로우 관계 설정. N:M 관계 해소 테이블
-- 특징: 
-- 1. 대부분의 유저는 3~10명의 다른 유저를 팔로우
-- 2. 라이언(1), 피카츄(21)는 30명 이상의 팔로워를 가진 인플루언서로 설정
-- =====================================================================
INSERT ALL
    -- 1. ryan (팔로잉: 6명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 2, TO_DATE('2022-01-01', 'YYYY-MM-DD')) -- choonsik
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 3, TO_DATE('2022-01-01', 'YYYY-MM-DD')) -- apeach
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 9, TO_DATE('2022-01-02', 'YYYY-MM-DD')) -- hello_kitty (다른 그룹 리더)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 32, TO_DATE('2022-01-02', 'YYYY-MM-DD')) -- mewtwo (다른 그룹 리더)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 40, TO_DATE('2022-01-03', 'YYYY-MM-DD')) -- prof_oak (총괄 매니저)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (1, 21, TO_DATE('2023-01-01', 'YYYY-MM-DD')) -- pikachu (인플루언서)

    -- 2. choonsik (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (2, 1, TO_DATE('2022-02-01', 'YYYY-MM-DD')) -- ryan (매니저)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (2, 27, TO_DATE('2022-02-02', 'YYYY-MM-DD')) -- eevee (귀여움)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (2, 12, TO_DATE('2022-02-03', 'YYYY-MM-DD')) -- cinnamoroll (귀여움)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (2, 26, TO_DATE('2022-02-04', 'YYYY-MM-DD')) -- snorlax (먹는 거 좋아함)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (2, 21, TO_DATE('2023-02-01', 'YYYY-MM-DD')) -- pikachu (인플루언서)

    -- 3. apeach (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (3, 1, TO_DATE('2022-03-01', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (3, 4, TO_DATE('2022-03-02', 'YYYY-MM-DD')) -- little_apeach
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (3, 11, TO_DATE('2022-03-03', 'YYYY-MM-DD')) -- kuromi (악동 기질)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (3, 30, TO_DATE('2022-03-04', 'YYYY-MM-DD')) -- gengar (장난꾸러기)

    -- 4. little_apeach (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (4, 3, TO_DATE('2022-08-02', 'YYYY-MM-DD')) -- apeach (매니저)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (4, 1, TO_DATE('2022-08-03', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (4, 37, TO_DATE('2022-08-04', 'YYYY-MM-DD')) -- togepi (아기)

    -- 5. muzi (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (5, 1, TO_DATE('2022-04-11', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (5, 6, TO_DATE('2022-04-12', 'YYYY-MM-DD')) -- con
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (5, 24, TO_DATE('2022-04-13', 'YYYY-MM-DD')) -- bulbasaur (초록색 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (5, 21, TO_DATE('2023-04-11', 'YYYY-MM-DD')) -- pikachu

    -- 6. con (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (6, 5, TO_DATE('2022-04-12', 'YYYY-MM-DD')) -- muzi
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (6, 1, TO_DATE('2022-04-13', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (6, 3, TO_DATE('2022-04-14', 'YYYY-MM-DD')) -- apeach

    -- 7. frodo (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (7, 8, TO_DATE('2022-05-03', 'YYYY-MM-DD')) -- neo (연인)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (7, 1, TO_DATE('2022-05-04', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (7, 21, TO_DATE('2023-05-03', 'YYYY-MM-DD')) -- pikachu

    -- 8. neo (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (8, 7, TO_DATE('2022-05-03', 'YYYY-MM-DD')) -- frodo (연인)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (8, 1, TO_DATE('2022-05-04', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (8, 9, TO_DATE('2022-05-05', 'YYYY-MM-DD')) -- hello_kitty (고양이 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (8, 28, TO_DATE('2022-05-06', 'YYYY-MM-DD')) -- meowth (고양이 친구)

    -- 9. hello_kitty (팔로잉: 6명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 10, TO_DATE('2022-01-11', 'YYYY-MM-DD')) -- my_melody
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 12, TO_DATE('2022-01-11', 'YYYY-MM-DD')) -- cinnamoroll
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 1, TO_DATE('2022-01-12', 'YYYY-MM-DD')) -- ryan (다른 그룹 리더)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 32, TO_DATE('2022-01-12', 'YYYY-MM-DD')) -- mewtwo (다른 그룹 리더)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 40, TO_DATE('2022-01-13', 'YYYY-MM-DD')) -- prof_oak
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (9, 21, TO_DATE('2023-01-11', 'YYYY-MM-DD')) -- pikachu
    
    -- 10. my_melody (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (10, 9, TO_DATE('2022-06-02', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (10, 11, TO_DATE('2022-06-02', 'YYYY-MM-DD')) -- kuromi (라이벌이자 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (10, 1, TO_DATE('2022-06-03', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (10, 21, TO_DATE('2023-06-02', 'YYYY-MM-DD')) -- pikachu
    
    -- 11. kuromi (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (11, 9, TO_DATE('2022-06-03', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (11, 10, TO_DATE('2022-06-03', 'YYYY-MM-DD')) -- my_melody (라이벌)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (11, 15, TO_DATE('2022-06-04', 'YYYY-MM-DD')) -- badtz_maru (악동 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (11, 30, TO_DATE('2022-06-05', 'YYYY-MM-DD')) -- gengar (악동 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (11, 1, TO_DATE('2022-06-06', 'YYYY-MM-DD')) -- ryan
    
    -- 12. cinnamoroll (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (12, 9, TO_DATE('2022-07-02', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (12, 17, TO_DATE('2022-07-03', 'YYYY-MM-DD')) -- kiki
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (12, 18, TO_DATE('2022-07-03', 'YYYY-MM-DD')) -- lala
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (12, 21, TO_DATE('2023-07-02', 'YYYY-MM-DD')) -- pikachu
    
    -- 13. pompompurin (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (13, 9, TO_DATE('2022-07-06', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (13, 16, TO_DATE('2022-07-07', 'YYYY-MM-DD')) -- gudetama (느긋함)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (13, 26, TO_DATE('2022-07-08', 'YYYY-MM-DD')) -- snorlax (느긋함)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (13, 1, TO_DATE('2022-07-09', 'YYYY-MM-DD')) -- ryan

    -- 14. keroppi (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (14, 12, TO_DATE('2022-01-16', 'YYYY-MM-DD')) -- cinnamoroll
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (14, 19, TO_DATE('2022-01-17', 'YYYY-MM-DD')) -- pochacco (강아지 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (14, 23, TO_DATE('2022-01-18', 'YYYY-MM-DD')) -- squirtle (물 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (14, 21, TO_DATE('2023-01-16', 'YYYY-MM-DD')) -- pikachu

    -- 15. badtz_maru (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (15, 11, TO_DATE('2022-02-21', 'YYYY-MM-DD')) -- kuromi
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (15, 20, TO_DATE('2022-02-22', 'YYYY-MM-DD')) -- hangyodon
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (15, 30, TO_DATE('2022-02-23', 'YYYY-MM-DD')) -- gengar
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (15, 1, TO_DATE('2022-02-24', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (15, 21, TO_DATE('2023-02-21', 'YYYY-MM-DD')) -- pikachu

    -- 16. gudetama (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (16, 13, TO_DATE('2022-03-11', 'YYYY-MM-DD')) -- pompompurin
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (16, 26, TO_DATE('2022-03-12', 'YYYY-MM-DD')) -- snorlax
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (16, 34, TO_DATE('2022-03-13', 'YYYY-MM-DD')) -- ditto (흐물흐물)

    -- 17. kiki & 18. lala (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (17, 18, TO_DATE('2022-08-11', 'YYYY-MM-DD')) -- lala
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (17, 12, TO_DATE('2022-08-11', 'YYYY-MM-DD')) -- cinnamoroll
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (17, 9, TO_DATE('2022-08-12', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (17, 1, TO_DATE('2022-08-13', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (17, 21, TO_DATE('2023-08-11', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (18, 17, TO_DATE('2022-08-11', 'YYYY-MM-DD')) -- kiki
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (18, 12, TO_DATE('2022-08-11', 'YYYY-MM-DD')) -- cinnamoroll
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (18, 9, TO_DATE('2022-08-12', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (18, 1, TO_DATE('2022-08-13', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (18, 21, TO_DATE('2023-08-11', 'YYYY-MM-DD')) -- pikachu

    -- 19. pochacco (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (19, 14, TO_DATE('2022-04-06', 'YYYY-MM-DD')) -- keroppi
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (19, 9, TO_DATE('2022-04-07', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (19, 1, TO_DATE('2022-04-08', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (19, 21, TO_DATE('2023-04-06', 'YYYY-MM-DD')) -- pikachu

    -- 20. hangyodon (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (20, 15, TO_DATE('2022-05-16', 'YYYY-MM-DD')) -- badtz_maru
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (20, 9, TO_DATE('2022-05-17', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (20, 1, TO_DATE('2022-05-18', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (20, 21, TO_DATE('2023-05-16', 'YYYY-MM-DD')) -- pikachu

    -- 포켓몬스터 -------------------------------------------------------------
    -- 21. pikachu (팔로잉: 8명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 40, TO_DATE('2021-09-02', 'YYYY-MM-DD')) -- prof_oak (트레이너의 스승)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 32, TO_DATE('2021-09-02', 'YYYY-MM-DD')) -- mewtwo (라이벌)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 22, TO_DATE('2021-09-03', 'YYYY-MM-DD')) -- charmander (동료)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 23, TO_DATE('2021-09-03', 'YYYY-MM-DD')) -- squirtle (동료)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 24, TO_DATE('2021-09-03', 'YYYY-MM-DD')) -- bulbasaur (동료)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 27, TO_DATE('2021-09-04', 'YYYY-MM-DD')) -- eevee (인기 포켓몬)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 1, TO_DATE('2022-09-02', 'YYYY-MM-DD')) -- ryan (인플루언서)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (21, 9, TO_DATE('2022-09-02', 'YYYY-MM-DD')) -- hello_kitty (인플루언서)

    -- 22. charmander (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (22, 21, TO_DATE('2021-09-03', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (22, 31, TO_DATE('2021-09-04', 'YYYY-MM-DD')) -- dragonite (진화형 존경)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (22, 1, TO_DATE('2022-09-03', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (22, 32, TO_DATE('2022-09-04', 'YYYY-MM-DD')) -- mewtwo

    -- 23. squirtle (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (23, 21, TO_DATE('2021-09-04', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (23, 36, TO_DATE('2021-09-05', 'YYYY-MM-DD')) -- gyarados (물타입 선배)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (23, 38, TO_DATE('2021-09-06', 'YYYY-MM-DD')) -- piplup (물타입 동료)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (23, 1, TO_DATE('2022-09-04', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (23, 20, TO_DATE('2022-09-05', 'YYYY-MM-DD')) -- hangyodon (물 친구)
    
    -- 24. bulbasaur (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (24, 21, TO_DATE('2021-09-05', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (24, 14, TO_DATE('2021-09-06', 'YYYY-MM-DD')) -- keroppi (풀타입 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (24, 1, TO_DATE('2022-09-05', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (24, 5, TO_DATE('2022-09-06', 'YYYY-MM-DD')) -- muzi
    
    -- 25. jigglypuff (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (25, 21, TO_DATE('2021-10-11', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (25, 37, TO_DATE('2021-10-12', 'YYYY-MM-DD')) -- togepi
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (25, 10, TO_DATE('2021-10-13', 'YYYY-MM-DD')) -- my_melody (핑크 친구)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (25, 3, TO_DATE('2021-10-14', 'YYYY-MM-DD')) -- apeach (핑크 친구)

    -- 26. snorlax (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (26, 21, TO_DATE('2021-10-16', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (26, 13, TO_DATE('2021-10-17', 'YYYY-MM-DD')) -- pompompurin
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (26, 16, TO_DATE('2021-10-18', 'YYYY-MM-DD')) -- gudetama
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (26, 2, TO_DATE('2021-10-19', 'YYYY-MM-DD')) -- choonsik
    
    -- 27. eevee (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (27, 21, TO_DATE('2021-11-02', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (27, 34, TO_DATE('2021-11-03', 'YYYY-MM-DD')) -- ditto
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (27, 1, TO_DATE('2022-11-02', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (27, 9, TO_DATE('2022-11-03', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (27, 12, TO_DATE('2022-11-04', 'YYYY-MM-DD')) -- cinnamoroll

    -- 28. meowth (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (28, 39, TO_DATE('2021-11-06', 'YYYY-MM-DD')) -- lucario
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (28, 8, TO_DATE('2021-11-07', 'YYYY-MM-DD')) -- neo (고양이)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (28, 1, TO_DATE('2022-11-06', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (28, 21, TO_DATE('2022-11-06', 'YYYY-MM-DD')) -- pikachu
    
    -- 29. psyduck (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (29, 21, TO_DATE('2021-12-02', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (29, 40, TO_DATE('2021-12-03', 'YYYY-MM-DD')) -- prof_oak
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (29, 1, TO_DATE('2022-12-02', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (29, 9, TO_DATE('2022-12-03', 'YYYY-MM-DD')) -- hello_kitty
    
    -- 30. gengar (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (30, 21, TO_DATE('2021-12-11', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (30, 11, TO_DATE('2021-12-12', 'YYYY-MM-DD')) -- kuromi
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (30, 15, TO_DATE('2021-12-13', 'YYYY-MM-DD')) -- badtz_maru
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (30, 32, TO_DATE('2021-12-14', 'YYYY-MM-DD')) -- mewtwo

    -- 31. dragonite (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (31, 32, TO_DATE('2022-01-21', 'YYYY-MM-DD')) -- mewtwo
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (31, 21, TO_DATE('2022-01-22', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (31, 36, TO_DATE('2022-01-23', 'YYYY-MM-DD')) -- gyarados
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (31, 1, TO_DATE('2023-01-21', 'YYYY-MM-DD')) -- ryan
    
    -- 32. mewtwo (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (32, 40, TO_DATE('2021-01-02', 'YYYY-MM-DD')) -- prof_oak
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (32, 33, TO_DATE('2021-01-03', 'YYYY-MM-DD')) -- mew
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (32, 1, TO_DATE('2022-01-02', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (32, 9, TO_DATE('2022-01-02', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (32, 21, TO_DATE('2023-01-02', 'YYYY-MM-DD')) -- pikachu
    
    -- 33. mew (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (33, 32, TO_DATE('2021-01-03', 'YYYY-MM-DD')) -- mewtwo
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (33, 21, TO_DATE('2021-01-04', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (33, 27, TO_DATE('2021-01-05', 'YYYY-MM-DD')) -- eevee
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (33, 1, TO_DATE('2022-01-03', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (33, 9, TO_DATE('2022-01-03', 'YYYY-MM-DD')) -- hello_kitty
    
    -- 34. ditto (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (34, 33, TO_DATE('2022-02-03', 'YYYY-MM-DD')) -- mew
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (34, 21, TO_DATE('2023-02-03', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (34, 1, TO_DATE('2023-02-03', 'YYYY-MM-DD')) -- ryan
    
    -- 35. magikarp (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (35, 36, TO_DATE('2023-04-03', 'YYYY-MM-DD')) -- gyarados (진화형)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (35, 21, TO_DATE('2023-03-04', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (35, 1, TO_DATE('2023-03-04', 'YYYY-MM-DD')) -- ryan
    
    -- 36. gyarados (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (36, 35, TO_DATE('2023-04-05', 'YYYY-MM-DD')) -- magikarp (과거의 나)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (36, 31, TO_DATE('2023-04-06', 'YYYY-MM-DD')) -- dragonite
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (36, 21, TO_DATE('2023-04-07', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (36, 1, TO_DATE('2023-04-08', 'YYYY-MM-DD')) -- ryan
    
    -- 37. togepi (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (37, 25, TO_DATE('2023-05-06', 'YYYY-MM-DD')) -- jigglypuff
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (37, 21, TO_DATE('2023-05-07', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (37, 4, TO_DATE('2023-05-08', 'YYYY-MM-DD')) -- little_apeach
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (37, 1, TO_DATE('2023-05-09', 'YYYY-MM-DD')) -- ryan

    -- 38. piplup (팔로잉: 4명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (38, 23, TO_DATE('2023-06-07', 'YYYY-MM-DD')) -- squirtle
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (38, 21, TO_DATE('2023-06-08', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (38, 1, TO_DATE('2023-06-09', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (38, 9, TO_DATE('2023-06-10', 'YYYY-MM-DD')) -- hello_kitty

    -- 39. lucario (팔로잉: 5명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (39, 32, TO_DATE('2022-02-26', 'YYYY-MM-DD')) -- mewtwo
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (39, 21, TO_DATE('2022-02-27', 'YYYY-MM-DD')) -- pikachu
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (39, 28, TO_DATE('2022-02-28', 'YYYY-MM-DD')) -- meowth
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (39, 1, TO_DATE('2023-02-26', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (39, 9, TO_DATE('2023-02-26', 'YYYY-MM-DD')) -- hello_kitty
    
    -- 40. prof_oak (팔로잉: 3명)
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (40, 1, TO_DATE('2020-01-10', 'YYYY-MM-DD')) -- ryan
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (40, 9, TO_DATE('2020-01-10', 'YYYY-MM-DD')) -- hello_kitty
    INTO FOLLOWS (follower_id, following_id, creation_date) VALUES (40, 32, TO_DATE('2020-01-10', 'YYYY-MM-DD')) -- mewtwo
SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-3: 게시물 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: 사용자가 작성한 게시물. 사진 또는 비디오.
-- 특징:
-- 1. 라이언(1), 피카츄(21), 헬로키티(9)는 게시물을 많이 작성한 인플루언서
-- 2. 구데타마(16), 뮤츠(32) 등 일부 캐릭터는 게시물이 없는 유령 회원
-- 3. GROUP BY 실습을 위해 날짜를 2022년~2024년에 걸쳐 의도적으로 분포시킴
-- 4. 해시태그 관련 쿼리 실습을 위해 공통 해시태그를 다수 포함하도록 수정
-- =====================================================================
INSERT ALL
    -- 1. ryan (인플루언서, 15개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (1, 1, '오늘의 책 한 구절. 마음의 양식을 쌓는 시간. #북스타그램 #독서 #일상', 'photo', TO_TIMESTAMP('2022-05-10 14:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (2, 1, '춘식이와 함께하는 평화로운 오후. #냥스타그램 #집사그램 #일상', 'photo', TO_TIMESTAMP('2022-08-20 18:00:15', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (3, 1, '리더의 조건에 대한 짧은 생각. #리더십 #생각', 'photo', TO_TIMESTAMP('2022-11-05 21:15:45', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (4, 1, '새해 첫 일출. 모두 소망 이루시길. #새해 #일출 #소원', 'photo', TO_TIMESTAMP('2023-01-01 07:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (5, 1, '카카오프렌즈 단체 회식! 즐거운 시간이었다. #카카오프렌즈 #회식 #일상', 'video', TO_TIMESTAMP('2023-04-12 20:05:10', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (6, 1, '빗소리를 들으며 즐기는 커피 한 잔의 여유. #커피 #힐링 #주말', 'photo', TO_TIMESTAMP('2023-07-18 15:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (7, 1, '가을은 독서의 계절이죠. #북스타그램 #가을', 'photo', TO_TIMESTAMP('2023-09-25 11:45:30', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (8, 1, '다들 메리 크리스마스! #크리스마스 #연말파티', 'photo', TO_TIMESTAMP('2023-12-25 00:01:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (9, 1, '새로운 다이어리를 개시. 올 한 해도 화이팅! #새해다짐 #플래너', 'photo', TO_TIMESTAMP('2024-01-02 09:10:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (10, 1, '춘식이가 또 고구마를 훔쳐먹었다... #냥스타그램 #사고뭉치', 'video', TO_TIMESTAMP('2024-03-15 19:50:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (11, 1, '따스한 봄볕 아래에서. #봄나들이 #데일리 #힐링', 'photo', TO_TIMESTAMP('2024-04-05 13:25:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (12, 1, '제주도 출장. 맑은 공기 마시니 좋구나. #여행스타그램 #제주도 #출장', 'photo', TO_TIMESTAMP('2024-05-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (13, 1, '새로운 프로젝트 구상 중. #열일 #직장인스타그램', 'photo', TO_TIMESTAMP('2024-05-15 23:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (14, 1, '어피치와 리틀어피치, 사고뭉치 듀오. #카카오프렌즈 #귀요미', 'photo', TO_TIMESTAMP('2024-05-18 17:10:45', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (15, 1, '오늘의 명언: 가장 큰 위험은 위험 없는 삶이다. #명언 #생각 #일상', 'photo', TO_TIMESTAMP('2024-05-20 08:30:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 2. choonsik (5개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (16, 2, '고구마... 맛있다... #고구마 #먹스타그램 #JMT', 'photo', TO_TIMESTAMP('2023-10-10 12:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (17, 2, '라이언님이 사주신 고구마 라떼. 냐냐. #고구마라떼 #먹스타그램', 'photo', TO_TIMESTAMP('2023-12-01 16:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (18, 2, '캣타워 꼭대기에서 낮잠 자기. #냥스타그램 #고양이일상 #힐링', 'video', TO_TIMESTAMP('2024-02-20 14:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (19, 2, '오늘 간식은 군고구마! #고구마 #먹스타그램', 'photo', TO_TIMESTAMP('2024-05-11 18:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (20, 2, '상자 안에 들어가기 성공! #냥스타그램 #고양이', 'photo', TO_TIMESTAMP('2024-05-18 11:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 3. apeach (4개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (21, 3, '내 뒤태 어때? #셀카 #데일리룩 #오오티디', 'photo', TO_TIMESTAMP('2023-08-15 13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (22, 3, '복숭아 농장에서! #과즙미뿜뿜 #여행스타그램 #주말', 'video', TO_TIMESTAMP('2024-05-02 15:20:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (23, 3, '리틀어피치랑 장난치기! 꺄르르~ #카카오프렌즈 #귀요미', 'video', TO_TIMESTAMP('2024-05-10 17:45:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (24, 3, '새로 산 리본 자랑. #오오티디 #데일리룩 #패션', 'photo', TO_TIMESTAMP('2024-05-19 12:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 5. muzi & con (3개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (25, 5, '콘이랑 같이 토끼 옷 입고 찰칵! #카카오프렌즈 #우정스타그램', 'photo', TO_TIMESTAMP('2023-11-11 11:11:11', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (26, 6, '무지를 키우는 건 정말 힘들어... #육아일기 #일상', 'photo', TO_TIMESTAMP('2024-03-20 22:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (27, 5, '단무지 파티! #노랑 #단무지 #먹스타그램', 'photo', TO_TIMESTAMP('2024-04-30 18:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 7. frodo & 8. neo (4개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (28, 7, '네오와 함께하는 낭만적인 저녁. #럽스타그램 #데이트 #데일리', 'photo', TO_TIMESTAMP('2024-02-14 20:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (29, 8, '오늘의 패션. #단발머리 #패셔니스타 #오오티디 #데일리룩', 'photo', TO_TIMESTAMP('2024-05-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (30, 8, '프로도가 사준 목걸이 자랑. #선물 #럽스타그램 #고마워', 'photo', TO_TIMESTAMP('2024-05-17 19:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (31, 7, '네오... 내 카드 그만 써... #럽스타그램맞나 #일상', 'photo', TO_TIMESTAMP('2024-05-18 21:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 9. hello_kitty (인플루언서, 13개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (32, 9, '사과 5개 무게의 헬로키티입니다! #프로필 #산리오', 'photo', TO_TIMESTAMP('2022-03-01 09:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (33, 9, '친구들과 함께하는 티타임. #산리오 #친구 #우정스타그램 #데일리', 'photo', TO_TIMESTAMP('2022-06-15 15:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (34, 9, '오늘 구운 애플파이! 정말 맛있어요. #베이킹 #디저트 #먹스타그램', 'photo', TO_TIMESTAMP('2022-10-31 16:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (35, 9, '모두 행복한 새해 보내세요! #새해인사 #산리오', 'video', TO_TIMESTAMP('2023-01-01 00:00:01', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (36, 9, '마이멜로디와 쿠로미, 사이좋게 지내렴~ #산리오 #친구 #우정스타그램', 'photo', TO_TIMESTAMP('2023-05-20 14:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (37, 9, '여름 휴가는 바다에서! #여름 #바캉스 #여행스타그램 #힐링', 'photo', TO_TIMESTAMP('2023-08-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (38, 9, '리본 컬렉션 대공개! #리본 #패션 #오오티디', 'video', TO_TIMESTAMP('2023-11-20 18:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (39, 9, '메리 크리스마스! 산타 할아버지가 선물을 주셨어요. #크리스마스 #선물', 'photo', TO_TIMESTAMP('2023-12-25 08:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (40, 9, '새해에도 모두에게 사랑과 행복이 가득하길. #새해 #소원', 'photo', TO_TIMESTAMP('2024-01-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (41, 9, '피아노 연주 영상. #취미 #피아노 #일상', 'video', TO_TIMESTAMP('2024-03-10 20:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (42, 9, '런던 여행 중! #여행스타그램 #런던 #힐링', 'photo', TO_TIMESTAMP('2024-05-05 11:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (43, 9, '오늘의 명언: 친절은 세상을 바꾸는 가장 강력한 힘이다. #명언 #좋은글', 'photo', TO_TIMESTAMP('2024-05-15 09:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (44, 9, '모두 좋은 하루 보내세요! #일상 #데일리 #소통', 'photo', TO_TIMESTAMP('2024-05-21 08:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 10. my_melody & 11. kuromi (6개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (45, 10, '오늘도 쿠로미랑 티격태격! 그래도 미워할 수 없어. #산리오 #친구 #우정스타그램', 'photo', TO_TIMESTAMP('2023-10-01 12:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (46, 11, '내가 최고라고! 마이멜로디는 내 라이벌일 뿐이야! #쿠로미 #산리오', 'photo', TO_TIMESTAMP('2023-10-01 12:05:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (47, 10, '아몬드 파운드 케이크 만들기 성공! #베이킹 #홈카페 #디저트 #먹스타그램', 'photo', TO_TIMESTAMP('2024-04-20 15:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (48, 11, '바쿠랑 함께 락 페스티벌! #락앤롤 #페스티벌 #주말', 'video', TO_TIMESTAMP('2024-05-12 21:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (49, 10, '모두 사이좋게 지내요~ #사랑 #평화 #일상', 'photo', TO_TIMESTAMP('2024-05-20 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (50, 11, '오늘의 일기: 또 마이멜로디에게 졌다... 분하다! #일기 #일상', 'photo', TO_TIMESTAMP('2024-05-19 23:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 12. cinnamoroll (3개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (51, 12, '카페 시나몬으로 놀러오세요~ #카페 #시나모롤 #산리오 #일상', 'photo', TO_TIMESTAMP('2024-01-20 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (52, 12, '하늘을 나는 연습 중! #시나모롤 #귀요미', 'video', TO_TIMESTAMP('2024-05-08 14:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (53, 12, '시나몬롤 냠냠. #디저트 #먹스타그램 #홈카페', 'photo', TO_TIMESTAMP('2024-05-18 16:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 21. pikachu (인플루언서, 18개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (54, 21, '피카피카! #첫게시물 #포켓몬', 'photo', TO_TIMESTAMP('2022-01-15 12:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (55, 21, '지우와 함께하는 모험! 오늘은 체육관 시합! #포켓몬 #모험', 'video', TO_TIMESTAMP('2022-04-01 18:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (56, 21, '꼬부기, 파이리, 이상해씨랑 같이. #친구 #우정스타그램 #포켓몬', 'photo', TO_TIMESTAMP('2022-07-22 13:10:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (57, 21, '백만볼트 훈련 중! 찌릿찌릿! #포켓몬 #훈련', 'video', TO_TIMESTAMP('2022-10-05 11:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (58, 21, '케첩은 세상에서 제일 맛있어. 피카... #먹스타그램 #JMT', 'photo', TO_TIMESTAMP('2023-02-10 19:45:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (59, 21, '로켓단은 정말 귀찮아! 피카츄! #포켓몬 #일상', 'photo', TO_TIMESTAMP('2023-05-05 17:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (60, 21, '이브이랑 같이 꽃밭에서. #귀요미 #포켓몬 #친구', 'photo', TO_TIMESTAMP('2023-06-20 15:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (61, 21, '잠만보 위에서 낮잠. 폭신폭신해. #포켓몬 #힐링 #일상', 'photo', TO_TIMESTAMP('2023-08-30 14:20:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (62, 21, '뮤츠와의 만남... 강하다...! #포켓몬 #전설', 'photo', TO_TIMESTAMP('2023-12-10 20:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (63, 21, '새해 복 많이 받아! 피카피카! #새해인사 #포켓몬', 'video', TO_TIMESTAMP('2024-01-01 00:05:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (64, 21, '오박사님 연구소에서. #포켓몬 #연구', 'photo', TO_TIMESTAMP('2024-02-28 16:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (65, 21, '전광석화! 달려라 피카츄! #포켓몬 #일상', 'video', TO_TIMESTAMP('2024-04-10 10:50:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (66, 21, '오늘의 간식은 나무열매! #먹스타그램 #포켓몬', 'photo', TO_TIMESTAMP('2024-05-01 13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (67, 21, '라이언과 함께! 노란색 친구들! #친구 #우정스타그램 #콜라보', 'photo', TO_TIMESTAMP('2024-05-10 12:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (68, 21, '푸린의 자장가를 듣다가 잠들 뻔... #푸린 #포켓몬 #일상', 'video', TO_TIMESTAMP('2024-05-17 22:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (69, 21, '포켓몬 콘테스트 준비중! #포켓몬 #대회', 'photo', TO_TIMESTAMP('2024-05-19 18:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (70, 21, '모두 내일도 힘내! 피카츄! #응원 #포켓몬', 'photo', TO_TIMESTAMP('2024-05-20 21:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (71, 21, '피카~츄! #셀카 #포켓몬', 'photo', TO_TIMESTAMP('2024-05-21 11:11:11', 'YYYY-MM-DD HH24:MI:SS'))

    -- 22. charmander (3개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (72, 22, '내 꼬리 불꽃, 멋지지 않아? #파이리 #포켓몬 #일상', 'photo', TO_TIMESTAMP('2023-09-01 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (73, 22, '언젠가 리자몽이 될 거야! #포켓몬 #다짐', 'photo', TO_TIMESTAMP('2024-05-15 14:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (74, 22, '매운 음식 도전! #불꽃타입 #먹스타그램', 'video', TO_TIMESTAMP('2024-05-20 19:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 23. squirtle (3개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (75, 23, '선글라스 장착! #꼬부기단 #포켓몬 #오오티디', 'photo', TO_TIMESTAMP('2023-07-07 13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (76, 23, '물대포 발사! #물장난 #포켓몬', 'video', TO_TIMESTAMP('2024-05-11 15:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (77, 23, '바다 수영은 즐거워! #여행스타그램 #여름 #포켓몬', 'photo', TO_TIMESTAMP('2024-05-19 14:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 24. bulbasaur (2개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (78, 24, '등에서 씨앗이 자라고 있어. #광합성 #포켓몬 #일상', 'photo', TO_TIMESTAMP('2024-04-22 09:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (79, 24, '덩쿨채찍 연습! #포켓몬 #훈련', 'video', TO_TIMESTAMP('2024-05-18 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 25. jigglypuff (2개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (80, 25, '내 노래를 들어줘! #자장가 #노래 #포켓몬', 'video', TO_TIMESTAMP('2023-12-24 22:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (81, 25, '또 다들 내 노래 듣다가 잠들었어... #낙서해야지 #푸린 #포켓몬 #일상', 'photo', TO_TIMESTAMP('2024-05-17 23:00:00', 'YYYY-MM-DD HH24:MI:SS'))

    -- 26. snorlax (2개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (82, 26, 'Zzzzz.... #잠만보 #일상 #힐링', 'photo', TO_TIMESTAMP('2023-03-10 14:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (83, 26, '밥... 어디 없나... #먹스타그램 #잠만보', 'photo', TO_TIMESTAMP('2024-03-20 13:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 27. eevee (3개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (84, 27, '어떤 모습으로 진화할까? #고민중 #포켓몬', 'photo', TO_TIMESTAMP('2023-11-15 18:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (85, 27, '피카츄랑 같이 놀기! #친구 #우정스타그램 #포켓몬 #귀요미', 'photo', TO_TIMESTAMP('2024-05-12 16:30:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (86, 27, '꼬리 살랑살랑~ #애교 #귀요미 #포켓몬', 'video', TO_TIMESTAMP('2024-05-16 11:45:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 34. ditto (1개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (87, 34, '메타몽! (피카츄로 변신했다) #변신 #포켓몬 #귀요미', 'photo', TO_TIMESTAMP('2024-05-10 10:10:10', 'YYYY-MM-DD HH24:MI:SS'))

    -- 36. gyarados (1개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (88, 36, '잉어킹 시절을 잊지 말자. 파괴광선! #포켓몬 #진화', 'photo', TO_TIMESTAMP('2024-05-08 20:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    
    -- 40. prof_oak (2개)
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (89, 40, '새로운 포켓몬 연구 결과를 발표하네. #포켓몬 #연구 #일상', 'photo', TO_TIMESTAMP('2023-09-15 09:00:00', 'YYYY-MM-DD HH24:MI:SS'))
    INTO POSTS (post_id, user_id, content, post_type, creation_date) VALUES (90, 40, '모두 포켓몬 도감을 채우는 것을 잊지 말게나! #포켓몬 #모험', 'photo', TO_TIMESTAMP('2024-05-21 10:00:00', 'YYYY-MM-DD HH24:MI:SS'))
SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-4: 해시태그 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: POSTS 테이블의 content에서 추출한 고유 해시태그 목록
-- 특징: 데이터 정규화의 예시로, 중복을 제거한 고유한 태그 이름만 관리
-- =====================================================================

INSERT ALL
    INTO HASHTAGS (tag_id, tag_name) VALUES (1001, '#일상')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1002, '#먹스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1003, '#포켓몬')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1004, '#산리오')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1005, '#귀요미')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1006, '#힐링')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1007, '#여행스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1008, '#우정스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1009, '#오오티디')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1010, '#냥스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1011, '#데일리')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1012, '#주말')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1013, '#데일리룩')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1014, '#친구')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1015, '#디저트')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1016, '#카카오프렌즈')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1017, '#북스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1018, '#생각')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1019, '#새해')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1020, '#크리스마스')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1021, '#명언')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1022, '#JMT')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1023, '#셀카')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1024, '#패션')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1025, '#럽스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1026, '#선물')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1027, '#베이킹')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1028, '#새해인사')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1029, '#여름')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1030, '#홈카페')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1031, '#시나모롤')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1032, '#모험')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1033, '#훈련')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1034, '#잠만보')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1035, '#독서')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1036, '#집사그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1037, '#리더십')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1038, '#일출')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1039, '#소원')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1040, '#회식')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1041, '#커피')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1042, '#가을')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1043, '#연말파티')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1044, '#새해다짐')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1045, '#플래너')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1046, '#사고뭉치')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1047, '#봄나들이')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1048, '#제주도')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1049, '#출장')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1050, '#열일')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1051, '#직장인스타그램')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1052, '#고구마')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1053, '#고구마라떼')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1054, '#고양이일상')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1055, '#고양이')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1056, '#과즙미뿜뿜')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1057, '#육아일기')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1058, '#노랑')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1059, '#단무지')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1060, '#데이트')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1061, '#단발머리')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1062, '#패셔니스타')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1063, '#고마워')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1064, '#럽스타그램맞나')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1065, '#프로필')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1066, '#바캉스')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1067, '#리본')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1068, '#취미')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1069, '#피아노')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1070, '#런던')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1071, '#좋은글')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1072, '#소통')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1073, '#쿠로미')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1074, '#락앤롤')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1075, '#페스티벌')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1076, '#사랑')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1077, '#평화')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1078, '#일기')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1079, '#카페')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1080, '#첫게시물')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1081, '#전설')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1082, '#연구')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1083, '#콜라보')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1084, '#푸린')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1085, '#대회')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1086, '#응원')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1087, '#파이리')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1088, '#다짐')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1089, '#불꽃타입')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1090, '#꼬부기단')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1091, '#물장난')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1092, '#광합성')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1093, '#자장가')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1094, '#노래')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1095, '#낙서해야지')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1096, '#고민중')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1097, '#애교')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1098, '#변신')
    INTO HASHTAGS (tag_id, tag_name) VALUES (1099, '#진화')
SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-5: 게시물-해시태그 연결 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: POSTS와 HASHTAGS의 N:M 관계를 해소하는 교차 테이블 데이터
-- 특징: 각 게시물(post_id)과 해당 게시물에 포함된 해시태그(tag_id)를 연결
-- =====================================================================
INSERT ALL
    -- Post 1
    INTO POST_TAGS (post_id, tag_id) VALUES (1, 1017) -- #북스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (1, 1035) -- #독서
    INTO POST_TAGS (post_id, tag_id) VALUES (1, 1001) -- #일상
    -- Post 2
    INTO POST_TAGS (post_id, tag_id) VALUES (2, 1010) -- #냥스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (2, 1036) -- #집사그램
    INTO POST_TAGS (post_id, tag_id) VALUES (2, 1001) -- #일상
    -- Post 3
    INTO POST_TAGS (post_id, tag_id) VALUES (3, 1037) -- #리더십
    INTO POST_TAGS (post_id, tag_id) VALUES (3, 1018) -- #생각
    -- Post 4
    INTO POST_TAGS (post_id, tag_id) VALUES (4, 1019) -- #새해
    INTO POST_TAGS (post_id, tag_id) VALUES (4, 1038) -- #일출
    INTO POST_TAGS (post_id, tag_id) VALUES (4, 1039) -- #소원
    -- Post 5
    INTO POST_TAGS (post_id, tag_id) VALUES (5, 1016) -- #카카오프렌즈
    INTO POST_TAGS (post_id, tag_id) VALUES (5, 1040) -- #회식
    INTO POST_TAGS (post_id, tag_id) VALUES (5, 1001) -- #일상
    -- Post 6
    INTO POST_TAGS (post_id, tag_id) VALUES (6, 1041) -- #커피
    INTO POST_TAGS (post_id, tag_id) VALUES (6, 1006) -- #힐링
    INTO POST_TAGS (post_id, tag_id) VALUES (6, 1012) -- #주말
    -- Post 7
    INTO POST_TAGS (post_id, tag_id) VALUES (7, 1017) -- #북스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (7, 1042) -- #가을
    -- Post 8
    INTO POST_TAGS (post_id, tag_id) VALUES (8, 1020) -- #크리스마스
    INTO POST_TAGS (post_id, tag_id) VALUES (8, 1043) -- #연말파티
    -- Post 9
    INTO POST_TAGS (post_id, tag_id) VALUES (9, 1044) -- #새해다짐
    INTO POST_TAGS (post_id, tag_id) VALUES (9, 1045) -- #플래너
    -- Post 10
    INTO POST_TAGS (post_id, tag_id) VALUES (10, 1010) -- #냥스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (10, 1046) -- #사고뭉치
    -- Post 11
    INTO POST_TAGS (post_id, tag_id) VALUES (11, 1047) -- #봄나들이
    INTO POST_TAGS (post_id, tag_id) VALUES (11, 1011) -- #데일리
    INTO POST_TAGS (post_id, tag_id) VALUES (11, 1006) -- #힐링
    -- Post 12
    INTO POST_TAGS (post_id, tag_id) VALUES (12, 1007) -- #여행스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (12, 1048) -- #제주도
    INTO POST_TAGS (post_id, tag_id) VALUES (12, 1049) -- #출장
    -- Post 13
    INTO POST_TAGS (post_id, tag_id) VALUES (13, 1050) -- #열일
    INTO POST_TAGS (post_id, tag_id) VALUES (13, 1051) -- #직장인스타그램
    -- Post 14
    INTO POST_TAGS (post_id, tag_id) VALUES (14, 1016) -- #카카오프렌즈
    INTO POST_TAGS (post_id, tag_id) VALUES (14, 1005) -- #귀요미
    -- Post 15
    INTO POST_TAGS (post_id, tag_id) VALUES (15, 1021) -- #명언
    INTO POST_TAGS (post_id, tag_id) VALUES (15, 1018) -- #생각
    INTO POST_TAGS (post_id, tag_id) VALUES (15, 1001) -- #일상
    -- Post 16
    INTO POST_TAGS (post_id, tag_id) VALUES (16, 1052) -- #고구마
    INTO POST_TAGS (post_id, tag_id) VALUES (16, 1002) -- #먹스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (16, 1022) -- #JMT
    -- Post 17
    INTO POST_TAGS (post_id, tag_id) VALUES (17, 1053) -- #고구마라떼
    INTO POST_TAGS (post_id, tag_id) VALUES (17, 1002) -- #먹스타그램
    -- Post 18
    INTO POST_TAGS (post_id, tag_id) VALUES (18, 1010) -- #냥스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (18, 1054) -- #고양이일상
    INTO POST_TAGS (post_id, tag_id) VALUES (18, 1006) -- #힐링
    -- Post 19
    INTO POST_TAGS (post_id, tag_id) VALUES (19, 1052) -- #고구마 (중복 태그, 데이터 확인)
    INTO POST_TAGS (post_id, tag_id) VALUES (19, 1002) -- #먹스타그램
    -- Post 20
    INTO POST_TAGS (post_id, tag_id) VALUES (20, 1010) -- #냥스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (20, 1055) -- #고양이
    -- Post 21
    INTO POST_TAGS (post_id, tag_id) VALUES (21, 1023) -- #셀카
    INTO POST_TAGS (post_id, tag_id) VALUES (21, 1013) -- #데일리룩
    INTO POST_TAGS (post_id, tag_id) VALUES (21, 1009) -- #오오티디
    -- Post 22
    INTO POST_TAGS (post_id, tag_id) VALUES (22, 1056) -- #과즙미뿜뿜
    INTO POST_TAGS (post_id, tag_id) VALUES (22, 1007) -- #여행스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (22, 1012) -- #주말
    -- Post 23
    INTO POST_TAGS (post_id, tag_id) VALUES (23, 1016) -- #카카오프렌즈
    INTO POST_TAGS (post_id, tag_id) VALUES (23, 1005) -- #귀요미
    -- Post 24
    INTO POST_TAGS (post_id, tag_id) VALUES (24, 1009) -- #오오티디
    INTO POST_TAGS (post_id, tag_id) VALUES (24, 1013) -- #데일리룩
    INTO POST_TAGS (post_id, tag_id) VALUES (24, 1024) -- #패션
    -- Post 25
    INTO POST_TAGS (post_id, tag_id) VALUES (25, 1016) -- #카카오프렌즈
    INTO POST_TAGS (post_id, tag_id) VALUES (25, 1008) -- #우정스타그램
    -- Post 26
    INTO POST_TAGS (post_id, tag_id) VALUES (26, 1057) -- #육아일기
    INTO POST_TAGS (post_id, tag_id) VALUES (26, 1001) -- #일상
    -- Post 27
    INTO POST_TAGS (post_id, tag_id) VALUES (27, 1058) -- #노랑
    INTO POST_TAGS (post_id, tag_id) VALUES (27, 1059) -- #단무지
    INTO POST_TAGS (post_id, tag_id) VALUES (27, 1002) -- #먹스타그램
    -- Post 28
    INTO POST_TAGS (post_id, tag_id) VALUES (28, 1025) -- #럽스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (28, 1060) -- #데이트
    INTO POST_TAGS (post_id, tag_id) VALUES (28, 1011) -- #데일리
    -- Post 29
    INTO POST_TAGS (post_id, tag_id) VALUES (29, 1061) -- #단발머리
    INTO POST_TAGS (post_id, tag_id) VALUES (29, 1062) -- #패셔니스타
    INTO POST_TAGS (post_id, tag_id) VALUES (29, 1009) -- #오오티디
    INTO POST_TAGS (post_id, tag_id) VALUES (29, 1013) -- #데일리룩
    -- Post 30
    INTO POST_TAGS (post_id, tag_id) VALUES (30, 1026) -- #선물
    INTO POST_TAGS (post_id, tag_id) VALUES (30, 1025) -- #럽스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (30, 1063) -- #고마워
    -- Post 31
    INTO POST_TAGS (post_id, tag_id) VALUES (31, 1064) -- #럽스타그램맞나
    INTO POST_TAGS (post_id, tag_id) VALUES (31, 1001) -- #일상
    -- Post 32
    INTO POST_TAGS (post_id, tag_id) VALUES (32, 1065) -- #프로필
    INTO POST_TAGS (post_id, tag_id) VALUES (32, 1004) -- #산리오
    -- Post 33
    INTO POST_TAGS (post_id, tag_id) VALUES (33, 1004) -- #산리오
    INTO POST_TAGS (post_id, tag_id) VALUES (33, 1014) -- #친구
    INTO POST_TAGS (post_id, tag_id) VALUES (33, 1008) -- #우정스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (33, 1011) -- #데일리
    -- Post 34
    INTO POST_TAGS (post_id, tag_id) VALUES (34, 1027) -- #베이킹
    INTO POST_TAGS (post_id, tag_id) VALUES (34, 1015) -- #디저트
    INTO POST_TAGS (post_id, tag_id) VALUES (34, 1002) -- #먹스타그램
    -- Post 35
    INTO POST_TAGS (post_id, tag_id) VALUES (35, 1028) -- #새해인사
    INTO POST_TAGS (post_id, tag_id) VALUES (35, 1004) -- #산리오
    -- Post 36
    INTO POST_TAGS (post_id, tag_id) VALUES (36, 1004) -- #산리오
    INTO POST_TAGS (post_id, tag_id) VALUES (36, 1014) -- #친구
    INTO POST_TAGS (post_id, tag_id) VALUES (36, 1008) -- #우정스타그램
    -- Post 37
    INTO POST_TAGS (post_id, tag_id) VALUES (37, 1029) -- #여름
    INTO POST_TAGS (post_id, tag_id) VALUES (37, 1066) -- #바캉스
    INTO POST_TAGS (post_id, tag_id) VALUES (37, 1007) -- #여행스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (37, 1006) -- #힐링
    -- Post 38
    INTO POST_TAGS (post_id, tag_id) VALUES (38, 1067) -- #리본
    INTO POST_TAGS (post_id, tag_id) VALUES (38, 1024) -- #패션
    INTO POST_TAGS (post_id, tag_id) VALUES (38, 1009) -- #오오티디
    -- Post 39
    INTO POST_TAGS (post_id, tag_id) VALUES (39, 1020) -- #크리스마스
    INTO POST_TAGS (post_id, tag_id) VALUES (39, 1026) -- #선물
    -- Post 40
    INTO POST_TAGS (post_id, tag_id) VALUES (40, 1019) -- #새해
    INTO POST_TAGS (post_id, tag_id) VALUES (40, 1039) -- #소원
    -- Post 41
    INTO POST_TAGS (post_id, tag_id) VALUES (41, 1068) -- #취미
    INTO POST_TAGS (post_id, tag_id) VALUES (41, 1069) -- #피아노
    INTO POST_TAGS (post_id, tag_id) VALUES (41, 1001) -- #일상
    -- Post 42
    INTO POST_TAGS (post_id, tag_id) VALUES (42, 1007) -- #여행스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (42, 1070) -- #런던
    INTO POST_TAGS (post_id, tag_id) VALUES (42, 1006) -- #힐링
    -- Post 43
    INTO POST_TAGS (post_id, tag_id) VALUES (43, 1021) -- #명언
    INTO POST_TAGS (post_id, tag_id) VALUES (43, 1071) -- #좋은글
    -- Post 44
    INTO POST_TAGS (post_id, tag_id) VALUES (44, 1001) -- #일상
    INTO POST_TAGS (post_id, tag_id) VALUES (44, 1011) -- #데일리
    INTO POST_TAGS (post_id, tag_id) VALUES (44, 1072) -- #소통
    -- Post 45
    INTO POST_TAGS (post_id, tag_id) VALUES (45, 1004) -- #산리오
    INTO POST_TAGS (post_id, tag_id) VALUES (45, 1014) -- #친구
    INTO POST_TAGS (post_id, tag_id) VALUES (45, 1008) -- #우정스타그램
    -- Post 46
    INTO POST_TAGS (post_id, tag_id) VALUES (46, 1073) -- #쿠로미
    INTO POST_TAGS (post_id, tag_id) VALUES (46, 1004) -- #산리오
    -- Post 47
    INTO POST_TAGS (post_id, tag_id) VALUES (47, 1027) -- #베이킹
    INTO POST_TAGS (post_id, tag_id) VALUES (47, 1030) -- #홈카페
    INTO POST_TAGS (post_id, tag_id) VALUES (47, 1015) -- #디저트
    INTO POST_TAGS (post_id, tag_id) VALUES (47, 1002) -- #먹스타그램
    -- Post 48
    INTO POST_TAGS (post_id, tag_id) VALUES (48, 1074) -- #락앤롤
    INTO POST_TAGS (post_id, tag_id) VALUES (48, 1075) -- #페스티벌
    INTO POST_TAGS (post_id, tag_id) VALUES (48, 1012) -- #주말
    -- Post 49
    INTO POST_TAGS (post_id, tag_id) VALUES (49, 1076) -- #사랑
    INTO POST_TAGS (post_id, tag_id) VALUES (49, 1077) -- #평화
    INTO POST_TAGS (post_id, tag_id) VALUES (49, 1001) -- #일상
    -- Post 50
    INTO POST_TAGS (post_id, tag_id) VALUES (50, 1078) -- #일기
    INTO POST_TAGS (post_id, tag_id) VALUES (50, 1001) -- #일상
    -- Post 51
    INTO POST_TAGS (post_id, tag_id) VALUES (51, 1079) -- #카페
    INTO POST_TAGS (post_id, tag_id) VALUES (51, 1031) -- #시나모롤
    INTO POST_TAGS (post_id, tag_id) VALUES (51, 1004) -- #산리오
    INTO POST_TAGS (post_id, tag_id) VALUES (51, 1001) -- #일상
    -- Post 52
    INTO POST_TAGS (post_id, tag_id) VALUES (52, 1031) -- #시나모롤
    INTO POST_TAGS (post_id, tag_id) VALUES (52, 1005) -- #귀요미
    -- Post 53
    INTO POST_TAGS (post_id, tag_id) VALUES (53, 1015) -- #디저트
    INTO POST_TAGS (post_id, tag_id) VALUES (53, 1002) -- #먹스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (53, 1030) -- #홈카페
    -- Post 54
    INTO POST_TAGS (post_id, tag_id) VALUES (54, 1080) -- #첫게시물
    INTO POST_TAGS (post_id, tag_id) VALUES (54, 1003) -- #포켓몬
    -- Post 55
    INTO POST_TAGS (post_id, tag_id) VALUES (55, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (55, 1032) -- #모험
    -- Post 56
    INTO POST_TAGS (post_id, tag_id) VALUES (56, 1014) -- #친구
    INTO POST_TAGS (post_id, tag_id) VALUES (56, 1008) -- #우정스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (56, 1003) -- #포켓몬
    -- Post 57
    INTO POST_TAGS (post_id, tag_id) VALUES (57, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (57, 1033) -- #훈련
    -- Post 58
    INTO POST_TAGS (post_id, tag_id) VALUES (58, 1002) -- #먹스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (58, 1022) -- #JMT
    -- Post 59
    INTO POST_TAGS (post_id, tag_id) VALUES (59, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (59, 1001) -- #일상
    -- Post 60
    INTO POST_TAGS (post_id, tag_id) VALUES (60, 1005) -- #귀요미
    INTO POST_TAGS (post_id, tag_id) VALUES (60, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (60, 1014) -- #친구
    -- Post 61
    INTO POST_TAGS (post_id, tag_id) VALUES (61, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (61, 1006) -- #힐링
    INTO POST_TAGS (post_id, tag_id) VALUES (61, 1001) -- #일상
    -- Post 62
    INTO POST_TAGS (post_id, tag_id) VALUES (62, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (62, 1081) -- #전설
    -- Post 63
    INTO POST_TAGS (post_id, tag_id) VALUES (63, 1028) -- #새해인사
    INTO POST_TAGS (post_id, tag_id) VALUES (63, 1003) -- #포켓몬
    -- Post 64
    INTO POST_TAGS (post_id, tag_id) VALUES (64, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (64, 1082) -- #연구
    -- Post 65
    INTO POST_TAGS (post_id, tag_id) VALUES (65, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (65, 1001) -- #일상
    -- Post 66
    INTO POST_TAGS (post_id, tag_id) VALUES (66, 1002) -- #먹스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (66, 1003) -- #포켓몬
    -- Post 67
    INTO POST_TAGS (post_id, tag_id) VALUES (67, 1014) -- #친구
    INTO POST_TAGS (post_id, tag_id) VALUES (67, 1008) -- #우정스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (67, 1083) -- #콜라보
    -- Post 68
    INTO POST_TAGS (post_id, tag_id) VALUES (68, 1084) -- #푸린
    INTO POST_TAGS (post_id, tag_id) VALUES (68, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (68, 1001) -- #일상
    -- Post 69
    INTO POST_TAGS (post_id, tag_id) VALUES (69, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (69, 1085) -- #대회
    -- Post 70
    INTO POST_TAGS (post_id, tag_id) VALUES (70, 1086) -- #응원
    INTO POST_TAGS (post_id, tag_id) VALUES (70, 1003) -- #포켓몬
    -- Post 71
    INTO POST_TAGS (post_id, tag_id) VALUES (71, 1023) -- #셀카
    INTO POST_TAGS (post_id, tag_id) VALUES (71, 1003) -- #포켓몬
    -- Post 72
    INTO POST_TAGS (post_id, tag_id) VALUES (72, 1087) -- #파이리
    INTO POST_TAGS (post_id, tag_id) VALUES (72, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (72, 1001) -- #일상
    -- Post 73
    INTO POST_TAGS (post_id, tag_id) VALUES (73, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (73, 1088) -- #다짐
    -- Post 74
    INTO POST_TAGS (post_id, tag_id) VALUES (74, 1089) -- #불꽃타입
    INTO POST_TAGS (post_id, tag_id) VALUES (74, 1002) -- #먹스타그램
    -- Post 75
    INTO POST_TAGS (post_id, tag_id) VALUES (75, 1090) -- #꼬부기단
    INTO POST_TAGS (post_id, tag_id) VALUES (75, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (75, 1009) -- #오오티디
    -- Post 76
    INTO POST_TAGS (post_id, tag_id) VALUES (76, 1091) -- #물장난
    INTO POST_TAGS (post_id, tag_id) VALUES (76, 1003) -- #포켓몬
    -- Post 77
    INTO POST_TAGS (post_id, tag_id) VALUES (77, 1007) -- #여행스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (77, 1029) -- #여름
    INTO POST_TAGS (post_id, tag_id) VALUES (77, 1003) -- #포켓몬
    -- Post 78
    INTO POST_TAGS (post_id, tag_id) VALUES (78, 1092) -- #광합성
    INTO POST_TAGS (post_id, tag_id) VALUES (78, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (78, 1001) -- #일상
    -- Post 79
    INTO POST_TAGS (post_id, tag_id) VALUES (79, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (79, 1033) -- #훈련
    -- Post 80
    INTO POST_TAGS (post_id, tag_id) VALUES (80, 1093) -- #자장가
    INTO POST_TAGS (post_id, tag_id) VALUES (80, 1094) -- #노래
    INTO POST_TAGS (post_id, tag_id) VALUES (80, 1003) -- #포켓몬
    -- Post 81
    INTO POST_TAGS (post_id, tag_id) VALUES (81, 1095) -- #낙서해야지
    INTO POST_TAGS (post_id, tag_id) VALUES (81, 1084) -- #푸린
    INTO POST_TAGS (post_id, tag_id) VALUES (81, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (81, 1001) -- #일상
    -- Post 82
    INTO POST_TAGS (post_id, tag_id) VALUES (82, 1034) -- #잠만보
    INTO POST_TAGS (post_id, tag_id) VALUES (82, 1001) -- #일상
    INTO POST_TAGS (post_id, tag_id) VALUES (82, 1006) -- #힐링
    -- Post 83
    INTO POST_TAGS (post_id, tag_id) VALUES (83, 1002) -- #먹스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (83, 1034) -- #잠만보
    -- Post 84
    INTO POST_TAGS (post_id, tag_id) VALUES (84, 1096) -- #고민중
    INTO POST_TAGS (post_id, tag_id) VALUES (84, 1003) -- #포켓몬
    -- Post 85
    INTO POST_TAGS (post_id, tag_id) VALUES (85, 1008) -- #우정스타그램
    INTO POST_TAGS (post_id, tag_id) VALUES (85, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (85, 1005) -- #귀요미
    INTO POST_TAGS (post_id, tag_id) VALUES (85, 1014) -- #친구
    -- Post 86
    INTO POST_TAGS (post_id, tag_id) VALUES (86, 1097) -- #애교
    INTO POST_TAGS (post_id, tag_id) VALUES (86, 1005) -- #귀요미
    INTO POST_TAGS (post_id, tag_id) VALUES (86, 1003) -- #포켓몬
    -- Post 87
    INTO POST_TAGS (post_id, tag_id) VALUES (87, 1098) -- #변신
    INTO POST_TAGS (post_id, tag_id) VALUES (87, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (87, 1005) -- #귀요미
    -- Post 88
    INTO POST_TAGS (post_id, tag_id) VALUES (88, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (88, 1099) -- #진화
    -- Post 89
    INTO POST_TAGS (post_id, tag_id) VALUES (89, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (89, 1082) -- #연구
    INTO POST_TAGS (post_id, tag_id) VALUES (89, 1001) -- #일상
    -- Post 90
    INTO POST_TAGS (post_id, tag_id) VALUES (90, 1003) -- #포켓몬
    INTO POST_TAGS (post_id, tag_id) VALUES (90, 1032) -- #모험
SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-6: 좋아요 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: 사용자가 게시물에 '좋아요'를 누른 기록. USERS와 POSTS의 N:M 관계.
-- 특징: 
-- 1. 대부분의 게시물에 1~20개의 좋아요를 골고루 분포
-- 2. 특정 게시물(2, 58, 67번)에 30개 이상의 좋아요를 집중시켜 Top-N, 윈도우 함수 실습 최적화
-- =====================================================================
INSERT ALL
    -- Post 1 (라이언) - Likes: 10
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 1, TO_DATE('2022-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 1, TO_DATE('2022-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 1, TO_DATE('2022-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 1, TO_DATE('2022-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 1, TO_DATE('2022-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 1, TO_DATE('2022-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (22, 1, TO_DATE('2022-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (32, 1, TO_DATE('2022-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 1, TO_DATE('2022-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (40, 1, TO_DATE('2022-05-15', 'YYYY-MM-DD'))

    -- Post 2 (라이언) - 2022년도 인기 게시물! Likes: 32
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 2, TO_DATE('2022-08-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 2, TO_DATE('2022-08-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (4, 2, TO_DATE('2022-08-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 2, TO_DATE('2022-08-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (6, 2, TO_DATE('2022-08-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (7, 2, TO_DATE('2022-08-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 2, TO_DATE('2022-08-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 2, TO_DATE('2022-08-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 2, TO_DATE('2022-08-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (11, 2, TO_DATE('2022-08-23', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 2, TO_DATE('2022-08-23', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 2, TO_DATE('2022-08-23', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (14, 2, TO_DATE('2022-08-24', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (15, 2, TO_DATE('2022-08-24', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (17, 2, TO_DATE('2022-08-25', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (18, 2, TO_DATE('2022-08-25', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (19, 2, TO_DATE('2022-08-26', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (20, 2, TO_DATE('2022-08-26', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 2, TO_DATE('2022-08-27', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (22, 2, TO_DATE('2022-08-27', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (23, 2, TO_DATE('2022-08-28', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (24, 2, TO_DATE('2022-08-28', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (25, 2, TO_DATE('2022-08-29', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (26, 2, TO_DATE('2022-08-29', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 2, TO_DATE('2022-08-30', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (28, 2, TO_DATE('2022-08-30', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (30, 2, TO_DATE('2022-08-31', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (31, 2, TO_DATE('2022-08-31', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (34, 2, TO_DATE('2022-09-01', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (35, 2, TO_DATE('2022-09-01', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (39, 2, TO_DATE('2022-09-02', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (40, 2, TO_DATE('2022-09-02', 'YYYY-MM-DD'))

    -- Post 16 (춘식이) - Likes: 15
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 16, TO_DATE('2023-10-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 16, TO_DATE('2023-10-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 16, TO_DATE('2023-10-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (26, 16, TO_DATE('2023-10-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 16, TO_DATE('2023-10-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 16, TO_DATE('2023-10-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 16, TO_DATE('2023-10-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 16, TO_DATE('2023-10-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 16, TO_DATE('2023-10-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (34, 16, TO_DATE('2023-10-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 16, TO_DATE('2023-10-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 16, TO_DATE('2023-10-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (7, 16, TO_DATE('2023-10-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 16, TO_DATE('2023-10-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (4, 16, TO_DATE('2023-10-16', 'YYYY-MM-DD'))

    -- Post 28 (프로도) - Likes: 12
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 28, TO_DATE('2024-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 28, TO_DATE('2024-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 28, TO_DATE('2024-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 28, TO_DATE('2024-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (4, 28, TO_DATE('2024-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 28, TO_DATE('2024-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 28, TO_DATE('2024-02-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 28, TO_DATE('2024-02-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 28, TO_DATE('2024-02-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 28, TO_DATE('2024-02-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 28, TO_DATE('2024-02-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (40, 28, TO_DATE('2024-02-18', 'YYYY-MM-DD'))

    -- Post 33 (헬로키티) - Likes: 22
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 33, TO_DATE('2022-06-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 33, TO_DATE('2022-06-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (11, 33, TO_DATE('2022-06-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 33, TO_DATE('2022-06-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 33, TO_DATE('2022-06-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (14, 33, TO_DATE('2022-06-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (15, 33, TO_DATE('2022-06-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (17, 33, TO_DATE('2022-06-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (18, 33, TO_DATE('2022-06-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (19, 33, TO_DATE('2022-06-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (20, 33, TO_DATE('2022-06-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 33, TO_DATE('2022-06-19', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (25, 33, TO_DATE('2022-06-19', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 33, TO_DATE('2022-06-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 33, TO_DATE('2022-06-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 33, TO_DATE('2022-06-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (32, 33, TO_DATE('2022-06-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 33, TO_DATE('2022-06-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (37, 33, TO_DATE('2022-06-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (38, 33, TO_DATE('2022-06-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (39, 33, TO_DATE('2022-06-23', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (40, 33, TO_DATE('2022-06-23', 'YYYY-MM-DD'))

    -- Post 58 (피카츄) - 2023년도 인기 게시물! Likes: 35
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 58, TO_DATE('2023-02-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 58, TO_DATE('2023-02-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 58, TO_DATE('2023-02-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (4, 58, TO_DATE('2023-02-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 58, TO_DATE('2023-02-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (6, 58, TO_DATE('2023-02-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (7, 58, TO_DATE('2023-02-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 58, TO_DATE('2023-02-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 58, TO_DATE('2023-02-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 58, TO_DATE('2023-02-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (11, 58, TO_DATE('2023-02-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 58, TO_DATE('2023-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 58, TO_DATE('2023-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (14, 58, TO_DATE('2023-02-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (15, 58, TO_DATE('2023-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (16, 58, TO_DATE('2023-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (17, 58, TO_DATE('2023-02-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (18, 58, TO_DATE('2023-02-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (19, 58, TO_DATE('2023-02-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (20, 58, TO_DATE('2023-02-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (22, 58, TO_DATE('2023-02-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (23, 58, TO_DATE('2023-02-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (24, 58, TO_DATE('2023-02-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (25, 58, TO_DATE('2023-02-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (26, 58, TO_DATE('2023-02-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 58, TO_DATE('2023-02-18', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (28, 58, TO_DATE('2023-02-19', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (29, 58, TO_DATE('2023-02-19', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (30, 58, TO_DATE('2023-02-19', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (31, 58, TO_DATE('2023-02-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (32, 58, TO_DATE('2023-02-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 58, TO_DATE('2023-02-20', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (34, 58, TO_DATE('2023-02-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (39, 58, TO_DATE('2023-02-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (40, 58, TO_DATE('2023-02-21', 'YYYY-MM-DD'))

    -- Post 67 (피카츄) - 2024년도 인기 게시물! Likes: 38
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 67, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 67, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (3, 67, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (4, 67, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (5, 67, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (6, 67, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (7, 67, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (8, 67, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 67, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 67, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (11, 67, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 67, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 67, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (14, 67, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (15, 67, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (16, 67, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (17, 67, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (18, 67, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (19, 67, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (20, 67, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (22, 67, TO_DATE('2024-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (23, 67, TO_DATE('2024-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (24, 67, TO_DATE('2024-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (25, 67, TO_DATE('2024-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (26, 67, TO_DATE('2024-05-14', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (27, 67, TO_DATE('2024-05-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (28, 67, TO_DATE('2024-05-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (29, 67, TO_DATE('2024-05-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (30, 67, TO_DATE('2024-05-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (31, 67, TO_DATE('2024-05-15', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (32, 67, TO_DATE('2024-05-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (33, 67, TO_DATE('2024-05-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (34, 67, TO_DATE('2024-05-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (35, 67, TO_DATE('2024-05-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (36, 67, TO_DATE('2024-05-16', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (37, 67, TO_DATE('2024-05-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (38, 67, TO_DATE('2024-05-17', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (39, 67, TO_DATE('2024-05-17', 'YYYY-MM-DD'))
    
    -- 기타 게시물에 대한 '좋아요' 데이터 (일부)
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 80, TO_DATE('2023-12-25', 'YYYY-MM-DD')) -- 푸린의 노래
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 80, TO_DATE('2023-12-25', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (37, 80, TO_DATE('2023-12-25', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 82, TO_DATE('2023-03-11', 'YYYY-MM-DD')) -- 잠만보
    INTO LIKES (user_id, post_id, creation_date) VALUES (13, 82, TO_DATE('2023-03-11', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (16, 82, TO_DATE('2023-03-12', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (9, 47, TO_DATE('2024-04-21', 'YYYY-MM-DD')) -- 마이멜로디 베이킹
    INTO LIKES (user_id, post_id, creation_date) VALUES (10, 47, TO_DATE('2024-04-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (12, 47, TO_DATE('2024-04-21', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (2, 47, TO_DATE('2024-04-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 47, TO_DATE('2024-04-22', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (22, 75, TO_DATE('2023-07-08', 'YYYY-MM-DD')) -- 꼬부기 선글라스
    INTO LIKES (user_id, post_id, creation_date) VALUES (21, 75, TO_DATE('2023-07-08', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (24, 75, TO_DATE('2023-07-08', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (38, 75, TO_DATE('2023-07-09', 'YYYY-MM-DD'))
    INTO LIKES (user_id, post_id, creation_date) VALUES (1, 75, TO_DATE('2023-07-09', 'YYYY-MM-DD'))


		-- Post 3 (라이언) - Likes: 8
		INTO LIKES (user_id, post_id, creation_date) VALUES (40, 3, TO_DATE('2022-11-06', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 3, TO_DATE('2022-11-06', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (32, 3, TO_DATE('2022-11-06', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (2, 3, TO_DATE('2022-11-07', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (3, 3, TO_DATE('2022-11-07', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (7, 3, TO_DATE('2022-11-08', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (8, 3, TO_DATE('2022-11-08', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 3, TO_DATE('2022-11-09', 'YYYY-MM-DD'))
	
		-- Post 4 (라이언) - Likes: 18
		INTO LIKES (user_id, post_id, creation_date) VALUES (2, 4, TO_DATE('2023-01-01', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (3, 4, TO_DATE('2023-01-01', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (4, 4, TO_DATE('2023-01-01', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (5, 4, TO_DATE('2023-01-01', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (6, 4, TO_DATE('2023-01-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (7, 4, TO_DATE('2023-01-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (8, 4, TO_DATE('2023-01-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 4, TO_DATE('2023-01-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (10, 4, TO_DATE('2023-01-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (11, 4, TO_DATE('2023-01-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 4, TO_DATE('2023-01-04', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (22, 4, TO_DATE('2023-01-04', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (23, 4, TO_DATE('2023-01-04', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (24, 4, TO_DATE('2023-01-05', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (32, 4, TO_DATE('2023-01-05', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (33, 4, TO_DATE('2023-01-05', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (39, 4, TO_DATE('2023-01-06', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (40, 4, TO_DATE('2023-01-06', 'YYYY-MM-DD'))
		
		-- Post 21 (어피치) - Likes: 9
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 21, TO_DATE('2023-08-15', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (4, 21, TO_DATE('2023-08-15', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (8, 21, TO_DATE('2023-08-16', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (11, 21, TO_DATE('2023-08-16', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (25, 21, TO_DATE('2023-08-17', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (27, 21, TO_DATE('2023-08-17', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (10, 21, TO_DATE('2023-08-18', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (37, 21, TO_DATE('2023-08-18', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 21, TO_DATE('2023-08-19', 'YYYY-MM-DD'))

		-- Post 31 (프로도) - Likes: 5 (네오와 친구들)
		INTO LIKES (user_id, post_id, creation_date) VALUES (8, 31, TO_DATE('2024-05-18', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 31, TO_DATE('2024-05-19', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (2, 31, TO_DATE('2024-05-19', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (3, 31, TO_DATE('2024-05-20', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (5, 31, TO_DATE('2024-05-20', 'YYYY-MM-DD'))
	
		-- Post 46 (쿠로미) - Likes: 6
		INTO LIKES (user_id, post_id, creation_date) VALUES (10, 46, TO_DATE('2023-10-01', 'YYYY-MM-DD')) -- 라이벌 마이멜로디가 좋아요!
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 46, TO_DATE('2023-10-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (15, 46, TO_DATE('2023-10-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (30, 46, TO_DATE('2023-10-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (3, 46, TO_DATE('2023-10-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 46, TO_DATE('2023-10-04', 'YYYY-MM-DD'))

		-- Post 52 (시나모롤) - Likes: 11
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 52, TO_DATE('2024-05-08', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (10, 52, TO_DATE('2024-05-08', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (17, 52, TO_DATE('2024-05-09', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (18, 52, TO_DATE('2024-05-09', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 52, TO_DATE('2024-05-09', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (27, 52, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (33, 52, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 52, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (2, 52, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (4, 52, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (25, 52, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
			
		-- Post 56 (피카츄) - Likes: 20
		INTO LIKES (user_id, post_id, creation_date) VALUES (22, 56, TO_DATE('2022-07-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (23, 56, TO_DATE('2022-07-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (24, 56, TO_DATE('2022-07-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 56, TO_DATE('2022-07-23', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (5, 56, TO_DATE('2022-07-23', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (27, 56, TO_DATE('2022-07-23', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (31, 56, TO_DATE('2022-07-24', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (32, 56, TO_DATE('2022-07-24', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (33, 56, TO_DATE('2022-07-24', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (39, 56, TO_DATE('2022-07-25', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (40, 56, TO_DATE('2022-07-25', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 56, TO_DATE('2022-07-26', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (10, 56, TO_DATE('2022-07-26', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (12, 56, TO_DATE('2022-07-27', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (14, 56, TO_DATE('2022-07-27', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (19, 56, TO_DATE('2022-07-28', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (2, 56, TO_DATE('2022-07-28', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (3, 56, TO_DATE('2022-07-29', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (7, 56, TO_DATE('2022-07-29', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (8, 56, TO_DATE('2022-07-30', 'YYYY-MM-DD'))
	
		-- Post 72 (파이리) - Likes: 7
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 72, TO_DATE('2023-09-01', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (31, 72, TO_DATE('2023-09-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (36, 72, TO_DATE('2023-09-02', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 72, TO_DATE('2023-09-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (23, 72, TO_DATE('2023-09-03', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (24, 72, TO_DATE('2023-09-04', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (32, 72, TO_DATE('2023-09-04', 'YYYY-MM-DD'))
		
		-- Post 87 (메타몽) - Likes: 9
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 87, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (33, 87, TO_DATE('2024-05-10', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 87, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 87, TO_DATE('2024-05-11', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (27, 87, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (16, 87, TO_DATE('2024-05-12', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (6, 87, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (26, 87, TO_DATE('2024-05-13', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (13, 87, TO_DATE('2024-05-14', 'YYYY-MM-DD'))

		-- Post 90 (오박사) - Likes: 8
		INTO LIKES (user_id, post_id, creation_date) VALUES (1, 90, TO_DATE('2024-05-21', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (9, 90, TO_DATE('2024-05-21', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (32, 90, TO_DATE('2024-05-21', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (21, 90, TO_DATE('2024-05-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (22, 90, TO_DATE('2024-05-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (23, 90, TO_DATE('2024-05-22', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (24, 90, TO_DATE('2024-05-23', 'YYYY-MM-DD'))
		INTO LIKES (user_id, post_id, creation_date) VALUES (33, 90, TO_DATE('2024-05-23', 'YYYY-MM-DD'))

SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 D-7: 댓글 데이터 삽입 (DML - Curated Dummy Data)
-- 컨셉: 게시물에 대한 댓글 및 대댓글. 계층 구조 포함.
-- 특징:
-- 1. 2-depth의 계층 구조를 포함하여 CONNECT BY 쿼리 실습에 최적화
-- 2. 특정 게시물(58, 67번)에 댓글을 집중시켜 그룹핑 및 순위 분석 함수 실습에 용이
-- 3. 댓글이 없는 게시물을 두어 OUTER JOIN, 서브쿼리 실습 활용도 증대
-- =====================================================================
INSERT ALL
    -- Post 2 (라이언의 춘식이 자랑글) - Comments: 5, Replies: 2
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20001, 2, 3, '춘식이 너무 귀여워요! >_<', TO_DATE('2022-08-20', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20002, 2, 1, '고맙다 어피치야. ㅎㅎ', TO_DATE('2022-08-21', 'YYYY-MM-DD'), 20001) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20003, 2, 9, '정말 평화로워 보이네요. 보기 좋아요.', TO_DATE('2022-08-21', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20004, 2, 21, '피카피카! (나도 저기서 놀고 싶다!)', TO_DATE('2022-08-22', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20005, 2, 27, '이브이! (같이가자 피카츄!)', TO_DATE('2022-08-22', 'YYYY-MM-DD'), 20004) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20006, 2, 8, '고양이는 역시 최고야.', TO_DATE('2022-08-23', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20007, 2, 2, '냐냐! (감사합니다!)', TO_DATE('2022-08-23', 'YYYY-MM-DD'), NULL)

    -- Post 28 (프로도의 럽스타그램) - Comments: 2, Replies: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20008, 28, 8, '어머, 프로도 >.< 사랑해!', TO_DATE('2024-02-14', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20009, 28, 7, '나도 사랑해 네오!', TO_DATE('2024-02-14', 'YYYY-MM-DD'), 20008) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20010, 28, 1, '둘이 보기 좋구나.', TO_DATE('2024-02-15', 'YYYY-MM-DD'), NULL)

    -- Post 31 (프로도의 한탄글) - Comments: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20011, 31, 8, '흥! 그래도 사줄거잖아?', TO_DATE('2024-05-18', 'YYYY-MM-DD'), NULL)
    
    -- Post 46 (쿠로미의 라이벌 선언) - Comments: 2, Replies: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20012, 46, 10, '쿠로미도 참~ 같이 사이좋게 지내자!', TO_DATE('2023-10-01', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20013, 46, 11, '흥! 누가 친구래!', TO_DATE('2023-10-01', 'YYYY-MM-DD'), 20012) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20014, 46, 15, '쿠로미님 멋져요!', TO_DATE('2023-10-02', 'YYYY-MM-DD'), NULL)

    -- Post 58 (피카츄의 케첩 사랑) - 인기 게시물 1! Comments: 7, Replies: 3
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20015, 58, 22, '피카츄는 케첩을 정말 좋아하는구나.', TO_DATE('2023-02-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20016, 58, 23, '저렇게 맛있나? 나도 먹어볼래!', TO_DATE('2023-02-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20017, 58, 21, '피카! (안돼, 내꺼야!)', TO_DATE('2023-02-11', 'YYYY-MM-DD'), 20016) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20018, 58, 40, '허허, 피카츄의 케첩 사랑은 여전하구나.', TO_DATE('2023-02-12', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20019, 58, 1, '보기만 해도 흐뭇하네.', TO_DATE('2023-02-12', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20020, 58, 2, '고구마만큼 맛있나? 냐냐.', TO_DATE('2023-02-13', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20021, 58, 21, '피카피카츄! (비교할 수 없어!)', TO_DATE('2023-02-13', 'YYYY-MM-DD'), 20020) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20022, 58, 9, '정말 좋아하는 게 느껴져요!', TO_DATE('2023-02-14', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20023, 58, 24, '이상해.. (케첩이..?)', TO_DATE('2023-02-14', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20024, 58, 21, '피카피! (맛있어!)', TO_DATE('2023-02-14', 'YYYY-MM-DD'), 20023) -- 대댓글
    
    -- Post 67 (피카츄와 라이언 콜라보) - 인기 게시물 2! Comments: 11, Replies: 4
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20025, 67, 2, '라이언님과 피카츄님! 최고의 조합!', TO_DATE('2024-05-10', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20026, 67, 5, '둘 다 노란색이라 더 귀여워요!', TO_DATE('2024-05-10', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20027, 67, 1, '피카츄와 함께해서 즐거웠다.', TO_DATE('2024-05-10', 'YYYY-MM-DD'), 20025) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20028, 67, 9, '세기의 만남이네요! 멋져요!', TO_DATE('2024-05-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20029, 67, 32, '흥, 귀여운 것들끼리 모여있군.', TO_DATE('2024-05-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20030, 67, 33, '뮤! (둘 다 귀여워!)', TO_DATE('2024-05-11', 'YYYY-MM-DD'), 20029) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20031, 67, 12, '저도 같이 사진 찍고 싶어요!', TO_DATE('2024-05-12', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20032, 67, 22, '피카츄! 멋지다!', TO_DATE('2024-05-12', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20033, 67, 23, '꼬북! (인정!)', TO_DATE('2024-05-12', 'YYYY-MM-DD'), 20032) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20034, 67, 24, '이상해씨... (나도 노란색이었으면...)', TO_DATE('2024-05-13', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20035, 67, 40, '보기 좋은 조합이로구나.', TO_DATE('2024-05-13', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20036, 67, 3, '라이언 옆자리는 내껀데!', TO_DATE('2024-05-14', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20037, 67, 7, '다들 멋지다!', TO_DATE('2024-05-14', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20038, 67, 8, '역시 우리 프로도 최고!', TO_DATE('2024-05-14', 'YYYY-MM-DD'), 20037) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20039, 67, 21, '피카피! (다들 고마워!)', TO_DATE('2024-05-15', 'YYYY-MM-DD'), NULL)

    -- Post 81 (푸린의 낙서) - Comments: 3
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20040, 81, 21, '피카?! (내 얼굴에 누가 낙서했어!)', TO_DATE('2024-05-18', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20041, 81, 26, 'Zzzz... (난 못 봤어...)', TO_DATE('2024-05-18', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20042, 81, 25, '푸푸린~ (내가 안 그랬어~)', TO_DATE('2024-05-18', 'YYYY-MM-DD'), 20040) -- 대댓글

    -- Post 88 (갸라도스의 분노) - Comments: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20043, 88, 35, '갸라도스님... 진정하세요... ㅠㅠ', TO_DATE('2024-05-08', 'YYYY-MM-DD'), NULL)
    
    -- Post 90 (오박사의 당부) - Comments: 4
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20044, 90, 21, '피카피카! (네, 박사님!)', TO_DATE('2024-05-21', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20045, 90, 22, '열심히 하고 있어요!', TO_DATE('2024-05-21', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20046, 90, 23, '꼬북꼬북!', TO_DATE('2024-05-22', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20047, 90, 24, '이상해씨!', TO_DATE('2024-05-22', 'YYYY-MM-DD'), NULL)


    -- Post 1 (라이언의 책자랑) - Comments: 3
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20048, 1, 2, '냐냐... (베고 자기 좋아보인다...)', TO_DATE('2022-05-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20049, 1, 9, '좋은 책 추천 감사해요, 라이언씨!', TO_DATE('2022-05-11', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20050, 1, 40, '독서는 마음의 양식이지. 훌륭하구나.', TO_DATE('2022-05-12', 'YYYY-MM-DD'), NULL)

    -- Post 13 (라이언의 열일) - Comments: 2, Replies: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20051, 13, 3, '라이언 또 일해? 나랑 놀자!', TO_DATE('2024-05-16', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20052, 13, 1, '조금만 더 하고... ㅎㅎ', TO_DATE('2024-05-16', 'YYYY-MM-DD'), 20051)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20053, 13, 7, '멋지십니다!', TO_DATE('2024-05-16', 'YYYY-MM-DD'), NULL)

    -- Post 34 (헬로키티의 애플파이) - Comments: 4, Replies: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20054, 34, 10, '와, 정말 맛있겠다! 레시피 알려줄 수 있어?', TO_DATE('2022-10-31', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20055, 34, 13, '킁킁.. 맛있는 냄새가 여기까지 나는 것 같아요.', TO_DATE('2022-11-01', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20056, 34, 11, '흥, 내가 만든 게 더 맛있을걸! (...그래도 한입만)', TO_DATE('2022-11-01', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20057, 34, 1, '솜씨가 좋군요.', TO_DATE('2022-11-02', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20058, 34, 9, '물론이지, 마이멜로디! 언제든지 알려줄게!', TO_DATE('2022-10-31', 'YYYY-MM-DD'), 20054) -- 대댓글

    -- Post 47 (마이멜로디의 베이킹) - Comments: 2
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20059, 47, 9, '멜로디의 케이크는 언제나 최고야!', TO_DATE('2024-04-20', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20060, 47, 11, '...나도 한 조각만.', TO_DATE('2024-04-21', 'YYYY-MM-DD'), NULL)

    -- Post 75 (꼬부기단의 선글라스) - Comments: 2, Replies: 1
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20061, 75, 22, '뭐야 그 선글라스ㅋㅋ', TO_DATE('2023-07-07', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20062, 75, 23, '멋지지?', TO_DATE('2023-07-07', 'YYYY-MM-DD'), 20061) -- 대댓글
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20063, 75, 21, '피카피카! (멋있다!)', TO_DATE('2023-07-08', 'YYYY-MM-DD'), NULL)

    -- Post 85 (이브이와 피카츄) - Comments: 2
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20064, 85, 9, '귀여운 친구들이 모였네요!', TO_DATE('2024-05-12', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20065, 85, 1, '둘 다 귀엽구나.', TO_DATE('2024-05-13', 'YYYY-MM-DD'), NULL)

    -- Post 73 (파이리의 다짐) - Comments: 2
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20066, 73, 21, '피카! (응원할게!)', TO_DATE('2024-05-15', 'YYYY-MM-DD'), NULL)
    INTO COMMENTS (comment_id, post_id, user_id, comment_text, creation_date, parent_comment_id) VALUES (20067, 73, 31, '파이리, 너라면 할 수 있어.', TO_DATE('2024-05-16', 'YYYY-MM-DD'), NULL)
    



SELECT 1 FROM DUAL;

COMMIT;

-- =====================================================================
-- 파트 C: 관계 무결성 설정 (DDL - Foreign Keys)
-- ALTER TABLE 문을 사용하여 외래 키 제약조건을 추가합니다.
-- 테이블 생성 후 별도로 FK를 정의하면 상호 참조 등으로 인한 생성 오류를 방지할 수 있습니다.
-- =====================================================================

-- USERS (자기참조)
ALTER TABLE USERS ADD CONSTRAINT fk_users_manager FOREIGN KEY (manager_id) REFERENCES USERS(user_id);

-- USER_PROFILES (1:1 관계)
ALTER TABLE USER_PROFILES ADD CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE;

-- POSTS
ALTER TABLE POSTS ADD CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE;

-- COMMENTS
ALTER TABLE COMMENTS ADD CONSTRAINT fk_comments_post FOREIGN KEY (post_id) REFERENCES POSTS(post_id) ON DELETE CASCADE;
ALTER TABLE COMMENTS ADD CONSTRAINT fk_comments_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE;
ALTER TABLE COMMENTS ADD CONSTRAINT fk_comments_parent FOREIGN KEY (parent_comment_id) REFERENCES COMMENTS(comment_id) ON DELETE CASCADE;

-- LIKES
ALTER TABLE LIKES ADD CONSTRAINT fk_likes_user FOREIGN KEY (user_id) REFERENCES USERS(user_id) ON DELETE CASCADE;
ALTER TABLE LIKES ADD CONSTRAINT fk_likes_post FOREIGN KEY (post_id) REFERENCES POSTS(post_id) ON DELETE CASCADE;

-- FOLLOWS
ALTER TABLE FOLLOWS ADD CONSTRAINT fk_follows_follower FOREIGN KEY (follower_id) REFERENCES USERS(user_id) ON DELETE CASCADE;
ALTER TABLE FOLLOWS ADD CONSTRAINT fk_follows_following FOREIGN KEY (following_id) REFERENCES USERS(user_id) ON DELETE CASCADE;

-- POST_TAGS
ALTER TABLE POST_TAGS ADD CONSTRAINT fk_post_tags_post FOREIGN KEY (post_id) REFERENCES POSTS(post_id) ON DELETE CASCADE;
ALTER TABLE POST_TAGS ADD CONSTRAINT fk_post_tags_tag FOREIGN KEY (tag_id) REFERENCES HASHTAGS(tag_id) ON DELETE CASCADE;