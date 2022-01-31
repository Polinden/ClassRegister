--
-- PostgreSQL database dump
--

-- Dumped from database version 11.6 (Ubuntu 11.6-1.pgdg16.04+1)
-- Dumped by pg_dump version 11.6 (Ubuntu 11.6-1.pgdg16.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fmh; Type: DATABASE; Schema: -; Owner: postgres
--

CREATE DATABASE fmh WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'ru_UA.UTF-8' LC_CTYPE = 'ru_UA.UTF-8';


ALTER DATABASE fmh OWNER TO postgres;

\connect fmh

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: fmh; Type: DATABASE PROPERTIES; Schema: -; Owner: postgres
--

ALTER DATABASE fmh SET "TimeZone" TO 'Europe/Kiev';


\connect fmh

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: active_prepod(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.active_prepod() RETURNS TABLE(f1 text, f2 text, f3 text)
    LANGUAGE sql
    AS $$
 with pppp as (select subject, class_name from journal where date>'2017.08.01' and mark<>0),  
  rrrr as (select class_name, subject, first_name||' '||second_name as fnsn from schedule_and_class 
   join prepod on prepod.schedule_id=schedule_and_class.schedules_id join users on users.login=prepod.login) 
     select distinct fnsn, rrrr.class_name, rrrr.subject from rrrr join pppp 
       on pppp.class_name=rrrr.class_name and pppp.subject=rrrr.subject order by fnsn;
$$;


ALTER FUNCTION public.active_prepod() OWNER TO postgres;

--
-- Name: class_aver(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.class_aver(class text, subj text) RETURNS TABLE(s_name character varying, s_mark text)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
return query select u.first_name, to_char(avg (CASE WHEN mark <> 0 THEN mark ELSE NULL END), '99D9') as av from journal 
inner join 
users as u on u.login=stud_login where class_name=class and subject=subj group by u.login order by av desc;
END
$$;


ALTER FUNCTION public.class_aver(class text, subj text) OWNER TO postgres;

--
-- Name: class_aver(text, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.class_aver(class text, subj text, topic_work text) RETURNS TABLE(s_name text, s_mark numeric)
    LANGUAGE plpgsql
    AS $$
        BEGIN
        IF topic_work<>'' THEN
        return query select u.first_name||' '||substring(u.second_name, 1,1)||'.', round(avg(CASE WHEN mark <> 0 THEN mark ELSE NULL END),1) as av from journal
        inner join
        users as u on u.login=stud_login where class_name=class and subject=subj and date>get_stud_year_startj()
         and work=topic_work
         group by u.login order by av desc;
        
        ELSE
        return query select u.first_name||' '||substring(u.second_name, 1,1)||'.', round(avg(CASE WHEN mark <> 0 THEN mark ELSE NULL END),1) as av from journal
        inner join
        users as u on u.login=stud_login where class_name=class and subject=subj and date>get_stud_year_startj() group by u.login order by av desc;
        END IF;
        END
        $$;


ALTER FUNCTION public.class_aver(class text, subj text, topic_work text) OWNER TO postgres;

--
-- Name: class_aver_allsubj(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.class_aver_allsubj(class text) RETURNS TABLE(s_name character varying, s_mark text)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
return query
select u.first_name, to_char(avg (CASE WHEN mark <> 0 THEN mark ELSE NULL END), '99D9') as av from journal 
inner join 
users as u on u.login=stud_login where class_name=class group by u.login order by av desc;
END
$$;


ALTER FUNCTION public.class_aver_allsubj(class text) OWNER TO postgres;

--
-- Name: class_aver_allsubj(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.class_aver_allsubj(class text, topic_work text) RETURNS TABLE(s_name text, s_mark numeric)
    LANGUAGE plpgsql
    AS $$
        BEGIN
        IF topic_work<>'' THEN
        return query select u.first_name||' '||substring(u.second_name, 1,1)||'.', round(avg(CASE WHEN mark <> 0 THEN mark ELSE NULL END),1) as av from journal
        inner join
        users as u on u.login=stud_login where class_name=class and date>=get_stud_year_startj()
        and work=topic_work
        group by u.login order by av desc;
        
        ELSE
        return query select u.first_name||' '||substring(u.second_name, 1,1)||'.', round(avg(CASE WHEN mark <> 0 THEN mark ELSE NULL END),1) as av from journal
        inner join
        users as u on u.login=stud_login where class_name=class and date>=get_stud_year_startj() group by u.login order by av desc;
        END IF;
        END
        $$;


ALTER FUNCTION public.class_aver_allsubj(class text, topic_work text) OWNER TO postgres;

--
-- Name: clean_jn(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.clean_jn() RETURNS void
    LANGUAGE plpgsql
    AS $$
        begin
        with dd as (select d,s,cn from
        (select date as d, subject as s, class_name as cn, sum(mark)
        as m from journal group by date, subject, class_name) as dd1 where m=0)
        delete from journal as j where (j.date, j.class_name, j.subject) in
        (select d,cn,s from dd);
        end;
        $$;


ALTER FUNCTION public.clean_jn() OWNER TO postgres;

--
-- Name: del_old_from_journal(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.del_old_from_journal() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
delete from journal where date < get_stud_year_startj () and
topic <> 'Підсумкові оцінки';
  end;
$$;


ALTER FUNCTION public.del_old_from_journal() OWNER TO postgres;

--
-- Name: del_spaces(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.del_spaces() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
        update users set first_name = regexp_replace(first_name, '[\s\t\r]', '');
        update users set second_name = regexp_replace(second_name, '[\s\t\r]', '');
        update users set third_name = regexp_replace(third_name, '[\s\t\r]', '');
        update users set login = regexp_replace(login, '[\s\t\r]', '');
        update users set password = regexp_replace(password, '[\s\t\r]', '');


END;
$$;


ALTER FUNCTION public.del_spaces() OWNER TO postgres;

--
-- Name: get_stud_year_startj(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_stud_year_startj() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
        BEGIN
        return case when (age(now(),  to_timestamp(date_part('year', now())||'-09-01', 'YYYY-MM-DD'))<interval '0') then (to_timestamp(date_part('year', now())||'-09-01', 'YYYY-MM-DD') - interval '1 years') else (to_timestamp(date_part('year', now())||'-09-01', 'YYYY-MM-DD'))  end;
        END
        $$;


ALTER FUNCTION public.get_stud_year_startj() OWNER TO postgres;

--
-- Name: get_stud_year_summary_end(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_stud_year_summary_end() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
        BEGIN
          return case when (age(now(),  to_timestamp(date_part('year', now())||'-08-31', 'YYYY-MM-DD'))<interval '0')
          then (to_timestamp(date_part('year', now())||'-08-31', 'YYYY-MM-DD') - interval '1 years')
          else (to_timestamp(date_part('year', now())||'-08-31', 'YYYY-MM-DD'))  end;
        END
        $$;


ALTER FUNCTION public.get_stud_year_summary_end() OWNER TO postgres;

--
-- Name: get_stud_year_summary_start(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_stud_year_summary_start() RETURNS timestamp without time zone
    LANGUAGE plpgsql
    AS $$
        BEGIN
          return case when (age(now(),  to_timestamp(date_part('year', now())||'-08-31', 'YYYY-MM-DD'))<interval '0')
          then (to_timestamp(date_part('year', now())||'-08-01', 'YYYY-MM-DD') - interval '1 years')
          else (to_timestamp(date_part('year', now())||'-08-01', 'YYYY-MM-DD'))  end;
        END
        $$;


ALTER FUNCTION public.get_stud_year_summary_start() OWNER TO postgres;

--
-- Name: top21(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.top21(topic_work text) RETURNS TABLE(n text, m numeric)
    LANGUAGE plpgsql
    AS $_$
        BEGIN
        IF topic_work<>'' THEN
        return query
        with sss1 as
                (select stud_login as login, u.first_name||' '
                 ||substring(u.second_name, 1,1)||'.' as name,
                 round(avg(CASE WHEN mark <> 0 THEN mark ELSE null END),1) as av,
        count(mark) as cm from journal
        inner join users as u on u.login=stud_login
        where date>get_stud_year_startj() and work=topic_work group by stud_login, u.login),

        sss2 as
        (select max(cm)+0.1 as cccm, max(av)+0.1 as xxxm from sss1)

        select name||' '||cas.class_name as names, av from sss2, sss1
        inner join class_and_students as cas on cas.students_login=login
        where (cas.class_name ~ '\d{1,2}[а-я]{1,1}$')=true and av IS NOT NULL
        order by (7*av/xxxm+cm/cccm) desc limit 20;

        ELSE
        return query
        with sss1 as
                (select stud_login as login, u.first_name||' '
                 ||substring(u.second_name, 1,1)||'.' as name,
                 round(avg(CASE WHEN mark <> 0 THEN mark ELSE null END),1) as av,
        count(mark) as cm from journal
        inner join users as u on u.login=stud_login
        where date>get_stud_year_startj() group by stud_login, u.login),

        sss2 as
        (select max(cm)+0.1 as cccm, max(av)+0.1 as xxxm from sss1 where cm>30)

        select name||' '||cas.class_name as names, av from sss2, sss1
        inner join class_and_students as cas on cas.students_login=login
        where (cas.class_name ~ '\d{1,2}[а-я]{1,1}$')=true and cm>30 and av IS NOT NULL
        order by (7*av/xxxm+cm/cccm) desc limit 20;

        END IF;

        END
        $_$;


ALTER FUNCTION public.top21(topic_work text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: authorities; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.authorities (
    login character varying(20) NOT NULL,
    authority character varying(10) NOT NULL
);


ALTER TABLE public.authorities OWNER TO fmh;

--
-- Name: TABLE authorities; Type: COMMENT; Schema: public; Owner: fmh
--

COMMENT ON TABLE public.authorities IS 'рівень доступу';


--
-- Name: class; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.class (
    class_name character varying(8) NOT NULL
);


ALTER TABLE public.class OWNER TO fmh;

--
-- Name: TABLE class; Type: COMMENT; Schema: public; Owner: fmh
--

COMMENT ON TABLE public.class IS 'довідник класів';


--
-- Name: class_and_students; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.class_and_students (
    class_name character varying(8) NOT NULL,
    students_login character varying(20) NOT NULL
);


ALTER TABLE public.class_and_students OWNER TO fmh;

--
-- Name: prepod; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.prepod (
    schedule_id bigint NOT NULL,
    subject character varying(30) NOT NULL,
    login character varying(20) NOT NULL
);


ALTER TABLE public.prepod OWNER TO fmh;

--
-- Name: schedule_and_class; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.schedule_and_class (
    schedules_id bigint NOT NULL,
    class_name character varying(8) NOT NULL
);


ALTER TABLE public.schedule_and_class OWNER TO fmh;

--
-- Name: subject_list; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.subject_list (
    subject character varying(30) NOT NULL
);


ALTER TABLE public.subject_list OWNER TO fmh;

--
-- Name: free_cl_and_subh; Type: VIEW; Schema: public; Owner: fmh
--

CREATE VIEW public.free_cl_and_subh AS
 SELECT x.c1,
    x.s1
   FROM ( SELECT class.class_name AS c1,
            subject_list.subject AS s1
           FROM public.class,
            public.subject_list) x
  WHERE ((NOT (((x.c1)::text || (x.s1)::text) IN ( SELECT ((schedule_and_class.class_name)::text || (prepod.subject)::text)
           FROM (public.prepod
             JOIN public.schedule_and_class ON ((prepod.schedule_id = schedule_and_class.schedules_id)))))) AND ("substring"((x.c1)::text, '[\d]+'::text) = "substring"((x.s1)::text, '[\d]+'::text)))
  ORDER BY x.c1;


ALTER TABLE public.free_cl_and_subh OWNER TO fmh;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: public; Owner: fmh
--

CREATE SEQUENCE public.hibernate_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.hibernate_sequence OWNER TO fmh;

--
-- Name: journal; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.journal (
    id bigint NOT NULL,
    comment character varying(40),
    date date,
    mark integer NOT NULL,
    present boolean DEFAULT true NOT NULL,
    show_date boolean DEFAULT true NOT NULL,
    subject character varying(30) NOT NULL,
    topic character varying(25),
    work character varying(25),
    stud_login character varying(20) NOT NULL,
    class_name character varying(8) NOT NULL,
    CONSTRAINT journal_mark_check CHECK (((mark >= 0) AND (mark <= 12)))
);


ALTER TABLE public.journal OWNER TO fmh;

--
-- Name: move; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.move (
    login character varying(20) NOT NULL,
    in_date date NOT NULL,
    in_order character varying(10),
    in_comment character varying(20),
    out_date date,
    out_comment character varying(20),
    out_order character varying(10)
);


ALTER TABLE public.move OWNER TO fmh;

--
-- Name: TABLE move; Type: COMMENT; Schema: public; Owner: fmh
--

COMMENT ON TABLE public.move IS 'рух учнів';


--
-- Name: prepod4cl_and_subh; Type: VIEW; Schema: public; Owner: fmh
--

CREATE VIEW public.prepod4cl_and_subh AS
 SELECT sl.class_name,
    p.subject,
    p.login
   FROM (public.prepod p
     JOIN public.schedule_and_class sl ON ((sl.schedules_id = p.schedule_id)));


ALTER TABLE public.prepod4cl_and_subh OWNER TO fmh;

--
-- Name: prepod_id; Type: SEQUENCE; Schema: public; Owner: fmh
--

CREATE SEQUENCE public.prepod_id
    START WITH 7
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.prepod_id OWNER TO fmh;

--
-- Name: prepod_id; Type: SEQUENCE OWNED BY; Schema: public; Owner: fmh
--

ALTER SEQUENCE public.prepod_id OWNED BY public.prepod.schedule_id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.roles (
    role character varying(10) NOT NULL
);


ALTER TABLE public.roles OWNER TO fmh;

--
-- Name: spr_auth; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.spr_auth (
    login character varying(20) NOT NULL,
    authority character varying(10) NOT NULL
);


ALTER TABLE public.spr_auth OWNER TO fmh;

--
-- Name: spr_users; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.spr_users (
    login character varying(20) NOT NULL,
    password character varying(20) NOT NULL,
    enabled boolean NOT NULL,
    first_name character varying(50) NOT NULL,
    second_name character varying(50) NOT NULL,
    third_name character varying(50)
);


ALTER TABLE public.spr_users OWNER TO fmh;

--
-- Name: users; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.users (
    login character varying(20) NOT NULL,
    password character varying(20) NOT NULL,
    enabled boolean NOT NULL,
    first_name character varying(50) NOT NULL,
    second_name character varying(50) NOT NULL,
    third_name character varying(50)
);


ALTER TABLE public.users OWNER TO fmh;

--
-- Name: students; Type: VIEW; Schema: public; Owner: fmh
--

CREATE VIEW public.students AS
 SELECT cs.class_name,
    users.first_name,
    users.second_name,
    au.login,
    users.password
   FROM ((public.users
     FULL JOIN public.class_and_students cs ON (((cs.students_login)::text = (users.login)::text)))
     JOIN public.authorities au ON (((au.login)::text = (users.login)::text)))
  WHERE ((au.authority)::text <> 'prepod'::text)
  ORDER BY cs.class_name, users.first_name;


ALTER TABLE public.students OWNER TO fmh;

--
-- Name: teachers; Type: VIEW; Schema: public; Owner: fmh
--

CREATE VIEW public.teachers AS
 SELECT p.subject,
    sc.class_name,
    u.first_name,
    u.second_name,
    u.login,
    sc.schedules_id
   FROM ((public.users u
     JOIN public.prepod p ON (((p.login)::text = (u.login)::text)))
     JOIN public.schedule_and_class sc ON ((sc.schedules_id = p.schedule_id)))
  ORDER BY p.subject, u.first_name;


ALTER TABLE public.teachers OWNER TO fmh;

--
-- Name: topics; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.topics (
    sched4t_id bigint NOT NULL,
    topic character varying(25)
);


ALTER TABLE public.topics OWNER TO fmh;

--
-- Name: works; Type: TABLE; Schema: public; Owner: fmh
--

CREATE TABLE public.works (
    sched4w_id bigint NOT NULL,
    work character varying(25)
);


ALTER TABLE public.works OWNER TO fmh;

--
-- Name: prepod schedule_id; Type: DEFAULT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.prepod ALTER COLUMN schedule_id SET DEFAULT nextval('public.prepod_id'::regclass);


--
-- Data for Name: authorities; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.authorities (login, authority) FROM stdin;
papa	prepod
polya	stud
baranova	stud
karamyan	stud
afonin	stud
balkashinov	stud
borodin	stud
goroh	stud
zaluzhniy	stud
zemelev	stud
ivanchyk	stud
bachynska	stud
kovalenko	stud
krasnovskii	stud
krutov	stud
bernada	stud
leontiyeva	stud
matiyko	stud
ostashevsky	stud
pokras	stud
ryzhov	stud
rizayev	stud
sidorenko	stud
starozhilova	stud
stec	stud
tishchenko	stud
tovkes	stud
tolstanova	stud
chehovoy	stud
chistov	stud
chumak	stud
lconst	prepod
biletska	stud
bilyk	stud
levchenko	stud
vorobyov	stud
hlushenkova	stud
ivahnenkov	stud
homenyuk	stud
hrymailo	stud
hubenko	stud
zabolotnyi	stud
klimenko	stud
kovba	stud
kovtun	stud
len	stud
malev	stud
mamenko	stud
navka	stud
nyzhnyk	stud
piskun	stud
podolsky	stud
ponomarenko	stud
prokopenko	stud
rafalyuk	stud
svystun	stud
slyusarenko	stud
shramko	stud
yakovlev	stud
bykov	stud
bondarenko	stud
horaychuk	stud
gordienko	stud
grimalska	stud
dekret	stud
dzyuba	stud
kanderal	stud
klymenko	stud
knopova	stud
korniychyk	stud
kravets	stud
kutsenko	stud
lyubyma	stud
martynchenko	stud
mikhailov	stud
myhalko	stud
moroz	stud
naumenko	stud
nimchenko	stud
novikov	stud
nudha	stud
stepura	stud
strus	stud
khmelevskyy	stud
tsymbalenko	stud
tsubina	stud
shpolyanska	stud
berestyanyy	stud
borysiuk	stud
bratchyk	stud
ramyk	stud
samarin	stud
filkin	stud
chernenko	stud
shcherbak	stud
shchurovsky	stud
yatsyk	stud
kyrychenko	stud
krast	stud
kuzma	stud
lisnichenko	stud
litvinova	stud
lukyanov	stud
mandryka	stud
pavlov	stud
simonov	stud
snyehovskyy	stud
sonkina	stud
fedoruk	stud
shulgin	stud
kua	prepod
siv	prepod
svm	prepod
fekla	prepod
goy	prepod
braginskyi16	stud
dudnyk16	stud
zholner16	stud
zubareva16	stud
pryshchepa16	stud
cherevko16	stud
chechotkin16	stud
sheredeko16	stud
4ernywenko16	stud
alekseev16	stud
bega16	stud
bizura16	stud
bondarenkoo16	stud
fal16	stud
gon4arenko16	stud
lugovaj16	stud
lugovam16	stud
mal4enko16	stud
miniaylo16	stud
muraviov16	stud
mmoroz	prepod
plusnin16	stud
kononenko	stud
krynko16	stud
royik16	stud
kovika16	stud
sharov	stud
pyvovar16	stud
gulaya	stud
palamarchuk	stud
sapelnikov16	stud
sokolovsky16	stud
mns	prepod
pvv	prepod
sio	prepod
yni	prepod
pyhalova16	stud
klm	prepod
su4kova16	stud
targonsky16	stud
kop	prepod
palamU20	stud
barash16	stud
danilov16	stud
zhylin16	stud
kolisnyk16	stud
kostytska16	stud
levoshko16	stud
mamichev16	stud
mozol16	stud
shchurov16	stud
pylypenko16	stud
posternak16	stud
sachokv16	stud
sachoki16	stud
slavska16	stud
stakhurska16	stud
chub16	stud
shapovalova16	stud
basovds	prepod
rtm	prepod
kotliarova16	stud
zdebka16	stud
khan	prepod
makhrovaov	prepod
rustamovavp	prepod
med	prepod
saviak16	stud
babich15	stud
bakai15	stud
baranivskyi15	stud
lytvak15	stud
vasylieva15	stud
venher15	stud
vinichenko15	stud
vorotchenko15	stud
humennyk15	stud
kobylinska15	stud
kovalenko15	stud
malovanyi15	stud
menabde15	stud
mudrahel15	stud
nehuliaiev15	stud
norenko15	stud
padusenko15	stud
ponomarenko15	stud
piatyhorskyi15	stud
rallo15	stud
rudenko15	stud
tarasenko15	stud
khyzhniak15	stud
yalovenko15	stud
morozdo	prepod
barlas14	stud
bilokur14	stud
bondarenko14	stud
vasylenko14	stud
holovach14	stud
davydova14	stud
dmytruk14	stud
yerko14	stud
zhuk14	stud
zurov14	stud
malovanyi14	stud
mysak14	stud
mindich14	stud
mordvintseva14	stud
nikitin14	stud
osadcha14	stud
ostapenko14	stud
panasiuk14	stud
prystiuk14	stud
samartseva14	stud
seniuk14	stud
senko14	stud
taran14	stud
teslia14	stud
fisunenko14	stud
khabatiuk14	stud
khropachov14	stud
zubchenkovp	prepod
haluha16	stud
zaika16	stud
skytsuk16	stud
khodakovskyi15	stud
honcharuk15	stud
mudruk15	stud
mezhenskyi15	stud
yerko16	stud
maliuha16	stud
pokotylo16	stud
pihulevska16	stud
tarasenko16	stud
dolhov15	stud
kozynets16	stud
nikanov15	stud
tsymbalenko16	stud
taiakina16	stud
zinchukvm	prepod
savinov16	stud
lukianenko15	stud
shkura15	stud
zvarych15	stud
murynskavv	prepod
gabia	stud
nahorna15	stud
vasyliev17	stud
zaitsev17	stud
kurochkin17	stud
milevska17	stud
nahorna17	stud
ofursova	prepod
iatsyk17	stud
borets17	stud
vynny	prepod
dobrzhanskyi17	stud
stepanova17	stud
burliai16	stud
bilous17	stud
zaiets17	stud
top	prepod
rozenwine	prepod
bruiev17	stud
bulakh17	stud
vasylchenko17	stud
vyhovskyi17	stud
haieva17	stud
balatsuk17	stud
vasylieva17	stud
demenkov17	stud
molodtsova17	stud
kyslenko17	stud
naumov17	stud
popova17	stud
prytup17	stud
savchenko17	stud
solomakha17	stud
mikliaiev16	stud
fla	prepod
zhmailo16	stud
mosiichuk16	stud
pavlov16	stud
ltv	prepod
tonkoshkur16	stud
synytsia16	stud
bohun16	stud
zadorozhnyi16	stud
rudyi16	stud
sobolevskyi16	stud
khalapsus16	stud
tsukanov16	stud
vyshnevetska16	stud
diachuk16	stud
kalinichenko16	stud
sydorak16	stud
oip48	prepod
cherniakova16	stud
akymenko16	stud
sahaidaktv	prepod
IrinaSklyar	prepod
pivenn16	stud
pivenx16	stud
tkachenko16	stud
husieiev17	stud
ievtodii17	stud
zhukovska17	stud
klymenko17	stud
kapustian17	stud
kolosok17	stud
marchenko17	stud
naveriani17	stud
nahornyi17	stud
rybalchenko17	stud
starunov17	stud
chernyshova17	stud
churylovych17	stud
vekha17	stud
zlotoiabko17	stud
kostia17	stud
lisovenko17	stud
lishanska17	stud
mykhailovskyi17	stud
ohorodnytskyi17	stud
okunievskyi17	stud
romanchenko17	stud
chikilov17	stud
shynkarenko17	stud
iurchenkom17	stud
onufryk17	stud
danylchenko16	stud
kolodkars	prepod
kovalchuk15	stud
savin15	stud
yaroslav	prepod
teryu	prepod
klymashevskyy	stud
kotsyk16	stud
nikitkakiev	stud
mordvynov17	stud
rosiiskov17	stud
Rouqen	stud
kleshchevnikov16	stud
gavrylchenkooooo	stud
drin	stud
arseniuk	stud
domnich16	stud
bilaonova15	stud
vylushchak17	stud
didenkodm	stud
kovtun17	stud
makhmudov17	stud
nemiatyi17	stud
stetsiuk17	stud
sheremetiev17	stud
shevel17	stud
bondarieva17	stud
levtik	prepod
patraboi17	stud
pliushchai17	stud
siryk17	stud
falko17	stud
miakobchuk	stud
borovyi17	stud
havrysh17	stud
komarov17	stud
muzychuk17	stud
riabichenko17	stud
bardyk15	stud
blp	prepod
ushakovv	stud
simonovandr	stud
zaporozhets	stud
senchenko	stud
andrus18	stud
babenk18	stud
danilo18	stud
іvanov18	stud
ieremenko17	stud
lomono18	stud
mazur18	stud
majdan18	stud
nester18	stud
novoha18	stud
prijma18	stud
selezn18	stud
shevtsov17	stud
hutorj18	stud
chorno18	stud
chufar18	stud
vojteh18	stud
erіk18	stud
zagoru18	stud
konber18	stud
zabarianska16	stud
maznichenko16	stud
matrosova	stud
malenko17	stud
GalinaFox	stud
stopchatyi16	stud
bovdui16	stud
bidasiuk	stud
kysliuk17	stud
koval17	stud
Lichutin	stud
skorobahatko17	stud
ivkoliz05	stud
Goldmayer	stud
bokhonovatu	prepod
vborysiuk	prepod
kosenk18	stud
lavrov18	stud
macheh18	stud
palama18	stud
semenk18	stud
tkachuk21	stud
1vahne18	stud
bakun	stud
barabash17	stud
berezhanskyi17	stud
vasiuta17	stud
zhytnik17	stud
kozyr17	stud
matsiukira	stud
KucherV17	stud
volodia2bondar	stud
pasechnykm	stud
IvanP	stud
ryzhenko17	stud
igorroik	stud
samarina17	stud
cezar17	stud
iezhel17	stud
romanov21	stud
chorni18	stud
tvnnk16	stud
ishche18	stud
vernk18	stud
papizh17	stud
Vysotskyy	stud
danyliuk16	stud
vlad	stud
redia16	stud
samarets16	stud
sizikova16	stud
sniehovskyi16	stud
diachenko	stud
jarko143	stud
barash18	stud
pashev18	stud
rezn18	stud
shtand18	stud
chobot18	stud
kamns18	stud
rachkevych17	stud
ischuk18	stud
galabu18	stud
gorn18	stud
golova18	stud
zhirno18	stud
konone18	stud
redina16	stud
mykhaelian17	stud
Yakubyshyn	stud
aleks18	stud
borise18	stud
dubas18	stud
zozulj18	stud
panfl18	stud
rubash18	stud
ardashov16	stud
soloma18	stud
tarannS20	stud
komarovM20	stud
bannij18	stud
mahinj18	stud
agarkov16	stud
kuzmishyna16	stud
strechin16	stud
afonin18	stud
kurchi18	stud
shydlovskyy15	stud
demche18	stud
panteleimonova16	stud
melesh18	stud
gajovi18	stud
rat	prepod
fml	prepod
hip	prepod
rnv	prepod
mli	prepod
Andria23	stud
linkan	stud
vea	prepod
Aleksie23	stud
Borys23	stud
Bernad23	stud
Burache23	stud
Vvas	stud
Hudzen23	stud
Husieiev23	stud
Dmytru23	stud
Dudko23	stud
Iholki23	stud
Kornii23	stud
Kravche23	stud
Krasno23	stud
LishYaro23	stud
LishOle23	stud
Mariukhi23	stud
Masnyi23	stud
Mysiv23	stud
Moloka23	stud
Nehoda23	stud
Nemiata23	stud
Parashchi23	stud
Pustov23	stud
Sazono23	stud
Skalats23	stud
Sporik23	stud
Stolbu23	stud
Khiuste23	stud
Cherba23	stud
Antono23	stud
Akhmeto23	stud
Varlam23	stud
Volove23	stud
Viniche23	stud
Homeniu23	stud
Hromov23	stud
Drobiaz23	stud
Diubenk23	stud
Zabolo23	stud
Koben23	stud
Kondra23t	stud
Kondra23c	stud
Krynyts23	stud
Kirieiev23	stud
Makhtieie23	stud
Nyzhnyk23	stud
Nikano23	stud
Pykhtin23	stud
Polovn23	stud
Poster23	stud
Ryzhova23	stud
Runchev23	stud
Riabiche23	stud
Savchen23	stud
Salan23	stud
Taraso23	stud
Tuktam23	stud
Fenina23	stud
Fachchin23	stud
Khanevy23	stud
Avdieien23	stud
Bedash23	stud
Bizhan23	stud
Bobesiu23	stud
Herus23	stud
Hlushko23	stud
Danchen23	stud
Dvirny23	stud
Zabaria23	stud
Ihnatu23	stud
Kyryliu23	stud
Korine23	stud
Korol23	stud
Korsun23	stud
Lypiats23	stud
Lykhoho23	stud
Maznich23	stud
Meshchan23	stud
Mykola23	stud
Mykhail23	stud
Mushchenk23	stud
Natal23	stud
Struko23	stud
Tsiupko23	stud
Chernets23	stud
Shchurovs23	stud
antoniuk22	stud
vov	prepod
krasnopol22	stud
zubish22	stud
mkyryliuk	prepod
Tomashe23	stud
lazore18	stud
voronin16	stud
vasylievn17	stud
petrenko	stud
iurchenkof17	stud
verbov18	stud
horoh18	stud
aop1993	prepod
granov18	stud
bagan18	stud
didish18	stud
dreger18	stud
zhmend18	stud
guman18	stud
zasoba18	stud
karpen18	stud
koval18	stud
kosten18	stud
kucher18	stud
lut18	stud
mudrag18	stud
mhnov18	stud
knopG19	stud
ohten18	stud
poplav18	stud
potiomk18	stud
rogovt18	stud
sahno18	stud
slsar18	stud
slch18	stud
timosh18	stud
topork18	stud
trojn18	stud
trotsk18	stud
shvora18	stud
shychy18	stud
janush18	stud
kozoriezova17	stud
Bahrych	stud
raetsk18	stud
tsimba18	stud
erik18	stud
shkil18	stud
sichka18	stud
tomkiv18	stud
peo	prepod
rli	prepod
HarbuzS	stud
Karimov18	stud
KurochDan	stud
prokopS18	stud
cherka18	stud
chubar18	stud
Rusinova	stud
bns	prepod
\.


--
-- Data for Name: class; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.class (class_name) FROM stdin;
9б
10а
10б
10в
10г
11а
11б
11в
11г
8а
8б
8в
8г
9а
9в
9г
9а-анг1
9а-анг2
9а-інф1
9а-інф2
9в-інф1
9в-інф2
8а-анг1
8а-анг2
8а-інф1
8а-інф2
8в-анг1
8в-анг2
8в-інф1
8в-інф2
8б-анг1
8б-анг2
8б-інф1
8б-інф2
9б-анг1
9б-анг2
9в-анг1
9в-анг2
9б-інф1
9б-інф2
10а-анг1
10а-анг2
10б-анг1
10б-анг2
10в-анг1
10г-анг1
10в-анг2
10г-інф1
10г-інф2
10г-анг2
10а-інф1
10в-інф1
10в-інф2
10а-інф2
10б-інф1
10б-інф2
8г-анг1
8г-анг2
8г-інф1
8г-інф2
9г-анг1
9г-анг2
9г-інф1
9г-інф2
кв11_1
кв11_2
кв11_3
кв11_4
кв11_5
кв11_6
кв11_7
кв11_8
11а-анг1
11а-анг2
11б-анг2
11б-анг1
11в-анг1
11в-анг2
11г-анг1
11г-анг2
11а-інф1
11а-інф2
11б-інф1
11б-інф2
11в-інф1
11в-інф2
11г-інф1
11г-інф2
10а-зхв1
10а-зхв2
11а-зхв2
11а-зхв1
10б-зхв1
10б-зхв2
11б-зхв2
11б-зхв1
10в-зхв1
10в-зхв2
11в-зхв2
11в-зхв1
10г-зхв1
10г-зхв2
11г-зхв2
11г-зхв1
10а-фзк1
10а-фзк2
11а-фзк2
11а-фзк1
10б-фзк1
10б-фзк2
11б-фзк2
11б-фзк1
10в-фзк1
10в-фзк2
11в-фзк2
11в-фзк1
10г-фзк1
10г-фзк2
11г-фзк2
11г-фзк1
8а-іт1
8а-іт2
8б-іт2
8б-іт1
8в-іт1
8в-іт2
8г-іт2
8г-іт1
9г-іт1
9г-іт2
9в-іт2
9в-іт1
9б-іт1
9б-іт2
9а-іт2
9а-іт1
10а-іт1
10а-іт2
10б-іт2
10б-іт1
10в-іт1
10в-іт2
10г-іт2
10г-іт1
11г-іт1
11г-іт2
11в-іт2
11в-іт1
11б-іт1
11б-іт2
11а-іт2
11а-іт1
\.


--
-- Data for Name: class_and_students; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.class_and_students (class_name, students_login) FROM stdin;
11в	savinov16
11в	pyvovar16
11в	alekseev16
11в	bega16
8б	Poster23
10в	kostia17
10в	okunievskyi17
8б	Riabiche23
8б	Taraso23
10в	simonovandr
8б	Khanevy23
8в	Bedash23
8в	Herus23
8в	Dvirny23
8в	Kyryliu23
11в	bizura16
11в	bondarenkoo16
11в	gon4arenko16
11в	zdebka16
11в	lugovam16
8в	Korsun23
8в	Maznich23
8в	Mykhail23
11в	lugovaj16
11в	mal4enko16
11в	muraviov16
8в	Struko23
11в	tarasenko16
8в	Chernets23
10в	rachkevych17
10в	kovtun17
10б	borets17
10б	husieiev17
10б	kapustian17
10б	naveriani17
9а	krasnopol22
9а	zubish22
10б	senchenko
10б	bruiev17
10б	kolosok17
10б	nahornyi17
10б	churylovych17
10в	milevska17
10в	didenkodm
10в	stetsiuk17
9а	andrus18
9а	babenk18
9а	barash18
9а	danilo18
10б	ieremenko17
9а	lomono18
9а	mazur18
9а	majdan18
9а	nester18
9а	novoha18
9а	prijma18
9а	selezn18
11а	barash16
9а	hutorj18
9а	chobot18
11а	danilov16
11а	zhylin16
11а	kolisnyk16
11а	kostytska16
11а	kuzmishyna16
8а	Aleksie23
8а	Andria23
9г	Vvas
8а	Dmytru23
8а	Kornii23
8а	LishOle23
8а	Mariukhi23
8а	Moloka23
8а	Parashchi23
8а	Skalats23
8а	Khiuste23
8б	Varlam23
8б	Homeniu23
8б	Diubenk23
8б	Koben23
8б	Krynyts23
8б	Nikano23
8б	Pykhtin23
8б	Ryzhova23
8б	Savchen23
8б	Tuktam23
8в	Fachchin23
11в	pyhalova16
11в	plusnin16
11в	sapelnikov16
8в	Bizhan23
11в	su4kova16
11в	targonsky16
8в	Hlushko23
8в	Zabaria23
8в	Korine23
8в	Lypiats23
8в	Meshchan23
8в	Mushchenk23
8в	Shchurovs23
9а	antoniuk22
11а	levoshko16
11а	maznichenko16
11в	fal16
11в	sheredeko16
11в	skytsuk16
11в	tsymbalenko16
11в	kotliarova16
11а	mamichev16
10в	lishanska17
10в	Yakubyshyn
10в	vekha17
10в	shevel17
10в	siryk17
10в	nemiatyi17
10в	patraboi17
11а	mozol16
9а	chorno18
10б	bidasiuk
10б	bilous17
10б	zaiets17
10б	kysliuk17
10б	koval17
11а	pylypenko16
11в	voronin16
10а	bakun
10а	balatsuk17
10а	barabash17
10а	berezhanskyi17
10а	vasylievn17
10а	vasylieva17
10а	vasiuta17
10а	demenkov17
10а	zhytnik17
10а	kozoriezova17
10а	matsiukira
10а	molodtsova17
10а	naumov17
10а	pasechnykm
10а	prytup17
10а	ryzhenko17
10а	igorroik
11а	posternak16
10а	savchenko17
10а	samarina17
10а	solomakha17
10а	cezar17
10а	romanov21
9в	chorni18
9в	shychy18
9в	janush18
9в	1vahne18
9а	tvnnk16
9а	ishche18
11а	sachokv16
11а	sachoki16
10б	Bahrych
11а	slavska16
11а	stakhurska16
11а	chub16
11а	shapovalova16
11б	bovdui16
11б	Goldmayer
11б	vyshnevetska16
9а	vernk18
9а-інф2	pashev18
9а	rezn18
9а	kamns18
11б	akymenko16
9б	HarbuzS
9б	Karimov18
9б	zhirno18
8а	Borys23
8а	Bernad23
8а	Hudzen23
8а	Dudko23
8а	Kravche23
8а	Masnyi23
9а	chufar18
9а	shtand18
8а	Nehoda23
9а	kurchi18
9а	demche18
9а	gajovi18
9а	raetsk18
8а	Pustov23
8а	Sporik23
8а	Cherba23
9б	vojteh18
8б	Antono23
8б	Viniche23
9б	golova18
8б	Hromov23
8б	Zabolo23
8б	Kondra23t
8б	Makhtieie23
9б	zagoru18
9б	konber18
10б	ushakovv
10б	bulakh17
9б	kosenk18
9б	lavrov18
9б	macheh18
10б	vasylchenko17
9б	palama18
10б	vyhovskyi17
11а	agarkov16
10б	zhukovska17
10б	shevtsov17
11а	burliai16
10б	starunov17
10б	papizh17
10в	kurochkin17
10в	nahorna17
10в	vasyliev17
10в	zaitsev17
10в	iatsyk17
11а	zhmailo16
11а	shchurov16
11а	mosiichuk16
11а	tonkoshkur16
10б	malenko17
8б	Polovn23
8б	Runchev23
8б	Salan23
8б	Fenina23
8в	Avdieien23
8в	Bobesiu23
10в	romanchenko17
11в	arseniuk
10в	shynkarenko17
8в	Danchen23
11в	zaika16
8в	Ihnatu23
10в	ohorodnytskyi17
10в	iurchenkom17
10в	havrysh17
8в	Korol23
10в	muzychuk17
8в	Lykhoho23
10в	pliushchai17
10в	falko17
10в	borovyi17
8в	Mykola23
10в	riabichenko17
9б	semenk18
8в	Natal23
11а	stopchatyi16
8в	Tsiupko23
10б	klymenko17
10б	zaporozhets
10б	mordvynov17
11б	bohun16
11б	zadorozhnyi16
10б	linkan
10б	Lichutin
10в	skorobahatko17
11б	ivkoliz05
8а	Burache23
8а	Husieiev23
8а	Iholki23
8а	Krasno23
8а	LishYaro23
8а	Mysiv23
10б	tkachuk21
10а	kozyr17
10а	kyslenko17
10а	jarko143
10а	KucherV17
10а	IvanP
10а	petrenko
10а	iezhel17
9а	tsimba18
9в	horoh18
9в	bannij18
9в	verbov18
9в	granov18
9в	bagan18
9в	didish18
9в	dreger18
9в	zhmend18
9в	guman18
9в	zasoba18
9в	koval18
9в	kosten18
9в	kucher18
9в	lut18
9в	mahinj18
9в	mhnov18
9в	mudrag18
9в	ohten18
9в	poplav18
9в	potiomk18
9в	sahno18
9в	slsar18
9в	slch18
9в	timosh18
9в	topork18
9в	trojn18
9в	trotsk18
9в	shvora18
11б	mikliaiev16
11б	pavlov16
11б	pivenn16
11б	rudyi16
11б	sobolevskyi16
11б	tkachenko16
11б	khalapsus16
11б	tsukanov16
11б	ardashov16
11б	volodia2bondar
11б	Vysotskyy
11б	danyliuk16
11б	diachuk16
11б	kalinichenko16
11б	vlad
11б	redia16
11б	Rusinova
11б	samarets16
11б	sydorak16
11б	sizikova16
11б	sniehovskyi16
11б	diachenko
11г	cherniakova16
9б	ischuk18
9б	shkil18
9б	gorn18
9б	sichka18
9б	tomkiv18
11а	redina16
10б	mykhaelian17
9б	aleks18
9б	borise18
9б	galabu18
9б	dubas18
9б	zozulj18
9б	konone18
9б	KurochDan
9б	panfl18
9б	rubash18
9б	cherka18
9б	chubar18
11б	pivenx16
8а	Nemiata23
8а	Sazono23
8а	Stolbu23
8б	Akhmeto23
8б	Volove23
8б	Drobiaz23
8б	Kondra23c
8б	Kirieiev23
8б	Nyzhnyk23
8в	Tomashe23
9а	lazore18
10а	popova17
10а	stepanova17
10а	iurchenkof17
9в	karpen18
9в	rogovt18
10а-інф1	berezhanskyi17
10а-інф1	vasylievn17
10а-інф1	demenkov17
10а-інф1	zhytnik17
10а-інф1	kozyr17
10а-інф1	kozoriezova17
10а-інф1	molodtsova17
10а-інф1	IvanP
10а-інф1	petrenko
10а-інф1	ryzhenko17
10а-інф1	romanov21
10а-інф1	igorroik
10а-інф1	samarina17
10а-інф1	stepanova17
10а-інф1	cezar17
10а-інф1	iurchenkof17
10б-інф1	bilous17
10б-інф1	vyhovskyi17
10б-інф1	husieiev17
10б-інф1	zaiets17
10б-інф1	koval17
10б-інф1	kolosok17
10б-інф1	linkan
10б-інф1	Lichutin
10б-інф1	malenko17
10б-інф1	naveriani17
10б-інф1	nahornyi17
11в-інф2	alekseev16
10б-інф1	starunov17
10б-інф1	papizh17
10б-інф1	tkachuk21
10б-інф1	ushakovv
10б-інф1	churylovych17
11б-інф1	akymenko16
11б-інф1	ardashov16
11б-інф1	zadorozhnyi16
11б-інф1	vlad
11б-інф1	mikliaiev16
11б-інф1	pavlov16
11б-інф1	pivenx16
11б-інф1	pivenn16
11б-інф1	samarets16
11б-інф1	sydorak16
11б-інф1	sniehovskyi16
11б-інф1	sobolevskyi16
11б-інф1	tkachenko16
11б-інф1	khalapsus16
11б-інф1	tsukanov16
11в-інф1	pyvovar16
11в-інф1	plusnin16
11в-інф1	savinov16
11в-інф1	sapelnikov16
11в-інф1	skytsuk16
11в-інф1	su4kova16
11в-інф1	tarasenko16
11в-інф1	targonsky16
11в-інф1	fal16
11в-інф1	tsymbalenko16
11в-інф1	sheredeko16
11в-інф2	arseniuk
11в-інф2	bega16
11в-інф2	bondarenkoo16
11в-інф2	bizura16
11в-інф2	voronin16
11в-інф2	gon4arenko16
11в-інф2	zaika16
11в-інф2	zdebka16
11в-інф2	lugovam16
11в-інф2	lugovaj16
11в-інф2	mal4enko16
11в-інф2	muraviov16
11в-інф2	pyhalova16
11в-інф2	kotliarova16
11б-інф2	bovdui16
11б-інф2	bohun16
11б-інф2	volodia2bondar
11б-інф2	Vysotskyy
11б-інф2	vyshnevetska16
11б-інф2	danyliuk16
11б-інф2	diachuk16
11б-інф2	ivkoliz05
11б-інф2	kalinichenko16
11б-інф2	redia16
11б-інф2	rudyi16
11б-інф2	Rusinova
11б-інф2	synytsia16
11б-інф2	sizikova16
11б-інф2	Goldmayer
11б-інф2	diachenko
11а-інф1	agarkov16
11а-інф1	barash16
11а-інф1	burliai16
11а-інф1	danilov16
11а-інф2	zhylin16
11а-інф1	zhmailo16
11а-інф1	zabarianska16
11а-інф1	kolisnyk16
11а-інф2	kostytska16
11а-інф1	levoshko16
11а-інф1	maznichenko16
11а-інф2	mamichev16
11а-інф1	mozol16
11а-інф2	shchurov16
11а-інф2	mosiichuk16
11а-інф2	pylypenko16
11а-інф2	posternak16
11а-інф2	sachokv16
11а-інф2	sachoki16
11а-інф1	slavska16
11а-інф1	stakhurska16
11а-інф1	GalinaFox
11а-інф2	chub16
11а-інф2	shapovalova16
10б-інф2	Bahrych
10б-інф2	bidasiuk
10б-інф2	borets17
10б-інф2	bruiev17
10б-інф2	bulakh17
10б-інф2	vasylchenko17
10б-інф2	zhukovska17
10б-інф2	zaporozhets
10б-інф2	kapustian17
10б-інф2	kysliuk17
10б-інф2	klymenko17
10б-інф2	mykhaelian17
10б-інф2	mordvynov17
10б-інф2	senchenko
10б-інф2	shevtsov17
10б-інф2	ieremenko17
10б-фзк1	Bahrych
10б-фзк1	bilous17
10б-фзк1	bruiev17
10б-фзк1	bulakh17
11а-інф1	tonkoshkur16
11а-інф1	redina16
10б-фзк1	vyhovskyi17
10б-фзк1	husieiev17
10б-фзк1	zaiets17
10б-фзк1	klymenko17
10б-фзк1	koval17
10б-фзк1	kolosok17
10б-фзк1	Lichutin
10б-фзк1	malenko17
10б-фзк1	mordvynov17
10б-фзк1	naveriani17
10б-фзк1	nahornyi17
10б-фзк1	papizh17
10б-фзк1	senchenko
10б-фзк1	starunov17
10б-фзк1	ushakovv
10б-фзк1	churylovych17
10б-фзк1	shevtsov17
10б-фзк2	bidasiuk
10б-фзк2	borets17
10б-фзк2	vasylchenko17
10б-фзк2	ieremenko17
10б-фзк2	zhukovska17
10б-фзк2	zaporozhets
10б-фзк2	kapustian17
10б-фзк2	kysliuk17
10б-фзк2	linkan
10б-фзк2	mykhaelian17
10б-фзк2	tkachuk21
8в-інф1	Avdieien23
8в-інф1	Bedash23
8в-інф1	Bobesiu23
8в-інф1	Bizhan23
8в-інф1	Herus23
8в-інф1	Hlushko23
8в-інф1	Danchen23
8в-інф1	Dvirny23
8в-інф1	Ihnatu23
8в-інф1	Kyryliu23
8в-інф1	Korine23
8в-інф1	Korol23
8в-інф1	Korsun23
8в-інф1	Meshchan23
8в-інф1	Tsiupko23
8в-інф2	Zabaria23
8в-інф2	Lypiats23
8в-інф2	Lykhoho23
8в-інф2	Maznich23
8в-інф2	Mykola23
8в-інф2	Mykhail23
8в-інф2	Mushchenk23
8в-інф2	Natal23
8в-інф2	Tomashe23
8в-інф2	Struko23
8в-інф2	Fachchin23
8в-інф2	Chernets23
8в-інф2	Shchurovs23
8в	palamU20
8в-інф2	palamU20
8в	tarannS20
8в-інф2	tarannS20
10в	komarovM20
10в-інф1	komarovM20
9в-анг1	bagan18
9в-анг1	horoh18
9в-анг1	bannij18
9в-анг1	verbov18
9в-анг1	granov18
9в-анг1	guman18
9в-анг1	didish18
9в-анг1	dreger18
9в-анг1	zhmend18
9в-анг1	zasoba18
9в-анг1	karpen18
9в-анг1	koval18
9в-анг1	kosten18
9в-анг1	kucher18
9в-анг1	chorni18
9в-анг1	mahinj18
9в-анг1	mhnov18
9в-анг2	1vahne18
9в-анг2	lut18
9в-анг2	mudrag18
9в-анг2	ohten18
9в-анг2	poplav18
9в-анг2	potiomk18
9в-анг2	rogovt18
9в-анг2	sahno18
9в-анг2	slch18
9в-анг2	slsar18
9в-анг2	timosh18
9в-анг2	topork18
9в-анг2	trojn18
9в-анг2	trotsk18
9в-анг2	shvora18
9в-анг2	shychy18
9в-анг2	janush18
9в-інф1	bagan18
9в-інф1	bannij18
9в-інф1	horoh18
9в-інф1	guman18
9в-інф1	1vahne18
9в-інф1	karpen18
9в-інф1	chorni18
9в-інф1	mhnov18
9в-інф1	ohten18
9в-інф1	potiomk18
9в-інф1	rogovt18
9в-інф1	slch18
9в-інф1	timosh18
9в-інф1	trotsk18
9в-інф1	shychy18
9в-інф1	janush18
9в-інф1	lut18
10а-інф2	bakun
10а-інф2	balatsuk17
10а-інф2	barabash17
10а-інф2	vasiuta17
10а-інф2	iezhel17
10а-інф2	kyslenko17
10а-інф2	KucherV17
10а-інф2	matsiukira
10а-інф2	naumov17
10а-інф2	pasechnykm
10а-інф2	popova17
10а-інф2	prytup17
10а-інф2	savchenko17
10а-інф2	solomakha17
10а-інф2	vasylieva17
10а-інф2	jarko143
10а-фзк2	bakun
10а-фзк1	balatsuk17
10а-фзк1	barabash17
10а-фзк1	berezhanskyi17
10а-фзк1	vasylievn17
10а-фзк2	vasylieva17
10а-фзк1	vasiuta17
10а-фзк1	demenkov17
10а-фзк1	zhytnik17
10а-фзк2	kyslenko17
10а-фзк1	kozyr17
10а-фзк2	kozoriezova17
10а-фзк1	KucherV17
10а-фзк2	matsiukira
10а-фзк2	molodtsova17
10а-фзк1	naumov17
10а-фзк1	jarko143
10а-фзк1	pasechnykm
10а-фзк1	IvanP
10а-фзк1	petrenko
10а-фзк2	popova17
10а-фзк1	prytup17
10а-фзк1	ryzhenko17
10а-фзк1	romanov21
10а-фзк1	igorroik
10а-фзк1	savchenko17
10а-фзк2	samarina17
10а-фзк1	solomakha17
10а-фзк1	cezar17
10а-фзк2	stepanova17
10а-фзк2	iurchenkof17
10а-фзк1	iezhel17
11а	zabarianska16
11а-інф1	stopchatyi16
11а	strechin16
11б-анг1	akymenko16
11б-анг1	bovdui16
11б-анг1	bohun16
11б-анг1	zadorozhnyi16
11б-анг1	ivkoliz05
11б-анг1	mikliaiev16
11б-анг1	pavlov16
11б-анг1	pivenn16
11б-анг1	rudyi16
11б-анг1	sobolevskyi16
11б-анг1	Goldmayer
11б-анг1	khalapsus16
11б-анг1	tsukanov16
11б-анг2	volodia2bondar
11б-анг2	Vysotskyy
11б-анг2	vyshnevetska16
11б-анг2	danyliuk16
11б-анг2	diachuk16
11б-анг2	kalinichenko16
11б-анг2	vlad
11б-анг2	redia16
11б-анг2	samarets16
11б-анг2	sydorak16
11б-анг2	synytsia16
11б-анг2	sizikova16
11б-анг2	sniehovskyi16
11б-анг2	diachenko
11б-іт1	bohun16
11б-іт1	Vysotskyy
11б-іт1	vyshnevetska16
11б-іт1	danyliuk16
11в-анг1	bega16
11в-анг1	bizura16
11в-анг1	voronin16
11в-анг1	gon4arenko16
11в-анг1	zaika16
11в-анг1	kotliarova16
11в-анг1	lugovam16
11в-анг1	lugovaj16
11в-анг1	mal4enko16
11в-анг1	muraviov16
11в-анг1	pyhalova16
11в-анг1	savinov16
11в-анг1	sheredeko16
11в-анг2	alekseev16
11в-анг2	arseniuk
11в-анг2	bondarenkoo16
11в-анг2	zdebka16
11в-анг2	pyvovar16
11в-анг2	plusnin16
11в-анг2	sapelnikov16
11в-анг2	skytsuk16
11в-анг2	su4kova16
11в-анг2	tarasenko16
11в-анг2	targonsky16
11в-анг2	fal16
11в-анг2	tsymbalenko16
11в-іт1	alekseev16
11в-іт2	arseniuk
11в-іт1	bega16
11в-іт1	bizura16
11в-іт1	bondarenkoo16
11в-іт1	voronin16
11в-іт1	gon4arenko16
11в-іт1	zaika16
11в-іт1	zdebka16
11в-іт1	kotliarova16
11в-іт1	lugovaj16
11в-іт1	lugovam16
11в-іт1	mal4enko16
11в-іт1	muraviov16
11в-іт1	pyhalova16
11в-іт1	sapelnikov16
11в-іт1	savinov16
11в-іт1	su4kova16
11в-іт2	pyvovar16
11в-іт2	plusnin16
11в-іт2	skytsuk16
11в-іт2	tarasenko16
11в-іт2	targonsky16
11в-іт2	fal16
11в-іт2	tsymbalenko16
11в-іт2	sheredeko16
10а-іт2	molodtsova17
10а-іт2	petrenko
10а-іт2	popova17
10а-іт2	prytup17
10а-іт2	ryzhenko17
10а-іт2	igorroik
10а-іт2	savchenko17
10а-іт2	samarina17
10а-іт2	kozoriezova17
10а-іт2	jarko143
10а-іт2	IvanP
10а-іт2	solomakha17
10а-іт2	stepanova17
10а-іт2	cezar17
10а-іт2	iurchenkof17
10а-іт2	vasylievn17
10а-іт2	zhytnik17
10а-іт1	bakun
10а-іт1	balatsuk17
10а-іт1	barabash17
10а-іт1	berezhanskyi17
10а-іт1	vasylieva17
10а-іт1	vasiuta17
10а-іт1	demenkov17
10а-іт1	iezhel17
10а-іт1	kyslenko17
10а-іт1	kozyr17
10а-іт1	KucherV17
10а-іт1	matsiukira
10а-іт1	pasechnykm
10а-іт1	romanov21
10а-іт1	naumov17
11б	synytsia16
11б-анг1	pivenx16
11б-анг1	tkachenko16
11б-анг1	Rusinova
11б-анг1	ardashov16
10в-фзк1	borovyi17
10в-фзк1	vasyliev17
10в-фзк1	vekha17
10в-фзк1	havrysh17
10в-фзк1	didenkodm
10в-фзк1	zaitsev17
10в-фзк2	kovtun17
10в-фзк1	komarovM20
10в-фзк2	kostia17
10в-фзк1	kurochkin17
10в-фзк2	lishanska17
10в-фзк1	muzychuk17
10в-фзк2	milevska17
10в-фзк2	nahorna17
10в-фзк1	nemiatyi17
10в-фзк1	ohorodnytskyi17
10в-фзк1	okunievskyi17
10в-фзк1	patraboi17
10в-фзк2	pliushchai17
10в-фзк2	rachkevych17
10в-фзк2	romanchenko17
10в-фзк2	riabichenko17
10в-фзк1	skorobahatko17
10в-фзк1	stetsiuk17
10в-фзк1	simonovandr
10в-фзк1	siryk17
10в-фзк1	falko17
10в-фзк1	shevel17
10в-фзк2	shynkarenko17
10в-фзк1	iurchenkom17
10в-фзк1	iatsyk17
11а-фзк1	agarkov16
11а-фзк1	barash16
11а-фзк1	burliai16
11а-фзк1	danilov16
11а-фзк1	zhylin16
11а-фзк1	zhmailo16
11а-фзк2	zabarianska16
11а-фзк1	kolisnyk16
11а-фзк2	kostytska16
11а-фзк2	kuzmishyna16
11а-фзк1	levoshko16
11а-фзк1	maznichenko16
11а-фзк1	mamichev16
11а-фзк1	mozol16
11а-фзк1	shchurov16
11а-фзк1	mosiichuk16
11а-фзк1	pylypenko16
11а-фзк2	posternak16
11а-фзк1	sachokv16
11а-фзк1	sachoki16
11а-фзк2	slavska16
11а-фзк2	stakhurska16
11а-фзк1	stopchatyi16
11а-фзк2	strechin16
11а-фзк2	tonkoshkur16
11а-фзк1	chub16
11а-фзк2	shapovalova16
11б-фзк1	akymenko16
11б-фзк1	ardashov16
11б-фзк2	bovdui16
11б-фзк1	bohun16
11б-фзк1	volodia2bondar
11б-фзк1	Vysotskyy
11б-фзк2	vyshnevetska16
11б-фзк2	danyliuk16
11б-фзк1	diachenko
11б-фзк1	diachuk16
11б-фзк1	zadorozhnyi16
11б-фзк2	kalinichenko16
11б-фзк2	ivkoliz05
11б-фзк1	vlad
11б-фзк1	mikliaiev16
11б-фзк1	pavlov16
11б-фзк2	pivenx16
11б-фзк2	pivenn16
11б-фзк1	redia16
11б-фзк1	rudyi16
11б-фзк2	Rusinova
11б-фзк1	samarets16
11б-фзк1	sydorak16
11б-фзк2	synytsia16
11б-фзк2	sizikova16
11б-фзк1	sniehovskyi16
11б-фзк1	sobolevskyi16
11б-фзк1	Goldmayer
11б-фзк1	tkachenko16
11б-фзк1	khalapsus16
11б-фзк1	tsukanov16
11в-фзк1	alekseev16
11в-фзк1	arseniuk
11в-фзк1	bega16
11в-фзк2	bizura16
11в-фзк1	bondarenkoo16
11в-фзк1	voronin16
11в-фзк1	gon4arenko16
11в-фзк1	zaika16
11в-фзк2	zdebka16
11в-фзк2	kotliarova16
11в-фзк2	lugovam16
11в-фзк2	lugovaj16
11в-фзк1	mal4enko16
11в-фзк1	muraviov16
11в-фзк1	pyvovar16
11в-фзк2	pyhalova16
11в-фзк1	plusnin16
11в-фзк1	savinov16
11в-фзк1	sapelnikov16
11в-фзк1	skytsuk16
11в-фзк2	su4kova16
11в-фзк1	tarasenko16
11в-фзк1	targonsky16
11в-фзк1	fal16
11в-фзк1	tsymbalenko16
11в-фзк1	sheredeko16
9а-інф2	vernk18
9а-інф2	barash18
9а-інф2	ishche18
9а-інф2	lazore18
9а-інф2	nester18
9а	pashev18
9а-інф2	prijma18
9а-інф2	rezn18
9а-інф2	selezn18
9а-інф2	tvnnk16
9а-інф2	hutorj18
9а-інф2	raetsk18
9а-інф2	tsimba18
9а-інф2	shtand18
9а-інф2	chobot18
9а-інф1	andrus18
9а-інф1	antoniuk22
9а-інф1	babenk18
9а-інф1	gajovi18
9а-інф1	danilo18
9а-інф1	demche18
9а-інф1	kamns18
9а-інф1	krasnopol22
9а-інф1	kurchi18
9а-інф1	lomono18
9а-інф1	mazur18
9а-інф1	majdan18
9а-інф1	novoha18
9а-інф1	chorno18
9а-інф1	zubish22
9в-інф2	granov18
11а-фзк2	redina16
10в-фзк1	Yakubyshyn
9в-інф2	didish18
9в-інф2	dreger18
9в-інф2	zhmend18
9в-інф2	zasoba18
9в-інф2	koval18
9в-інф2	kosten18
9в-інф2	kucher18
9в-інф2	poplav18
9в-інф2	sahno18
9в-інф2	slsar18
9в-інф2	topork18
9в-інф2	trojn18
9в-інф2	shvora18
9в-інф2	verbov18
9в-інф2	mahinj18
9в-інф2	mudrag18
8б-інф1	Zabolo23
8б-інф1	Nyzhnyk23
8б-інф1	Nikano23
8б-інф1	Pykhtin23
8б-інф1	Polovn23
8б-інф1	Poster23
8б-інф1	Ryzhova23
8б-інф1	Runchev23
8б-інф1	Riabiche23
8б-інф1	Savchen23
8б-інф1	Salan23
8б-інф1	Taraso23
8б-інф1	Tuktam23
8б-інф1	Fenina23
8б-інф1	Khanevy23
8б-інф1	Makhtieie23
8б-інф2	Antono23
8б-інф2	Akhmeto23
8б-інф2	Varlam23
8б-інф2	Viniche23
8б-інф2	Volove23
8б-інф2	Homeniu23
8б-інф2	Hromov23
8б-інф2	Drobiaz23
8б-інф2	Diubenk23
8б-інф2	Kirieiev23
8б-інф2	Koben23
8б-інф2	Kondra23t
8б-інф2	Kondra23c
8б-інф2	Krynyts23
10в-інф1	borovyi17
10в-інф1	vasyliev17
10в-інф1	havrysh17
10в-інф1	zaitsev17
10в-інф1	kovtun17
10в-інф1	muzychuk17
10в-інф1	nemiatyi17
10в-інф1	patraboi17
10в-інф1	pliushchai17
10в-інф1	riabichenko17
10в-інф1	siryk17
10в-інф1	stetsiuk17
10в-інф1	falko17
10в-інф1	shevel17
10в-інф1	skorobahatko17
10в-інф2	vekha17
10в-інф2	didenkodm
10в-інф2	kostia17
10в-інф2	kurochkin17
10в-інф2	lishanska17
10в-інф2	milevska17
10в-інф2	nahorna17
10в-інф2	ohorodnytskyi17
10в-інф2	okunievskyi17
10в-інф2	rachkevych17
10в-інф2	romanchenko17
10в-інф2	simonovandr
10в-інф2	shynkarenko17
10в-інф2	iurchenkom17
10в-інф2	iatsyk17
8а-інф1	Aleksie23
8а-інф1	Andria23
8а-інф1	Borys23
8а-інф1	Burache23
8а-інф1	Hudzen23
8а-інф1	Husieiev23
8а-інф1	Dmytru23
8а-інф1	Dudko23
8а-інф1	Iholki23
8а-інф1	Kornii23
8а-інф1	Kravche23
8а-інф1	Krasno23
8а-інф1	LishOle23
8а-інф1	LishYaro23
8а-інф2	Mariukhi23
8а	knopG19
8а-інф1	knopG19
8а-інф2	Masnyi23
8а-інф2	Mysiv23
8а-інф2	Sporik23
8а-інф2	Moloka23
8а-інф2	Parashchi23
8а-інф2	Stolbu23
8б-інф2	Sazono23
8а-інф2	Nehoda23
8а-інф2	Skalats23
8а-інф2	Pustov23
8а-інф2	Nemiata23
8а-інф2	Khiuste23
8а-інф2	Cherba23
8а-інф2	Bernad23
9б-інф1	aleks18
9б-інф1	vojteh18
9б-інф1	galabu18
9б-інф1	HarbuzS
9б	erik18
9б-інф1	erik18
9б-інф1	zhirno18
9б-інф1	zagoru18
9б-інф1	zozulj18
9б-інф1	ischuk18
9б-інф1	konone18
9б-інф1	lavrov18
9б-інф1	macheh18
9б-інф1	panfl18
9а-інф1	cherka18
9б-інф1	shkil18
9б-інф1	dubas18
9б-інф1	prokopS18
9б-інф2	borise18
9б-інф2	gorn18
9б-інф2	konber18
9б-інф2	kosenk18
9б-інф2	palama18
9б-інф2	semenk18
9б-інф2	sichka18
9б-інф2	tomkiv18
9б-інф2	chubar18
9б-інф2	KurochDan
9б-інф2	golova18
9б-інф2	rubash18
9б-іт1	aleks18
9б-іт1	borise18
9б-іт1	vojteh18
9б-іт1	galabu18
9б-іт1	HarbuzS
9б-іт1	golova18
9б-іт1	gorn18
9б-іт1	dubas18
9б-іт1	erik18
9б-іт1	zhirno18
9б-іт1	zagoru18
9б-іт1	ischuk18
9б-іт1	konber18
9б-інф2	Karimov18
9б	prokopS18
10в-інф1	Yakubyshyn
9б-іт1	zozulj18
9б-іт2	konone18
9б-іт2	kosenk18
9б-іт2	KurochDan
9б-іт2	lavrov18
9б-іт2	macheh18
9б-іт2	palama18
9б-іт2	panfl18
9б-іт2	rubash18
9б-іт2	semenk18
9б-іт2	sichka18
9б-іт2	tomkiv18
9б-іт2	cherka18
9б-іт2	chubar18
9б-іт2	shkil18
9б-іт2	prokopS18
9б-іт1	Karimov18
\.


--
-- Data for Name: journal; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.journal (id, comment, date, mark, present, show_date, subject, topic, work, stud_login, class_name) FROM stdin;
\.


--
-- Data for Name: move; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.move (login, in_date, in_order, in_comment, out_date, out_comment, out_order) FROM stdin;
\.


--
-- Data for Name: prepod; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.prepod (schedule_id, subject, login) FROM stdin;
1	Алгебра 9кл	lconst
2	Алгебра 9кл	kua
4	Фізика 9кл	pvv
5	Геометрія 9кл	sio
6	Хімія 9кл	mns
8	Біологія 9кл	kop
10	Геометрія 9кл	kua
12	Фізичний практикум 9кл	goy
14	Алгебра 10кл	siv
15	Біологія 10кл	kop
17	Хімія 10кл	mns
22	Геометрія 10кл	siv
23	Фізика 10кл	pvv
24	Фізика 9кл	klm
25	Фізика 10кл	svm
26	Біологія 10кл	yni
30	Українська мова 10кл	blp
31	Українська література 10кл	blp
32	Українська мова 10кл	fekla
33	Українська література 10кл	fekla
34	Зарубіжна література 9кл	rli
35	Художня культура 9кл	rli
36	Зарубіжна література 10кл	rli
37	Художня культура 10кл	rli
39	Фізичний практикум 10кл	goy
41	Алгебра 8кл	basovds
42	Геометрія 8кл	basovds
44	Геометрія 10кл	basovds
45	Алгебра 8кл	bokhonovatu
46	Геометрія 8кл	bokhonovatu
3	Фізична культура 9кл	rtm
49	Фізична культура 8кл	bokhonovatu
50	Зарубіжна література 8кл	rli
47	Українська мова 8кл	med
48	Українська література 8кл	med
124	Українська мова 10кл	med
56	Географія 8кл	rustamovavp
57	Географія 9кл	rustamovavp
58	Географія 10кл	rustamovavp
59	Географія 11кл	rustamovavp
60	Біологія 8кл	yni
62	Біологія 11кл	yni
125	Українська література 10кл	med
64	Хімія 8кл	mns
67	Алгебра 8кл	sahaidaktv
68	Геометрія 8кл	sahaidaktv
69	Алгебра 9кл	morozdo
70	Геометрія 9кл	morozdo
75	Фізика 10кл	zinchukvm
76	Алгебра 10кл	sio
77	Геометрія 10кл	sio
78	Українська мова 8кл	blp
79	Українська література 8кл	blp
16	Інформатика 9кл	ltv
80	Українська мова 9кл	fekla
81	Українська література 9кл	fekla
85	Англійська мова 8кл	makhrovaov
86	Англійська мова 9кл	makhrovaov
87	Зарубіжна література 11кл	rli
88	Основи здоров'я 9кл	kop
90	Фізична культура 9кл	khan
94	Алгебра 11кл	vynny
95	Геометрія 11кл	vynny
99	Фізичний практикум 11кл	levtik
100	Фізичний практикум 11кл	zinchukvm
101	Фізичний практикум 10кл	zinchukvm
104	Інформатика 8кл	fla
106	Основи здоров'я 8кл	yni
107	Інформатика 8кл	ltv
108	Фізична культура 8кл	rtm
118	Фізика 11кл	rozenwine
120	Фізика 10кл	klm
102	Фізика 8кл	yaroslav
103	Фізика 11кл	yaroslav
123	Правознавство 9кл	top
126	Англійська мова 10кл	murynskavv
127	Інформатика 10кл	fla
131	Інформатика 10кл	ltv
138	Історія України 10кл	top
139	Всесвітня історія 10кл	top
142	Алгебра 11кл	basovds
143	Алгебра 9кл	basovds
144	Геометрія 11кл	basovds
145	Алгебра 10кл	basovds
146	Геометрія 9кл	basovds
147	Алгебра 8кл	vynny
148	Геометрія 8кл	vynny
149	Алгебра 9кл	vynny
150	Геометрія 9кл	vynny
151	Алгебра 8кл	kua
152	Алгебра 10кл	kua
153	Геометрія 10кл	kua
154	Алгебра 11кл	siv
155	Алгебра 9кл	siv
156	Геометрія 11кл	siv
157	Геометрія 9кл	siv
89	Інформатика 9кл	IrinaSklyar
105	Інформатика 8кл	IrinaSklyar
132	Інфтехнології 10кл	fla
135	Інфтехнології 10кл	ltv
109	Інфтехнології 8кл	fla
110	Інфтехнології 8кл	IrinaSklyar
160	Алгебра 10кл	lconst
161	Фізика 11кл	svm
163	Біологія 11кл	kop
164	Основи здоров'я 8кл	kop
165	Всесвітня історія 11кл	top
166	Історія України 11кл	top
167	Економіка 11кл	zubchenkovp
172	Фізична культура 9кл	bokhonovatu
174	Фізика 8кл	kolodkars
175	Правознавство 10кл	top
176	Фізика 9кл	yaroslav
177	Фізика 9кл	teryu
178	Українська мова 9кл	blp
179	Українська література 9кл	blp
180	Українська мова 11кл	blp
181	Українська література 11кл	blp
197	Алгебра 11кл	lconst
198	Фізика 11кл	pvv
199	Алгебра 8кл	siv
200	Геометрія 8кл	siv
201	Астрономія 11кл	mkyryliuk
202	Фізика 8кл	mkyryliuk
203	Фізика 8кл	zinchukvm
204	Фізика 9кл	kolodkars
205	Всесвітня історія 9кл	top
206	Історія України 9кл	top
207	Інформатика 11кл	ltv
209	Алгебра 8кл	hip
210	Геометрія 8кл	hip
211	Хімія 11кл	mns
212	Українська мова 8кл	fml
213	Українська література 8кл	fml
214	Українська мова 9кл	fml
215	Фізичний практикум 10кл	levtik
216	Українська література 9кл	fml
217	Фізика 8кл	vborysiuk
218	Фізика 8кл	rozenwine
220	Англійська мова 8кл	vov
221	Англійська мова 9кл	vov
222	Фізика 10кл	kolodkars
223	Біологія 8кл	kop
224	Інформатика 11кл	fla
225	Алгебра 10кл	mmoroz
226	Геометрія 10кл	mmoroz
227	Алгебра 9кл	sio
228	Алгебра 11кл	sio
229	Хімія 10кл	bns
230	Хімія 11кл	bns
231	Всесвітня історія 8кл	peo
232	Історія України 8кл	peo
233	Правознавство 9кл	peo
234	Громадянська освіта 10кл	peo
235	Алгебра 9кл	sahaidaktv
236	Геометрія 9кл	sahaidaktv
237	Фізика 11кл	teryu
242	Фізична культура 10кл	rtm
243	Фізична культура 10кл	khan
244	Українська мова 11кл	fekla
245	Українська література 11кл	fekla
246	Українська література 9кл	med
247	Українська мова 9кл	med
248	Українська література 11кл	med
249	Українська мова 11кл	med
250	Мистецтво 8кл	rli
251	Мистецтво 9кл	rli
252	Англійська мова 10кл	makhrovaov
253	Англійська мова 11кл	makhrovaov
82	Англійська мова 9кл	oip48
83	Англійська мова 10кл	oip48
84	Англійська мова 11кл	oip48
257	Фізична культура 9кл	aop1993
258	Захист Вітчизни 10кл	rat
259	Захист Вітчизни 11кл	rat
260	Захист Вітчизни 10кл	mli
261	Захист Вітчизни 11кл	mli
262	Фізика 9кл	zinchukvm
263	Інформатика 9кл	vea
264	Всесвітня історія 11кл	ofursova
265	Історія України 11кл	ofursova
266	Всесвітня історія 9кл	ofursova
267	Історія України 9кл	ofursova
268	Фізична культура 11кл	rtm
269	Фізична культура 11кл	khan
270	Фізична культура 8кл	khan
272	Хімія практ 10кл	bns
273	Біологія практ 10кл	yni
129	Інформатика 10кл	IrinaSklyar
238	Інформатика 11кл	IrinaSklyar
240	Інфтехнології 10кл	vea
241	Інфтехнології 10кл	rnv
133	Інфтехнології 10кл	IrinaSklyar
219	Інфтехнології 9кл	vea
271	Інфтехнології 9кл	rnv
254	Інфтехнології 8кл	ltv
255	Інфтехнології 11кл	rnv
256	Інфтехнології 11кл	vea
239	Інфтехнології 11кл	IrinaSklyar
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.roles (role) FROM stdin;
stud
admin
secretar
clmaster
prepod
\.


--
-- Data for Name: schedule_and_class; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.schedule_and_class (schedules_id, class_name) FROM stdin;
226	10в
100	11а-зхв1
100	11в
45	8а
46	8а
205	9а
206	9а
139	10а
139	10б
139	10в
138	10а
138	10б
138	10в
209	8в
210	8в
6	9а
6	9б
6	9в
64	8а
64	8б
64	8в
211	11а
211	11б
26	10а
26	10б
26	10в
62	11а
62	11б
62	11в
212	8а
212	8б
213	8а
213	8б
142	11а
144	11а
144	11б
147	8б
148	8б
12	9а
12	9б
12	9в
103	11а
201	11а
201	11б
201	11в
152	10б
153	10а
153	10б
215	10а
160	10а
4	9б
155	9а
157	9а
154	11в
156	11в
214	9а
216	9а
217	8в
202	8а
218	8б
24	9а
220	8а
220	8б
79	8в
78	8в
179	9б
178	9б
30	10а
30	10б
225	10в
31	10а
31	10б
222	10а
227	9в
5	9в
8	9а
8	9б
8	9в
88	9а
88	9б
88	9в
223	8а
223	8б
223	8в
164	8а
164	8б
164	8в
228	11б
229	10а
127	10а-інф1
127	10б-інф1
229	10б
229	10в
224	11б-інф1
224	11в-інф1
161	11б
230	11в
232	8а
232	8б
232	8в
231	8а
231	8б
231	8в
233	9а
233	9б
233	9в
234	10а
234	10б
234	10в
235	9б
236	9б
237	11в
238	11а-інф1
207	11а-інф2
207	11б-інф2
207	11в-інф2
245	11б
32	10в-анг1
246	9в
247	9в
125	10в
124	10в-анг2
248	11а
248	11в
50	8а
50	8б
50	8в
34	9а
34	9б
34	9в
36	10а
36	10б
36	10в
87	11а
87	11б
87	11в
250	8а
250	8б
250	8в
251	9а
251	9б
251	9в
85	8в
221	9а
221	9б
221	9в-анг1
86	9в-анг2
131	10а-інф2
131	10б-інф2
108	8а
108	8в
23	10б
23	10в
252	10а
252	10в-анг2
83	10б
83	10в-анг1
253	11а
253	11б-анг2
84	11б-анг1
84	11в
257	9а
257	9б
257	9в
249	11а
249	11в-анг1
244	11б
244	11в-анг2
256	11б-іт2
256	11в-іт1
255	11б-іт1
255	11в-іт2
241	10а-іт2
241	10б-інф2
258	10а-фзк1
258	10б-фзк1
258	10в-фзк1
259	11а-фзк1
259	11б-фзк1
259	11в-фзк1
260	10а-фзк2
260	10б-фзк2
260	10в-фзк2
261	11а-фзк2
261	11б-фзк2
261	11в-фзк2
262	9в
101	10б
264	11а
264	11б
264	11в
265	11а
265	11б
265	11в
266	9б
266	9в
267	9б
267	9в
56	8а
56	8б
56	8в
57	9а
57	9б
57	9в
58	10а
58	10б
58	10в
59	11а
59	11б
59	11в
268	11а-фзк2
268	11б-фзк2
268	11в-фзк2
269	11а-фзк1
269	11б-фзк1
269	11в-фзк1
270	8б
263	9а-інф1
263	9в-інф2
242	10а-фзк2
242	10б-фзк2
242	10в-фзк2
129	10в-інф1
129	10в-інф2
272	10в-інф2
273	10в-інф2
133	10в-інф1
240	10а-іт1
240	10б-інф1
240	10в-інф2
254	8а-інф1
254	8б-інф2
254	8в-інф1
107	8а-інф1
107	8б-інф2
107	8в-інф1
110	8а-інф2
110	8б-інф1
110	8в-інф2
105	8а-інф2
105	8б-інф1
105	8в-інф2
89	9а-інф2
89	9б-інф1
89	9в-інф1
16	9б-інф2
271	9а-інф2
271	9б-іт1
271	9в-інф1
219	9а-інф1
219	9б
219	9б-іт2
219	9в-інф2
243	10а-фзк1
243	10б-фзк1
243	10в-фзк1
\.


--
-- Data for Name: spr_auth; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.spr_auth (login, authority) FROM stdin;
admin	admin
director	director
\.


--
-- Data for Name: spr_users; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.spr_users (login, password, enabled, first_name, second_name, third_name) FROM stdin;
admin	nhjtobyf	t	A	B	C
director	gj,tlbntkm	t	Л	Н	Н
\.


--
-- Data for Name: subject_list; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.subject_list (subject) FROM stdin;
Алгебра 9кл
Алгебра 10кл
Біологія 10кл
Хімія 10кл
Геометрія 10кл
Фізика 10кл
Українська мова 9кл
Українська мова 10кл
Українська література 9кл
Українська література 10кл
Зарубіжна література 9кл
Зарубіжна література 10кл
Художня культура 9кл
Фізика 9кл
Геометрія 9кл
Хімія 9кл
Інформатика 9кл
Біологія 9кл
Фізичний практикум 9кл
Історія України 9кл
Всесвітня історія 9кл
Художня культура 10кл
Фізичний практикум 10кл
Алгебра 8кл
Геометрія 8кл
Українська мова 8кл
Українська література 8кл
Українська мова 11кл
Українська література 11кл
Фізична культура 9кл
Фізична культура 8кл
Фізична культура 10кл
Фізична культура 11кл
Зарубіжна література 8кл
Зарубіжна література 11кл
Фізика 11кл
Фізика 8кл
Історія України 8кл
Історія України 10кл
Історія України 11кл
Всесвітня історія 8кл
Всесвітня історія 10кл
Всесвітня історія 11кл
Географія 8кл
Географія 9кл
Географія 10кл
Географія 11кл
Біологія 8кл
Біологія 11кл
Хімія 8кл
Хімія 11кл
Музичне мистецтво 8кл
Англійська мова 8кл
Англійська мова 9кл
Англійська мова 10кл
Англійська мова 11кл
Основи здоров'я 8кл
Основи здоров'я 9кл
КВ економіка 11кл
КВ українська 11кл
КВ хімія 11 кл
КВ біологія 11кл
КВ фізика 11 кл
Алгебра 11кл
Геометрія 11кл
Людина і Світ
Фізичний практикум 11кл
Інформатика 8кл
Інформатика 10кл
Інформатика 11кл
Правознавство 9кл
Астрономія 11кл
Економіка 11кл
Правознавство 10кл
Громадянська освіта 10кл
Мистецтво 8кл
Мистецтво 9кл
Захист Вітчизни 10кл
Захист Вітчизни 11кл
Біологія практ 10кл
Хімія практ 10кл
Інфтехнології 10кл
Інфтехнології 9кл
Інфтехнології 8кл
Інфтехнології 11кл
\.


--
-- Data for Name: topics; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.topics (sched4t_id, topic) FROM stdin;
3	Футбол
3	Подтягивания
3	Волейбол
3	Штанга
3	Отжимания
25	Постійний струм
5	Повторення 8кл
5	Розв'язуванн трикутників
5	Правильні многокутники
25	Ел-магнітна індукція
25	Ел-статика
30	2. Фонетика
30	1. Повторення
197	комплексні числа
25	Струм середовища
197	похідна
25	Магнетики
25	Магнітне поле
47	2.Підмет і
47	1. Просте
200	4.Подібність
200	5.Прямок.тр.
82	3 Conditional
200	3.Чотирикутн
200	2.Многокутн.
200	1.Повторення
48	2.Шевченко
48	1.Повторення
94	інтеграл
200	7.Площі
200	8.Повтор.
200	6.ДКР
57	машинобудува
57	металургія
57	самостійна робота
57	хімічна промисловіст
58	країни Америки
58	Країни Африки
58	країни Європи
58	глобальні проблеми
58	Австралія і
58	країни Азії
69	Повторення
69	Доведення нерівностей
69	Квадратична функція
69	Елементи прикладної
69	Системи рівняннь
69	Послідовност
70	Вектори
70	Декартові координати
70	Геометричні перетворення
107	Основи Python
107	Математична логіка
107	Кодування даних
1	Повторення 9класу
1	Доведення нерівностей
1	Квадратична функцiя
1	Системи рівнянь
1	Повторення 8класу
60	2.Нервова система
60	1.Oпора i
1	Прогресії
1	Прикладна математика
31	2. П.Мирний
31	2 Фонетика
31	1 повторення
31	Карпенко-Кар
99	змінний струм
99	геометрична оптика
10	Вектори
10	Координати на
10	Геометричні перетворення
198	інтерференц. самост.
198	контр.фотони
198	дифракція контр.
198	ДКР
198	диктант.ств
198	фотоефект к.р.
197	використання похідної
197	первісна
197	ДКР
197	границя функції
197	визначений інтеграл
197	многочлени
203	Повторення механіки
203	Теплота
197	ймовірність
15	Неорганічні речовини
15	Органічні речовини
225	Тригонометри функції
225	Степенева функція
15	клітина
131	Сортування
150	правильні многокутники
150	розвязування трикутників
127	Повторення
127	Масиви
127	Сортування масивів
142	Повторення
142	інтеграл
142	Похідна
150	декартова система
150	геометричні перетворення
150	вектори
150	повторення 8кл
175	основи теорії
175	основи публічного
175	основи
123	основи теорії
123	сімейне право
123	сімейне та
123	людина і
123	цивільне право
123	правовідноси правопорушен
123	цивільнесіме трудове
166	основи теорії
166	Системна криза
166	перебудова в
166	друга світова
166	Україна у
151	повторення
151	Квадратні рівняння
151	Теорія подільності
151	множини
151	Квадратні корені
151	нерівності
151	Повторення 8кл.
151	раціональні вирази
229	повторення
229	вуглеводні
229	оксигеновміс сполуки
204	Повторення
204	Статика
204	Динаміка
204	РухПоКолу
204	Кінематика
204	Закони збереження
14	9.Повторення
14	1.Повторення 9
14	2.Триг. функції
14	5.Степ. функція2
14	6.Посл-сті
14	7.Границя функції
14	4.Степенева функція1
14	3.Триг. р-ня
14	8.Похідна
14	Залік
86	travelling
86	Food
131	Повторення матеріалу
176	коливання хвилі
176	динаміка
176	ДКР
176	Статика ДОРТТ
176	ANEнергія
176	кінематика
161	Коливання
161	Ел.-маг. хвилі
161	Елем. частинки
161	Світлові хвилі
161	Геометр. оптика
161	Повторення
161	Ядерна фізика
161	Механічні хвилі
161	Змінний струм
161	Світлові кванти
161	ЗНО
161	Елементи ТВ
161	Спектр. аналіз
149	квадратична функція
149	послідовност
149	рівн-системи
149	Повторення 8кл
149	прикладна математика
149	нерівності
131	Масиви файли
176	повторення 8кл
165	Країни Західної
165	Друга світова
165	Східна Європа
165	США і
148	теорема Фалеса
148	площі многокутникі
148	повторення 7кл
148	повторення 8
148	розв'язуванн трикутників
148	вписані-опис 4-кутники
148	подібність
148	многокутники
205	Франція
22	2.Вступ
22	4.Перпенд.у просторі
22	5.Вект. коорд.
22	3.Паралельн. просторі
22	1.Повторення
22	6.Повторення
22	Залік
157	5.Координати
157	8. Повторення
157	2.Розв.трик.
157	7.Тригоном
157	3.Прав.мн-ки
157	6.Геом.перет
157	4.Вектори
157	1. Повторення
174	Теплові явища
174	Світлові явища
174	Електричні явища
174	Ел-маг. явища
174	Повторення 7класу
198	поточна
198	контр.роб.сп
2	Квадратична функція
142	chernetka
2	Системи рівнянь
2	Послідовност
2	нерівності
2	Прикладна математика
199	01.Повторенн
199	04.Нерівност
199	08.ДКР
199	11.Повтор.
199	05.Кв.корені
199	06.Кв.рівнян
199	07.Подільн.
199	09.Многочлен
199	02.Множини
199	03.Рац.вираз
243	легка атлетика
139	перша світова
243	повторення ЛА
243	волейбол
243	силова підготовка
205	Франція 1815-1847
205	Модернізація Європи
243	баскетбол
243	норматив
139	провідні країни
16	Основи програмуванн
6	Іонні рівняння
6	швидкість реакції
6	Розчини
139	семестрова
139	післявоєнний устрій
205	Країни Європи
205	революції 1848-49
16	Складені оператори
16	Системи числення
205	Робітничий рух
147	святкова контрольна
147	квадратні корені
147	повторення 8
147	повторення 7кл
147	нерівності
147	теорія множин
147	квадратні рівняння
147	подільність
147	раціональні вирази
205	Німеччина.Ан
218	повторення7к
156	4.Об`єми
156	2.Многогранн
156	5. Комб.геом.ті
156	3.Тіла оберт.
156	1.Многогр.ку
156	6.Повторення
155	2.Квадр.ф.
155	4.Нерівності
155	6.Прикладна м
155	5.Послідовно
155	7.Повторення
155	3.Сист. рівн.
155	1. Повторення
154	1.Заст.пох. Пок.лог
154	5.Многочлени
154	2. Інтеграл
154	3. Прикл.матем.
154	6.Матем.логі
154	7.Повторення
154	4.Компл.числ
152	тригонометри функції
152	степенева функція
152	тригонометри рівняння
153	вступ до
153	паралельніст у
153	відстані
160	степенева функція
160	логарифми
160	тригонометрі 1
160	тригонометрі 2
205	Азія і
205	французька революція
266	Французька революція
266	Революції обєднання
212	Грамат. основа
268	легка атлетика
257	Легка Атлетика
212	Словоспол.
36	золоті сторінки
201	Сферична астрономія
214	Складне речення
108	легка атлетика
214	Пряма Непряма
228	Повторення
248	вступ
216	Ренесанс. Бароко
216	Фольклор. Давня
216	Нова УЛ
213	Фольклор
50	Священні книги
79	Думи
79	1 Історичні
79	Леся Українка
79	Пісні Чурай
79	Т. Шевченко
79	односкладне речення
223	Клітина
8	Кров кровообіг
8	органи виділення
8	Дихання травлення
8	Опора рух
8	Клітина
8	Cенсорна система
8	Регуляція функцій
221	Unit 7
221	Unit 6
221	Unit 5
221	Unit 8
260	ОЦЗ
260	домедична підготовка
260	отруєння
260	тематична
260	механізм травми
260	МГП
260	домедична допомога
209	рац
205	Культура народів
205	США Росія
205	наполеонівсь війни
237	хвилі
237	коливання
235	Нерівності
31	1.Нечуй-Леви
139	річна
139	США
222	Повторення
222	Термодинамік
222	Молекулярна фізика
139	СШАБританія Франція
139	Країни Центральної
178	Складнопідря реч.
178	Пряма мова
252	Unit 2
252	Unit 1
178	повторення
213	Поезія Шевченка
213	Світ поезії
178	Складне реч.
45	Квадратні рівняння
242	легка атлетика
242	човниковий біг
242	стрибок з
45	множини
45	Тотожні перетворення
45	Квадратні корені
230	повторення
230	хімічний звязок
45	повторення 7
45	нерівності
45	теорія чисел
45	раціональні вирази
178	Складносуряд реч.
236	Площа фігур
23	Контрольна механіка
23	тема-мех
23	повтор мех
23	молекуляр
23	термодинамік
23	тема-2
23	Контрольна молекулярка
264	Друга світова
64	Періодичний закон
64	Будова атома
64	Масова частка
64	хімічні формули
64	Густина газів
211	Періодичний закон
211	Іонні рівняння
46	повторення
46	чотирикутник
46	паралелограм
46	вписані та
46	многокутники
24	динаміка
24	магнетизм
24	геометрична оптика
144	Повторення
144	Тіла обертання
144	черенка
144	Прав. многогран.
144	chernetka
24	повторення 8кл
87	кафка перевтілення
125	усна творчість
125	Котляревськи
125	Т.Г. Шевченко
261	отруєння
125	Куліш
125	Квітка-Основ
26	біорізномані
26	ДКР
26	2.подiл клiтини
246	народна творчість
246	давня література
62	АДАПТАЦІЯ
226	Вступ
226	Паралельніст у
84	Unit 7
84	Unit 9
84	Unit 8
179	Усн. нар
78	2 Словосполуч.
78	Другорядні члени
78	1.Повторення
110	Вступ ІТ
89	Лінійні алгоритми
89	Системи числення
34	ПРОСВІТНИЦТВ
4	оптика
4	магнетизм
4	кінематика
129	Сортування
129	КЗЗ
129	Стандартні контейнери
129	АТД
129	Масиви файли
206	декабристи
206	Адмінподіл міжнародні
206	практична робота
206	Азія і
206	Наддніпрянщи 1
206	Економічний розвиток
206	Україна на
206	культура України
206	Наддніпрянщи у
206	західноукраї землі
206	КМТ
206	культура 19
110	Інформаційна система
105	Основи програмуванн
105	Математична логіка
105	Кодування даних
217	Теплота
217	Повторення 7класу
215	Основи МКТ
254	Вступ технології
254	Інформаційна система
133	Основи Excell
133	Вбудовані функції
207	ООП калькулятор
207	ООП тест
202	повторення механіки
202	молекулярка теплота
234	тема 1
231	тема 1
232	тематична
232	тема 1
238	Проектна робота
88	Складові здоров'я
88	тема 2
88	тема 1
265	Двуга світова
267	Російська імперія
267	Австрійська імперія
224	Повторення
224	Проект Тестування
224	Проект Візуалізація
224	Проект Калькулятор
138	українська революція
138	перша світова
138	Українська держава
138	семестрова
138	річна
138	Сталінська модернізація
83	Граматичне завдання
83	Повторення. Starter
83	Unit1 Освіта
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.users (login, password, enabled, first_name, second_name, third_name) FROM stdin;
andrus18	iDpVpLlF	t	Андрущенко	Валерія	Ігорівна 
babenk18	mpVMVj2X	t	Бабенко	Максим	Глібович 
pyhalova16	mFkimw	t	Пихалова	Маргарита	Володимирівна
kurchi18	mamamarka	t	Курчин	Марк	Денисович
danilo18	qRjszhgr	t	Данилова	Євгенія	Борисівна 
demche18	197919812004	t	Демченко	Ілля	Дмитрович
svm	hA8FwPdc	t	Стецюк	Володимир	Миколайович
Antono23	5cG4j	t	Антонов	Іван	Євгенович
fekla	sm1vQPx	t	Заболотня	Олена	Федорівна
goy	DxowBW9	t	Гудзь	Олександр	Якович
gajovi18	321766Yarik2004	t	Гайовий	Ярослав	Олексійович
bizura16	8EnHIj	t	Бізюра	Ольга	Володимирівна
lugovaj16	R1DpZK	t	Лугова	Юлія	Олександрівна
sapelnikov16	RVoRep	t	Сапельніков	В'ячеслав	Леонідович
akymenko16	akymenko16	t	Акименко	Андрій	Петрович
pyvovar16	Benedict2002	t	Пивовар	Єгор	Ігорович
Aleksie23	Gu28x	t	Алексєєва	Марія	Артемівна
Husieiev23	Eps43	t	Гусєєва	Марія	Костянтинівна
kop	CopKov123	t	Ковальчук	Оксана	Петрівна
chorni18	9H6teb	t	Магалецький	Андрій	Костянтинович
Bahrych	Nik2004	t	Багрич	Нікіта	Євгенович
Mariukhi23	m6C5b	t	Марюхін	Ілля	Сергійович
Volove23	Yg41l	t	Воловенко	Ігор	Олегович
Koben23	58Eiu	t	Кобеньок	Юлія	Олегівна
zaika16	jazdlook1337	t	Заїка	Георгій	Олександрович
Pykhtin23	c2lA8	t	Пихтін	Давид	Ігорович
kotliarova16	2003alina	t	Котлярова	Аліна	Юріївна
bokhonovatu	145	t	Бохонова	Тетяна	Юріївна
ishche18	user2004	t	Іщенко	Іван	Андрійович
lomono18	uVepWwuu	t	Ломоносов	Матвій	Олексійович 
mazur18	O1SE8bKT	t	Мазур	Максим	Іванович 
majdan18	HwRBdoJ7	t	Майданник	Луіза	Олегівна 
yni	145	t	Ястребцова	Наталія	Іванівна
top	xyz2012	t	Торчило	Олена	Петрівна
klm	145x	t	Хольвінська	Лідія	Михайлівна
Salan23	5k5Lj	t	Салан	Михайло	Юрійович
rtm	rtm101	t	Ржанская	Татяна	Миколаївна
Pustov23	u67Zc	t	Пустовойт	Микита	Сергійович
Herus23	Bng03	t	Герус	Назар	Сергійович
Korol23	6c5Zt	t	Корольов	Нікіта	Олександрович
mns	mns	t	Махоткина	Наталія	Станиславівна
pvv	pvv145	t	Перга	Вікторія	Виталіївна
Mushchenk23	Oz2y6	t	Мущенко	Дана	Олександрівна
aop1993	aop1993	t	Атаманенко	Олексій	Павлович
vernk18	ogI9xJGv	t	Вернік	Данило	Олексійович
barash18	jNaES6b2	t	Бараш	Даниїл	Максимович
krasnopol22	xcv46	t	Краснопольський	Святослав	Ігорович
zubish22	rty09	t	Зубішин	Олександр	Дмитрович
zubareva16	3Lrtri	f	Зубарева	Ольга	Сергіївна
bondarenkoo16	Y6kTDB	t	Бондаренко	Олексій	Дмитрович
zdebka16	mBeEy9	t	Здебська	Катерина	Сергіївна
mal4enko16	tHYhm6	t	Мальченко	Гліб	Сергійович
fal16	Bu11dG	t	Фаль	Андрій	Андрійович
nester18	f8M5vTR6	t	Нестеренко	Назарій	Олександрович 
novoha18	KYXc0USm	t	Новохацький	Антон	Олександрович 
lconst	nhjtobyf	t	Лятамбур	Костянтин	Миколайович
іvanov18	mW6P9API	f	Іванов	Андрій	Дмитрович 
palamU20	XZe5n	t	Паламарчук	Юстин	Ігорович
pashev18	wEcrJ1tZ	t	Пашева	Діана	Андріївна
kamns18	2t9r8WY3	t	Камінський	Антон	Сергійович
kuzmishyna16	1	t	Кузьмішина	Майя	Володимирівна
levoshko16	1	t	Левошко	Данило	Костянтинович
shchurov16	1	t	Молчанов	Антон	Павлович
posternak16	1	t	Постернак	Марія	Володимирівна
stakhurska16	1	t	Стахурська	Інга	Максимівна
shapovalova16	1	t	Шаповалова	Марія	Данилівна
tkachenko16	tkachenko16	t	Ткаченко	Іван	Ростиславович
zadorozhnyi16	zadorozhnyi16	t	Задорожний	Михайло	Олегович
mikliaiev16	mikliaiev16	t	Мікляєв	Гліб	Олегович
knopG19	knopG19	t	Кнопов	Георгій	Олександрович
rli	HoT	t	Романчикова	Любов	Іванівна
vyshnevetska16	vyshnevetska16	t	Вишневецька	Ольга	Денисівна
sydorak16	sydorak16	t	Сидорак	Данило	Романович
HarbuzS	1Gh4q	t	Гарбуз	Софія	Олександрівна
prokopS18	S8yu7P	t	Прокопенко	Сергій	Романович
zhirno18	vUJA	t	Жирнов	Денис	Максимович
prijma18	fxWkc9mn	t	Прийма	Владислав	Михайлович 
ischuk18	TPuYMGSz	t	Іщук	Дмитро	Вадимович
shtand18	Gwc5UWxP	t	Штанденко	Анна	Сергіївна
plusnin16	cMbWiX	t	Плюснін	Владислав	Сергійович
selezn18	QLZbnFER	t	Селезньов	Нікіта	Андрійович 
basovds	Kuzma444	t	Басов	Дмитро	Сергійович
hutorj18	ACt3JbjT	t	Хуторян	Єгор	Андрійович 
tsymbalenko16	tsymba51	t	Цимбаленко	Владислав	Олегович
skytsuk16	q123	t	Скицюк	Віктор	Андрійович
Akhmeto23	47uBu	t	Ахметова	Валентина	Олегівна
Hlushko23	j5U2l	t	Глушко	Дмитро	Володимирович
Korsun23	H6p3v	t	Корсун	Дарія	Ігорівна
Dmytru23	z42mL	t	Дмитрук	Олег	Андрійович
rezn18	ileYYZrR	t	Рейзін	Тимофій	Денисович
chorno18	NVji4jYT	t	Чорноморець	Варвара	Юріївна 
chufar18	GsvNFcE6	t	Чуфаров	Михайло	Ігорович 
galabu18	74chbCo	t	Галабурда	Микола	Андрійович
Natal23	5n4oD	t	Натальченко	Мирослав	Іванович
khan	khan	t	Хараберюш	Анатолій	Миколайович
vojteh18	qBxCjxFZ	t	Войтех	Тимофій	Володимирович
zinchukvm	8forfo	t	Зінчук	Вадим	Миколайович
tsimba18	xxxtentacion	t	Цимбал	Петро	Володимирович
alekseev16	xZjbzK	t	Алєксєєв	Артем	В'ячеславович
muraviov16	ifEgOp	t	Муравйов	Тимофій	Вадимович
siv	N6Fds9h	t	Сидоренко	Ірина	Володимирівна
su4kova16	mnqPKp	t	Сучкова	Єлизавета	Іванівна
1vahne18	b9SWou	t	Івахненкова	Дарія	Сергіївна
gon4arenko16	elNuiK	t	Гончаренко	Костянтин	Олександрович
vynny	vynny229	t	Виннишин	Ярослав	Федорович
tarannS20	LmKj8	t	Тараннік	Софія	Володимирівна
morozdo	z91r6QBU	t	Мороз	Дарина	Олегівна
zagoru18	pPErOFne	t	Загоруйко	Даніїл	Ігорович
zubchenkovp	Vc17GqM5	t	Зубченко	Володимир	Петрович
konber18	hczbKeeP	t	Конберг	Гліб	Денисович
kosenk18	0Daj9pZ4	t	Косенко	Геннадій	Геннадійович
lavrov18	TWU7JoXa	t	Лаврова	Віра	Іванівна
macheh18	HLqnhQBY	t	Мачехін	Назар	Олексійович
palama18	sP21qnQx	t	Паламарчук	Олексій	Володимирович
semenk18	d5XNbG6H	t	Семенько	Іван	Ігорович
chobot18	mczyYcxG	t	Чоботюк	Анастасія	Олександрівна
barash16	1	t	Бараш	Арсеній	Максимович
tvnnk16	12345678	t	Тівоненко	Андрій	Іванович
danilov16	1	t	Данілов	Гліб	Ігорович
zhylin16	1	t	Жилін	Ілля	Олександрович
kolisnyk16	1	t	Колісник	Дмитро	Олексійович
kostytska16	1	t	Костицька	Анна	Михайлівна
mamichev16	1	t	Мамічев	Артем	Олександрович
mozol16	1	t	Мозоль	Артем	Євгенійович
mosiichuk16	1	t	Мосійчук	Кирило	Олександрович
pylypenko16	1	t	Пилипенко	Олексій	Андрійович
sachokv16	1	t	СачокВ	Володимир	Дмитрович
sachoki16	1	t	СачокІ	Ігор	Дмитрович
slavska16	1	t	Славська	Олеся	Олександрівна
chub16	1	t	Чуб	Іван	Олександрович
pavlov16	pavlov16	t	Павлов	Володимир	Ігоревич
rudyi16	rudyi16	t	Рудий	Петро	Андрійович
sobolevskyi16	sobolevskyi16	t	Соболевський	Антон	Сергійович
khalapsus16	khalapsus16	t	Халапсус	Гліб	Денисович
tsukanov16	tsukanov16	t	Цуканов	Даніїл	Ігорович
diachuk16	diachuk16	t	Дячук	Даніїл	Дмитрович
kalinichenko16	kalinichenko16	t	Калініченко	Катерина	Дмитрівна
aleks18	97otxF	t	Алексєєва	Наталія	Сергіївна
oip48	oip48	t	Ольховська	Ірина	Петрівна
gorn18	UJt34NYD	t	Горнійчук	Роман	Євгенович
sichka18	LxYCYpYE	t	Січка	Дмитро	Андрійович
golova18	hUEoZbSA	t	Головань	Володимир	Ілліч
erіk18	GzomqN7o	f	Ерік	Артур	Євгенович
pivenn16	pivenn16	t	ПівеньА	Анастасія	Дмитрівна
Karimov18	eR15nm	t	Карімов	Кирило	Євгенович
synytsia16	MS16	t	Синиця	Марія	Станіславівна
borise18	S23hMp	t	Борисенко	Катерина	Андріівна
dubas18	5hddywW	t	Дубас	Данило	Ростиславович
zozulj18	Yg8m7GH	t	Зозуля	Данило	Олексійович
konone18	QYypu6P	t	Кононенко	Олександр	Євгенович
panfl18	Xw2PX3qw	t	Панфілов	Микита	Михайлович
rubash18	07XquqK	t	Рубашна	Вероніка	Ігорівна
bega16	0TvMrj	t	Бега	Іван	Андрійович
lugovam16	R2DpZK	t	Лугова	Мирослава	Олександрівна
targonsky16	xQE3vn	t	Таргонський	Дмитро	Дмитрович
sheredeko16	Zma2LY	t	Шередеко	Георгій	Вікторович
makhrovaov	liolia	t	Махрова	Ольга	Василівна
med	med	t	Медведенко	Оксана	Анатоліївна
balatsuk17	p2h9P	t	Балацюк	Лука	Анатолійович
vasylieva17	yR76d	t	Васильєва	Василиса	Володимирівна
demenkov17	Rv9c1	t	Деменков	Олександр	Віталійович
levtik	1020	t	Левтік	Микола	Миколайович
savinov16	Qlvgow	t	Савінов	Артем	Володимирович
kyslenko17	aAv21	t	Кисленко	Софія	Юріївна
ltv	tul16167	t	Лук'янчикова	Тетяна	Володимирівна
cherniakova16	1nTJl7	t	Чернякова	Олександра	Павлівна
kozoriezova17	tV6p1	t	Козорєзова	Тетяна	Сергіївна
tarasenko16	Yt56bR	t	Тарасенко	Сергій	Віталійович
jarko143	O1sj1	t	Ніколенко	Ярослав	Вікторович
molodtsova17	5rFx6	t	Молодцова	Анна	Єгенівна
naumov17	mT87h	t	Наумов	Данііл	Олегович
verbov18	kQirDX	t	Вербов	Артемій	Вадимович
murynskavv	Lut48iv7	t	Муринська	Вікторія	Вікторівна
rustamovavp	krav1934	t	Рустамова	Віра	Петрівна
yaroslav	12345	t	Гуменюк	Ярослав	Олександрович
mmoroz	0674459263	t	Мороз	Микола	Петрович
mahinj18	kxNAwc	t	Махиня	Ігор	Сергійович
mudrag18	h24aHT	t	Мудрагель	Дар'я	Сергіївна
shkil18	TosUHemr	t	Шкіль	Олександр	Володимирович
tomkiv18	CKZ2h3GY	t	Томків	Данило	Павлович
Yakubyshyn	Archik777	t	Якубишин	Анатолій	Сергійович
papa	qwas	t	Липницкий	Денис	Владимирович
kovtun17	ZZt3d5	t	Ковтун	Дар'я	Василівна
kua	kua14541	t	Кушнір	Юрій	Анатолійович
nahorna17	BCzVV6	t	Нагорна	Єлизавета	Вікторівна
ofursova	0987099796	t	Фурсова	Олена	Юріївна
horoh18	cV9Ws9	t	Горох	Єлизавета	Євгеніївна
sahaidaktv	stv	t	Сагайдак	Тетяна	Василівна
burliai16	1	t	Бурляй	Данило	Юрійович
granov18	PNTR7K	t	Грановський	Андрій	Костянтинович
bagan18	c4v2Mm	t	Баган	Наталія	Анатоліївна
didish18	dyub1S	t	Дидишко	Аліна	Віталіївна
dreger18	mHnJ0B	t	Дрегер	Владислав	Владиславович
zhmend18	WuhPe7	t	Жмендак	Олександр	Андрійович
guman18	FeEYBZ	t	Гуманіцький	Андрій	Олександрович
zasoba18	Bwex2M	t	Засоба	Олена	Максимвна
karpen18	wN6kUE	t	Карпенко	Максим	Сергійович
koval18	rgMzvH	t	Коваль	Артем	Володимирович
kosten18	jVTdpE	t	Костенко	Лев	Антонович
kucher18	7h8xWx	t	Кучер	Богдан	Олександрович
lut18	46sYUp	t	Лут	Артем	Романович
IrinaSklyar	Fkujhbnv	t	Скляр	Ірина	Вільївна
mhnov18	Zs1s7D	t	Міхновська	Марія	Станіславівна
cherka18	pjhEDvv6	t	Черкас	Дмитро	Олексійович
ohten18	XnttF5	t	Охтень	Артем	Олегович
poplav18	jAg492	t	Поплавський	Дмитро	Іванович
potiomk18	VATnZw	t	Потьомкін	Олександр	Євгенович
rogovt18	m2zcOT	t	Роговцова	Анна	Олександрівна
sahno18	ZrJoSb	t	Сахно	Олександр	Павлович
slsar18	8M0u38	t	Слісарчук	Микита	Миколайович
slch18	YEDLB1	t	Сільчин	Іван	Ігорович
timosh18	BN19mi	t	Тимошенко	Данило	Сергійович
topork18	iB2Gcp	t	Топорков	Гліб	Валентинович
trojn18	viBkf2	t	Тройнікова	Маргарита	Олексіївна
trotsk18	E5h2Qp	t	Троцько	Софія	Русланівна
shvora18	qhUWdA	t	Шворак	Наталія	Віталіївна
fla	Lyscnth	t	Федорів	Любомир	Атанасійович
chubar18	5S6R2s	t	Чубарук	Софія	Олександрівна
zhmailo16	1	t	Жмайло	Олександр	Дмитрович
bohun16	bohun16	t	Богун	Іван	Дмитрович
khmelevskyy	Kl4bFt	f	Хмелевський	Святослав	Олександрович
pivenx16	pivenx16	t	ПівеньК	Ксенія	Дмитрівна
diachenko	diachenko	t	Дяченко	Артем	Сергійович
vasyliev17	KLf38f	t	Васильєв	Костянтин	Олексійович
zaitsev17	esR22u	t	Зайцев	Нікіта	Олексійович
kurochkin17	hxsHX	t	Курочкін	Павло	Ігорович
milevska17	YPwwvn	t	Мілевська	Анастасія	Володимирівна
iatsyk17	dCRbrB	t	Яцик	Олександр	Вікторович
malenko17	nHrt11	t	Маленко	Сергій	Сергійович
borets17	3LLCw145	t	Борець	Мілена	Владиславівна
bruiev17	ZhmVSm	t	Бруєв	Іван	Костянтинович
bulakh17	gdcZm3	t	Булах	Леонід	Ігорович
vasylchenko17	AZg3J4	t	Васильченко	Анастасія	Дмитрівна
vyhovskyi17	xMxVr9	t	Виговський	Назар	Дмитрович
vborysiuk	borysiuk145	t	Борисюк	Василь	Іванович
rozenwine	rose	t	Розенвайн	Олексій	Григорович
husieiev17	uTd4Eh	t	Гусєєв	Єгор	Костянтинович
nemiatyi17	3ebpyX	t	Нем'ятий	Роман	Сергійович
rachkevych17	Sfggka	t	Рачкевич	Ярина	Вікторівна
shevtsov17	ShN7k	t	Шевцов	Нікіта	Сергійович
mykhaelian17	MyAnn37	t	Михаелян	Анна	Гергіївна
bilous17	77SbFH	t	Білоус	Юрій	Валентинович
zaiets17	ivLAwG	t	Заєць	Ілля	Вікторович
ardashov16	ardashov16	t	Ардашов	Олександр	Дмитрович
barabash17	u7Ju4	t	Барабаш	Дмитро	Володимирович
berezhanskyi17	gX53i	t	Бережанський	Іван	Ігорович
vasylievn17	2mpP5	t	Васильєв	Назар	Любомирович
vasiuta17	K58tt	t	Васюта	Анатолій	Вікторович
stetsiuk17	8XLMvM	t	Стецюк	Юрій	Геннадійович
shevel17	Ks1DVj	t	Шевель	Денис	Євгенійович
skorobahatko17	180623Dm	t	Скоробагатько	Дмитро	Олександрович
zhukovska17	Gd6aN	t	Жуковська	Мирослава	Юріївна
klymenko17	P2fcD2	t	Клименко	Михайло	Олександрович
kapustian17	eMZi2z	t	Капустян	Аліса	Денисівна
kolosok17	WDwT7E	t	Колосок	Роман	Олегович
zhytnik17	fbN14	t	Житнік	Богдан	Юрійович
tonkoshkur16	1	t	Тонкошкур	Ксенія	Геннадіївна
naveriani17	NsmpgZ	t	Наверіані	Давид	Емзарович
nahornyi17	qQR21f	t	Нагорний	Дмитро	Андрійович
starunov17	BrxjPT	t	Старунов	Артьом	Олександрович
churylovych17	PSgCGw	t	Чурилович	Дмитро	Вадимович
vekha17	Up4ns	t	Веха	Олексій	Володимирович
kostia17	atnp6G	t	Костя	Пауліна	Євгеніївна
lishanska17	X1uWj2	t	Лішанська	Катерина	Дмитрівна
ohorodnytskyi17	xxGEZl	t	Огородницький	Володимир	Дмитрович
okunievskyi17	c98Ez9	t	Окунєвський	Єгор	Павлович
romanchenko17	5zz9gG	t	Романченко	Єлизавета	Андріївна
shynkarenko17	b8ygFF	t	Шинкаренко	Олександра	Євгенівна
iurchenkom17	8AHETS	t	Юрченко	Даниїл	Дмитрович
popova17	0Ug5v	t	Попова	Єлизавета	Олександрівна
patraboi17	i5BXnF	t	Патрабой	Назарій	Олександрович
kolodkars	A6u9yqd	t	Колодка	Роман	Степанович
teryu	phy9V122	t	Терентьєва	Юлія	Георгіївна
tkachuk21	qwaertyg	t	Ткачук	Карнела	Леонідівна
ieremenko17	vVzhS8	t	Єременко	Єлизавета	Ігорівна
KucherV17	vj6D2	t	Кучеренко	Володимир	Олегович
prytup17	e74Se	t	Притуп	Володимир	Юрійович
ryzhenko17	n8M0x	t	Риженко	Дмитро	Ігорович
shychy18	P6hLHg	t	Шичинов	Іван	Романович
savchenko17	i6R0r	t	Савченко	Микола	Віталійович
samarina17	S5sn3	t	Самаріна	Валерія	Євгенівна
solomakha17	bKc03	t	Соломаха	Олександр	Віталійович
zabarianska16	1	t	Забарянська	Ірина	Сергіївна
iurchenkof17	0T9tu	t	Юрченко	Дарія	Дмитрівна
iezhel17	jsK70	t	Єжель	Михайло	Ігорович
igorroik	2fzG5	t	Роїк	Ігор	Олександрович
janush18	1W1kuS	t	Янушевський	Роман	Олексійович
papizh17	papizhkpnl	t	Папіж	Михайло	Володимирович
komarovM20	mTR45	t	Комаров	Микита	Павлович
maznichenko16	1	t	Мазніченко	Лев	Владиславович
bilokur14	Q4rG1g	f	Білокур	Михайло	Олександрович
bovdui16	bovdui16	t	Бовдуй	Еліна	Юріївна
ivkoliz05	ivkoliz05	t	Івко	Єлизавета	Юріївна
Vysotskyy	Vysotskyy	t	Висоцький	Дмітрій	Русланович
danyliuk16	danyliuk16	t	Данилюк	Валерія	Русланівна
pliushchai17	35BDPM	t	Плющай	Анна	Олександрівна
kysliuk17	zqd8Yj	t	Кислюк	Ольга	Вікторівна
siryk17	U1DdAQ	t	Сірик	Артем	Олексійович
bakun	U1jm5	t	Бакун	Марія	Вадимівна
koval17	p2ejKk	t	Коваль	Володимир	Юрійович
kozyr17	E8vi4	t	Козир	Єгор	Денисович
matsiukira	6Uu7e	t	Мацюк	Ірина	Юріївна
pasechnykm	3mn5F	t	Пасечник	Михайло	Денисович
IvanP	9j4Tn	t	Переворухов	Іван	Андрійович
petrenko	i7A6v	t	Петренко	Ростислав	Русланович
cezar17	16koU	t	Цезар	Денис	Беркей
raetsk18	2KoAeN5R	t	Раєцький	Євгеній	Дмитрович
Rusinova	Rusinova	t	Русінова	Анна	Олегівна
falko17	fK2Af9	t	Фалько	Олег	Андрійович
borovyi17	NevwdA	t	Боровий	Іван	Володимирович
havrysh17	yfVM5U	t	Гавриш	Олексій	Вікторович
muzychuk17	W7Hqd8	t	Музичук	Дмитро	Анатолійович
riabichenko17	FkLWiU	t	Рябіченко	Алєксандра	Дмитрівна
mordvynov17	mordv17	t	Мордвинов	Аскольд	Ернестович
blp	0661540248	t	Бондаренко	Людмила	Петрівна
ushakovv	041218	t	Ушаков	Віктор	Віталійович
zaporozhets	werewolf	t	Запорожець	Крістіна	Сергіївна
didenkodm	174hfydtrj	t	Діденко	Дмитро	Геннадійович
arseniuk	Fhctyer	t	Арсенюк	Андрій	Олександрович
bidasiuk	12546yfhgdters	t	Бідасюк	Анастасія	Юріївна
Lichutin	77771309	t	Лічутін	Дмитро	Євгенійович
simonovandr	123456	t	Сімонов	Андрій	Леонідович
senchenko	2208291irina	t	Сенченко	Віталій	Вікторович
linkan	tyurio8675ijg	t	Лінк	Анастасія	Андріївна
volodia2bondar	volodia2bondar	t	Бондар	Володимир	Олександрович
marchenko17	M9Nnkp	f	Марченко	Марк	Тарасович
Goldmayer	Goldmayer	t	Тищенко	Єгор	Андрійович
stopchatyi16	1	t	Стопчатий	Андрій	Романович
GalinaFox	1	t	Стречин	Галина	Ярославівна
vlad	vlad	t	Ковальчук	Владислав	Васильович
redia16	redia16	t	Редя	Олександр	Володимирович
samarets16	samarets16	t	Самарець	Олександр	Юрійович
sizikova16	sizikova16	t	Сізікова	Софія	Євгеніївна
sniehovskyi16	sniehovskyi16	t	Снєговський	Нікіта	Олегович
lukyanov	sOgiqg	f	Лук'янов	Віталій	Євгенович
peo	DDff13	t	Перепьолкін	Євген	Олександрович
vov	541vOv	t	Володкевич	Олена	Володимирівна
sio	OEOaN5s	t	Савченко	Ігорь	Олександрович
rat	145	t	Щур	Юрій	Іванович
fml	145	t	Федорів	Марія	Любомирівна
hip	145	t	Грабовий	Ігор	Петрович
rnv	145	t	Речич	Наталія	Василівна
mli	145	t	Мірзоєва	Людмила	Іванівна
vea	iONKeD	t	Варзар	Євгеній	Анатолійович
Bernad23	Lam93	t	Бернада	Вероніка	Анатоліївна
mikhailov	6NEvnt	f	Михайлова	Марина	Михайлівна
Masnyi23	8I3dx	t	Масний	Богдан	Ігорович
Sazono23	8bEs8	t	Сазонов	Єгор	Олексійович
Varlam23	2l1cS	t	Варламов	Андрій	Юрійович
Homeniu23	0D9tv	t	Гоменюк	Поліна	Дмитрівна
Kondra23t	t6yA7	t	Кондратюк	Денис	Андрійович
Polovn23	J09ch	t	Половнев	Артем	Євгенович
Taraso23	t74vX	t	Тарасов	Григорій	Георгійович
Danchen23	iuB17	t	Данченко	Олександр	Євгенович
Lypiats23	22Ccd	t	Липяцький	Олександр	Володимирович
Struko23	dn57J	t	Струкова	Катерина	Сергіївна
Dudko23	7u8zG	t	Дудко	Тамара	Олегівна
Iholki23	1Gd3n	t	Іголкін	Єгор	Вадимович
bannij18	6aY9yY	t	Банний	Іван	Михайлович
haieva17	Nsa53a	f	Гаєва	Дар'я	Павлівна
KurochDan	TTrdf5	t	Курочкін	Данило	Ігорович
Viniche23	Fs98m	t	Вініченко	Олексій	Олексійович
Hromov23	e0N6e	t	Громович	Марія	Анатоліївна
Kondra23c	Hbk53	t	Кондрачук	Ярослав	Володимирович
Mysiv23	8F7mb	t	Мисів	Владислав	Любомирович
Skalats23	5zXu0	t	Скалацький	Георгій	Вячеславович
Poster23	7vL4g	t	Постернак	Андрій	Сергійович
Tuktam23	8kJo7	t	Туктамишев	Дамір	Дмитрович
Fachchin23	M2i0z	t	Фаччін	Олів'єро	Маркович
Dvirny23	7nDf4	t	Двірний	Максим	Ігорович
Lykhoho23	7bUb7	t	Лихогод	Михайло	Олександрович
Andria23	9y1Iu	t	Андріанова	Маргарита	Юріївна
mudrahel15	8HxE7H	f	Мудрагель	Дмитро	Сергійович
davydova14	zd6X9G	f	Давидова	Анастасія	Валеріївна
naumenko	B8JJnM	f	Науменко	Артем	Ігорович
pihulevska16	a5X9Yo	f	Пігулевська	Віра	Олександрівна
krast	bHA08i	f	Краст	Поліна	Андріївна
kuzma	YlCYBH	f	Кузьма	Володимир	Володимирович
menabde15	Y75nSv	f	Менабде	Владислав	Гурамович
hlushenkova	Ec81HQ	f	Глушенкова	Дар’я	Віталіївна
mordvintseva14	XM57vZ	f	Мордвінцева	Людмила	Юріївна
horaychuk	71k1uo	f	Горайчук	Максим	Ігорович
karamyan	BeAz63Q	f	Карамян	Андрій	Васильович
tsymbalenko	NdBSWW	f	Цимбаленко	Всеволод	Олегович
kovalenko	k93rRyF	f	Коваленко	Марк	Русланович
korniychyk	58CtwS	f	Корнійчик	Каріна	Олександрівна
bondarenko	Yf2PmS	f	Бондаренко	Дмитро	Віталійович
afonin	dJVW7my	f	Афонін	Олександр	Андрійович
biletska	DLKuET	f	Білецька	Дар’я	Денисівна
panteleimonova16	FBFnPN	f	Пантелеймонова	Юлія	Андріївна
yerko14	Z2Uw4E	f	Єрко	Андрій	Вадимович
norenko15	1C6sRg	f	Норенко	Артем	Вікторович
kutsenko	XJ0FtL	f	Куценко	Євгеній	Михайлович
lyubyma	g3rDAb	f	Любима	Михайліна	Вікторівна
saviak16	TUib97	f	Сав'як	Макар	Володимирович
tovkes	tu6JWQ8	f	Товкес	Нікіта	Ярославович
vinichenko15	g8QBu4	f	Вініченко	Євгеній	Олексійович
klymashevskyy	JM9nZ9B	f	Клімашевський	Ігор	Анатолійович
prokopenko	q3FBkY	f	Прокопенко	Іван	Віталійович
Kornii23	rt1E5	t	Корнійчук	Назар	Андрійович
Moloka23	aEr72	t	Молоканов	Костянтин	Юрійович
Sporik23	Ls1i4	t	Спорік	Олексій	Миколайович
Drobiaz23	2cL4z	t	Дробязко	Володимир	Романович
Krynyts23	3bS1j	t	Криницький	Дмитро	Дмитрович
Ryzhova23	55rlG	t	Рижова	Маргарита	Антонівна
Fenina23	1r1En	t	Феніна	Марія	Василівна
Avdieien23	n4Cb4	t	Авдєєнко	Уляна	Сергіївна
Zabaria23	K5vi7	t	Забарянський	Олександр	Сергійович
Maznich23	s36rZ	t	Мазніченко	Мирослава	Владиславівна
Tsiupko23	Gf31i	t	Цюпко	Юлія	Ігорівна
Borys23	88Xty	t	Борис	Петро	Валерійович
stepanova17	4O5rf	t	Степанова	Ірина	Віталіївна
Diubenk23	eZd86	t	Дюбенков	Семен	Володимирович
Makhtieie23	gzB00	t	Махтєєв	Андрій	Сергійович
Runchev23	k0S6c	t	Рунчев	Єгор	Сергійович
Khanevy23	m0rR0	t	Ханевич	Леонід	Леонтійович
Bedash23	44sNb	t	Бедаш	Ігор	Сергійович
Ihnatu23	0B2mf	t	Ігнатуша	Валентин	Анатолійович
Meshchan23	s9t9A	t	Мещан	Іван	Ігорович
Chernets23	8Eve6	t	Чернецький	Ілля	Анатолійович
Burache23	2v4zM	t	Бурачек	Андрій	Олегович
Kravche23	B3it7	t	Кравченко	Артем	Сергійович
Nehoda23	04eRt	t	Негода	Костянтин	Юрійович
Stolbu23	4dGv7	t	Столбунська	Аліса	Віталіївна
Khiuste23	F64kr	t	Хьюстед	Зоя	Шонівна
Zabolo23	sF41x	t	Заболотна	Анна	Григорівна
Nyzhnyk23	4zf9J	t	Нижник	Марія	Михайлівна
Riabiche23	Fun03	t	Рябіченко	Євґєнія	Дмитрівна
erik18	GzomqN7o	t	Ерік	Артур	Євгенович
nehuliaiev15	LCg6F8	f	Негуляєв	Нікіта	Єгорович
tarasenko15	3dyLP2	f	Тарасенко	Данил	Олександрович
klimenko	PwMIwP	f	Клименко	Ярослав	Ілліч
levchenko	D7HnBt5	f	Левченко	Софія	Андріївна
krasnovskii	B4jNUAy	f	Красновський	Андрій	Дмитрович
krutov	7VuRVgS	f	Крутов	Василь	Васильович
Bizhan23	Mn9j0	t	Біжан	Іван	Юрійович
Kyryliu23	H29xl	t	Кирилюк	Георгій	Вікторович
Mykola23	Sy7g4	t	Миколайчук	Софія	Антонівна
Shchurovs23	Xg05l	t	Щуровський	Костянтин	В'ячеславович
antoniuk22	Xwt2Y	t	Антонюк	Тимофій	Ярославович
Vvas	145	t	Васильков	Артур	Олегович
agarkov16	1	t	Агарков	Андрій	Ігорович
romanov21	E66nd	t	Романов	Андрій	Олексійович
Krasno23	2hj7B	t	Красновська	Поліна	Дмитрівна
Nemiata23	8lEr7	t	Нем`ята	Юлія	Сергіївна
Cherba23	gDd26	t	Черба	Стефанія	Сергіївна
Kirieiev23	km78A	t	Кірєєв	Олег	Станіславович
Nikano23	A7ap6	t	Ніканова	Олександра	Максимівна
Savchen23	Fis70	t	Савченко	Юрій	Георгійович
Bobesiu23	48Let	t	Бобесюк	Максим	Дмитрович
Korine23	vy7N3	t	Коріневський	Роман	Сергійович
Mykhail23	mxC04	t	Михайлич	Максим	Ігорович
Hudzen23	dL4z6	t	Гудзенко	Тимофій	Андрійович
LishOle23	R1vz6	t	Лішенко	Олександр	Дмитрович
LishYaro23	22Yvb	t	Лішенко	Ярослав	Дмитрович
Parashchi23	e24pX	t	Паращій	Ярослав	Олександрович
mkyryliuk	4163342	t	Кирилюк	Микола	Євгенович
Tomashe23	znar62	t	Томашевський	Назар	Геннадійович
lazore18	La110605	t	Лазоренко	Олександр	Володимирович
voronin16	vrNN	t	Воронін	Олександр	Максимович
kobylinska15	0Ke2PL	f	Кобилінська	Марія	Сергіївна
matiyko	U6CBtsS	f	Матійко	Ярослав	Вікторович
ostashevsky	yK3Y937	f	Осташевський	Марк	Ростиславович
goroh	bF2QDaU	f	Горох	Катерина	Євгеніївна
pokras	ZbKdJ6d	f	Покрас	Олександр	Олександрович
nikitin14	n6nul8	f	Нікітін	Богдан	Денисович
seniuk14	y0uln6	f	Сенюк	Максим	Антонович
teslia14	HMm1p7	f	Тесля	Марія	Романівна
drin	Vldrolo3	f	Дрінь	Валентина	Олегівна
zurov14	ia12AL	f	Зуров	Андрій	Анатолійович
mindich14	0e1kTm	f	Міндіч	Денис	Григорович
shpolyanska	OHdP8D	f	Шполянська	Анна-Марія	Олегівна
maliuha16	1cAv4Q	f	Чайка	Юлія	Сергіївна
dudnyk16	VCs5ph	f	Дудник	Олександр	Ігорович
chechotkin16	BGBEQt	f	Чечоткін	Давід	Владиславович
bernada	CxJZOO	f	Бернада	Дмитрій	Анатолійович
vorobyov	NIFyIw	f	Воробйов	Євгеній	Григорович
mandryka	8EkYvF	f	Мандрика	Даниїл	Юрійович
pavlov	57mxOH	f	Павлов	Богдан	Петрович
snyehovskyy	ghLJ9e	f	Снєговський	Владислав	Олегович
sonkina	ln79DZ	f	Сонькіна	Євгенія	Олександрівна
fedoruk	hTNfVG	f	Федорук	Олег	Володимирович
barlas14	dXX76F	f	Барлас	Олег	Леонідович
dmytruk14	y1CzM8	f	Дмитрук	Михайло	Андрійович
sheremetiev17	Axip8P	f	Шереметьєв	Данило	Дмитрович
venher15	GT7nO1	f	Венгер	Максим	Анатолійович
taran14	Pu0v0f	f	Таран	Дмитро	Олександрович
novikov	Rt9Gfe	f	Новіков	Данило	Миколайович
bilaonova15	Js55Oy	f	БілаоноваДяченко	Анфіса	Андріївна
domnich16	Dom9u	f	Домніч	Денис	Сергійович
strechin16	1	t	Стречин	Галина	Ярославівна
redina16	1	t	Редіна	Христина	Денисівна
borodin	2LsTb7V	f	Бородін	Микита	Дмитрович
slyusarenko	jFjShm	f	Слюсаренко	Євген	Євгенович
yakovlev	3iMx6b	f	Яковлєв	Михайло	Сергійович
rizayev	rcp2WZP	f	Різаєв	Лев	Едуардович
pryshchepa16	zbGf5Q	f	Прищепа	Владислав	Геннадійович
navka	Qn2gPP	f	Навка	Гліб	Олександрович
nyzhnyk	HqAJVa	f	Нижник	Борис	Михайлович
mysak14	l92CIW	f	Мисак	Юрій	Сергійович
matrosova	1	f	Матросова	Катерина	Романівна
yatsyk	kccW8K	f	Яцик	Артем	Вікторович
ramyk	mnKgYV	f	Рамик	Іван	Петрович
ryzhov	QvKg6tM	f	Рижов	Ігор	Антонович
bakai15	4iZ2SX	f	Бакай	Олеся	Романівна
cherevko16	6edFiX	f	Черевко	Крістіна	Олександрівна
chernyshova17	nHCZm6	f	Чернишова	Катерина	Петрівна
dobrzhanskyi17	J1WXP4	f	Добржанський	Леонід	Олександрович
zaluzhniy	rFMd3Cu	f	Залужний	Юрій	Андрійович
ponomarenko15	h6a4fY	f	Пономаренко	Аліна	В'ячеславівна
zemelev	Xm6uNLL	f	Земелев	Савелій	Єгорович
polya	bolT2002	f	Липницька	Поліна	Денисівна
berestyanyy	boM42v	f	Берестяний	Владислав	Олександрович
khropachov14	AAGg31	f	Хропачов	Іван	Глібович
tishchenko	B7YNMgE	f	Тищенко	Тимофій	Андрійович
haluha16	qJvs73	f	Галуга	Олексій	Петрович
osadcha14	l5yd2V	f	Осадча	Поліна	Ігорівна
bardyk15	cfif21	f	Бардик	Олександр	Віталійович
soloma18	Ll7HEUkf	f	Соломаха	Максим	Олександрович
krynko16	fh0Bj6	f	Кринько	Данило	Олександрович
royik16	7jxppK	f	Роїк	Андрій	Євгенович
makhmudov17	TLj83K	f	Махмудов	Олександр	Олександрович
nimchenko	Puh4bG	f	Німченко	Артем	Андрійович
vylushchak17	hGec6Z	f	Вилущак	Володимир	Олегович
sokolovsky16	edl56V	f	Соколовський	Микола	Вікторович
nikitkakiev	6gr6i3tk	f	Довбань	Микита	Ігорович
ievtodii17	AxExHh	f	Євтодій	Дмитро	Андрійович
komarov17	5aFWwK	f	Комаров	Микита	Павлович
rallo15	f5bWI8	f	Ралло	Володимир	Ярославович
lukianenko15	poiuyt	f	Лукяненко	Максим	Андрійович
nahorna15	aNp37qq	f	Нагорна	Анастасія	Павлівна
kovba	Znof9t	f	Ковба	Борис	Ігорович
bachynska	LvZxXK	f	Бачинська	Аріна	Сергіївна
ostapenko14	incH59	f	Остапенко	Олександра	Сергіївна
samartseva14	S38xlV	f	Самарцева	Юлія	Сергіївна
holovach14	x0lY8o	f	Головач	Олександр	В‘ячеславович
kovalenko15	Fd44vw	f	Коваленко	Назарій	Віталійович
piatyhorskyi15	qPEm80	f	П‘ятигорський	Нікіта	Дмитрович
moroz	NYAOer	f	Мороз	Микита	Олександрович
malovanyi14	py5p7J	f	Мальований	Ярослав	Борисович
kovalchuk15	bkQ17wa	f	Ковальчук	Богдан	Андрійович
chikilov17	Dw6euK	f	Чікільов	Анатолій	Максимович
mykhailovskyi17	M5wVGA	f	Михайловський	Володимир	Дмитрович
gavrylchenkooooo	2953uysv	f	Гаврильченко	Анна	Олегівна
bilyk	FMSH145	f	Білик	Олеся	Олександрівна
zabolotnyi	9Jg88J	f	Заболотний	Антон	Григорович
shramko	p9aHQW	f	Шрамко	Георгій	Юрійович
dolhov15	2iQ6lk	f	Долгов	Олександр	Дмитрович
kozynets16	Esa0E0	f	Козинець	Валерія	Василівна
zholner16	ZomYOb	f	Жолнер	Петро	Дмитрович
khyzhniak15	5zb6dA	f	Хижняк	Максим	Олександрович
yerko16	IK3veF	f	Єрко	Світлана	Вадимівна
senko14	ICz25r	f	Сенько	Дмитро	Ігорович
khabatiuk14	7oyKy2	f	Хабатюк	Юлія	Олексіївна
starozhilova	J8WPjQ6	f	Старожилова	Анастасія	Володимирівна
len	nFz1A8	f	Лень	Андрій	Євгенович
onufryk17	rf37	f	Онуфрик	ЄваМарія	Сергіївна
rosiiskov17	rosii	f	Російськов	Владислав	Євгенович
zlotoiabko17	v77uLv	f	Злотоябко	Михайло	Борисович
borysiuk	5edMgv	f	Борисюк	Василина-Катерина	Іванівна
rudenko15	BJL4D0	f	Руденко	Ніка	Олександрівна
mudruk15	otsinkulic	f	Мудрук	Тетяна	Максимівна
babich15	9L1hxY	f	Бабіч	Анатолій	В'ячеславович
shkura15	skura15	f	Шкура	Ян	Олександрович
rybalchenko17	22vx2v	f	Рибальченко	Лев	Сергійович
baranivskyi15	7cv0tE	f	Баранівський	Вадим	Миколайович
grimalska	3ePKu4	f	Гримальська	Юлія	Євгеніївна
dzyuba	VpLiA6	f	Дзюба	Валерія	Євгеніївна
vasylieva15	Y1o4Cj	f	Васильєва	Марія	Георгіївна
baranova	jlvxU8	f	Баранова	Марія	Вячеславівна
mamenko	zxc123	f	Маменко	Валерія	Олександрівна
zhuk14	nR1X3t	f	Жук	Борис	Романович
tolstanova	S5aSA6d	f	Толстанова	Дарія	Михайлівна
rafalyuk	U4xDnT	f	Рафалюк	Роман	Богданович
svystun	0bMEbP	f	Свистун	Тарас	Андрійович
panasiuk14	QHSx20	f	Панасюк	Роман	Олегович
fisunenko14	12siLR	f	Фісуненко	Артем	Андрійович
shchurovsky	MuVSfX	f	Щуровський	Дмитро	Вячеславович
khodakovskyi15	artemi14102001AK	f	Ходаковський	Артем	Леонідович
lisnichenko	iQJzN9	f	Лісніченко	Олександр	Олександрович
podolsky	Qhrfli	f	Подольський	Нікіта	Володимирович
ponomarenko	zDB015	f	Пономаренко	Ольга	Олегівна
4ernywenko16	aBOwyq	f	Чернишенко	Владислав	Тарасович
homenyuk	XIyJKq	f	Гоменюк	Максим	Дмитрович
ivanchyk	Q4JqXbM	f	Іванчик	Ілля	Русланович
nikanov15	y5X2nM	f	Ніканов	Олексій	Максимович
pokotylo16	1lBXx3	f	Покотило	Захарій	Любомирович
miakobchuk	fjuythjrugdhfsvc	f	Якобчук	Микита	Олександрович
leontiyeva	SqsFK7c	f	Леонтьєва	Марія	Констянтинівна
chernenko	kn5h1b	f	Черненко	Всеволод	Сергійович
knopova	jfIAaq	f	Кнопова	Тетяна	Олександрівна
braginskyi16	eqrNS	f	Брагінський	Ілля	Вікторович
melesh18	2xreXyAY	f	Мелешко	Дмитро	Владиславович
afonin18	Dexel12	f	Афонина	Екатерина	Сергеевна
vorotchenko15	Bdl26f	f	Воротченко	Марія	Олександрівна
ivahnenkov	Af5C4d12	f	Івахненков	Дмитро	Сергійович
taiakina16	3Pg4X7	f	Таякіна	Ніка	Володимирівна
palamarchuk	solopal	f	Паламарчук	Соломія	Ігорівна
gulaya	ulisspoirot	f	Гулая	Єлизавета	Олексіївна
lisovenko17	YZ8tU5	f	Лісовенко	Ігор	Віталійович
sharov	Lf5Ej9W	f	Шаров	Микита	Ігоревич
yalovenko15	JyU90W	f	Яловенко	Ярослав	Васильович
nudha	YNv8Cc	f	Нудьга	Олексій	Романович
humennyk15	KC2Xy4	f	Гуменник	Богдан	Ігорович
dekret	YQh4zE	f	Декрет	Владислав	Володимирович
bondarenko14	KrM19V	f	Бондаренко	Марія	Юріївна
myhalko	hyzPmZ	f	Михалко	Катерина	Володимирівна
Rouqen	Zebasi	f	Тарабров	Гліб	Ігорович
danylchenko16	danylchenko	f	Данильченко	Варвара	Сергіївна
samarin	H290gL	f	Самарін	Євген	Євгенович
honcharuk15	bbb33469	f	Гончарук	Тарас	Сергійович
shcherbak	P26qlL	f	Щербак	Денис	Володимирович
stepura	fIiF7X	f	Степура	Андрій	Олексійович
bratchyk	kBq5Kn	f	Братчик	Софія	Романівна
savin15	XxES11	f	Савін	Дмитро	Анатолійович
balkashinov	jwSK5Eg	f	Балкашинов	Іван	Леонідович
simonov	7Vfjim	f	Симонов	Єгор	Денисович
litvinova	I0elig	f	Літвінова	Крістіна	Олександрівна
kovtun	BQfKjz	f	Ковтун	Володимир	Петрович
sidorenko	quWqK3s	f	Сидоренко	Нікіта	Сергійович
kyrychenko	EdkGCD	f	Кириченко	Богдан	Дмитрович
bondarieva17	8ap2jj1	f	Бондарєва	Галина	Вікторівна
prystiuk14	vp7C4r	f	Пристюк	Назар	Володимирович
malev	qio95C	f	Малєв	Іван	Юрійович
shydlovskyy15	55AAmd	f	Шидловський	Іван	Сергійович
zvarych15	1jp96rd057	f	Зварич	Альбіна	Валеріївна
piskun	DPGNnO	f	Піскун	Юлія	Андріївна
gordienko	b98Sll	f	Гордієнко	Іван	Максимович
miniaylo16	0nHZtJ	f	Міняйло	Святослав	Сергійович
kanderal	0WVUTa	f	Кандерал	Тетяна	Сергіївна
klymenko	NzfUXW	f	Клименко	Євгеній	Костянтинович
kleshchevnikov16	BLNomZ	f	Клєщевніков	Олег	Олексійович
stec	H6n9QZe	f	Стець	Владислав	Юрійович
gabia	kG81hp	f	Корженяускайте	Габія	а
martynchenko	ikIKBs	f	Мартинченко	Антон	Олегович
strus	3btnzb	f	Струсь	Роман	Андрійович
chehovoy	s6ptbKd	f	Чеховой	Віктор	Олександрович
chistov	CAe6Uxg	f	Чистов	Данило	Михайлович
chumak	HwW6bCU	f	Чумак	Андрій	Сергійович
lytvak15	2Awmd6	f	Литвак-Шевкопяс	Олег	Олегович
kovika16	px3aZX	f	Ковіка	Діана	Петрівна
mezhenskyi15	S7i0Jt	f	Меженський	Микита	Юрійович
malovanyi15	3LsH0U	f	Мальований	Дмитро	Борисович
padusenko15	Hs88Ox	f	Падусенко	Анастасія	Олексіївна
vasylenko14	B10LuY	f	Василенко	Дмитро	Олегович
bykov	Ot2JqN	f	Биков	Максим	Сергійович
kotsyk16	Kot9u	f	Коцик	Андрій	Олександрович
tsubina	uLlTEJ	f	Цубіна	Софія	Віталіївна
filkin	r5io9G	f	Фількін	Максим	Андрійович
kononenko	chemistry123	f	Кононенко	Кирило	Олегович
hrymailo	AF845b	f	Гримайло	Григорій	Ігорович
hubenko	0zQSti	f	Губенко	Роман	Іванович
kravets	ribmc6	f	Кравець	Володимир	Павлович
shulgin	xocbL4	f	Шульгін	Даниїл	Віталійович
bns	bodulns	t	Бодюл	Наталія	Сергіївна
\.


--
-- Data for Name: works; Type: TABLE DATA; Schema: public; Owner: fmh
--

COPY public.works (sched4w_id, work) FROM stdin;
272	Контрольная робота
272	Залік
272	ДКР
272	Самостійна робота
272	Домашня робота
272	Устна відповідь
272	Тест
3	Зачет
3	Экзамен
3	Соревнование
3	Нормативы
272	Зошит
203	Диктант
203	ДКР
203	Тест
203	Домашня робота
206	контурна карта
197	ДКР
197	Тест
197	зовнішній вигляд
203	Контрольная робота
203	Самостійна робота
203	Практична робота
203	Зошит
203	Лабораторна робота
203	Залік
203	Устна відповідь
197	Домашня робота
197	Контрольная робота
197	Самостійна робота
197	Класна робота
197	Практична робота
197	Зошит
5	Контрольна робота
5	Самостійна робота
5	Зошит
5	Поточна оцінка
5	Залік
206	Диктант
197	Лабораторна робота
197	Залік
197	Устна відповідь
30	сам. роб.
30	за урок
156	Теорія
82	диктант
82	тест
48	вірші напам'ять
48	тести
206	ДКР
206	Тест
206	Домашня робота
206	Контрольна робота
206	Самостійна робота
1	Самостiйна робота
1	Бонусна оцiнка
1	Тест
1	Домашня робота
1	Контрольна робота
1	Практична робота
1	Ведення зошита
1	Письмове опитування
1	Домашнiй тест
94	контрольна робота
156	Диктант
156	Тест
156	Домашня робота
156	Контрольная робота
156	Самостійна робота
156	За урок
69	Контрольна робота
69	Самостійна робота
69	зошит
69	Класна робота
70	Самостійна робота
70	Контрольна робота
70	Класна робота
70	Зошит
15	Тематична
15	семестрова
15	Самостійна робота
15	Практична робота
15	Усна відповідь
15	Письмова робота
86	письмо
86	читання
86	Диктант
86	самостійна робота
86	Тест
86	говоріння
86	аудіювання
272	Диктант
272	Практична робота
125	твір
125	літ диктант
125	контрольна робота
125	вірш їхав
206	Практична робота
206	Зошит
206	Лабораторна робота
206	Залік
206	Устна відповідь
217	Диктант
217	ДКР
25	Тематичний залік
217	Тест
217	Домашня робота
25	Фіздиктант
25	Тест
25	Домашня робота
25	Контрольна робота
217	Контрольная робота
217	Самостійна робота
217	Практична робота
217	Зошит
217	Лабораторна робота
235	Робота на
156	Зошит
60	тематична
60	за урок
60	самостiйна робота
60	ДКР
58	контурна карта
58	доповідь
58	тематична
58	самостійна робота
58	практ.робота
217	Залік
217	Устна відповідь
58	семестровий
58	контрольна робота
58	презентація
272	Лабораторна робота
235	Диктант
235	ДКР
30	контр. роб.
30	зошит
30	есе
30	тест
235	Тест
235	Домашня робота
235	Контрольная робота
235	Самостійна робота
143	Контрольная робота
143	Залік
143	ДКР
143	Самостійна робота
143	Домашня робота
143	Устна відповідь
143	Тест
143	Зошит
143	Диктант
143	Практична робота
143	Лабораторна робота
255	Контрольная робота
255	Залік
255	ДКР
255	Самостійна робота
255	Домашня робота
255	Устна відповідь
255	Тест
255	Зошит
255	Диктант
255	Практична робота
255	Лабораторна робота
145	Контрольная робота
145	Залік
145	ДКР
145	Самостійна робота
145	Домашня робота
145	Устна відповідь
145	Тест
145	Зошит
145	Диктант
145	Практична робота
145	Лабораторна робота
146	Контрольная робота
146	Залік
146	ДКР
146	Самостійна робота
146	Домашня робота
146	Устна відповідь
146	Тест
146	Зошит
146	Диктант
146	Практична робота
146	Лабораторна робота
15	Лабораторна робота
235	Практична робота
235	Зошит
235	Лабораторна робота
235	Залік
235	Устна відповідь
215	Практична робота
258	Контрольная робота
156	Лабораторна робота
156	Устна відповідь
156	ДКР
156	Практична робота
156	Залік
204	Диктант
204	ДКР
204	Тест
204	Домашня робота
204	Контрольная робота
204	Самостійна робота
204	Практична робота
204	Зошит
204	Лабораторна робота
204	Залік
204	Устна відповідь
163	Контрольная робота
163	Залік
163	ДКР
163	Самостійна робота
163	Домашня робота
163	Устна відповідь
163	Тест
163	Зошит
163	Диктант
163	Практична робота
163	Лабораторна робота
258	Залік
258	ДКР
258	Самостійна робота
258	Домашня робота
258	Устна відповідь
258	Тест
258	Зошит
164	Контрольная робота
164	Залік
164	ДКР
175	Диктант
175	ДКР
175	Тест
175	Домашня робота
175	Контрольна робота
175	Самостійна робота
175	Практична робота
175	Зошит
175	Лабораторна робота
175	Залік
175	Устна відповідь
164	Самостійна робота
164	Домашня робота
164	Устна відповідь
164	Тест
164	Зошит
164	Диктант
164	Практична робота
164	Лабораторна робота
167	Контрольная робота
167	Залік
167	ДКР
167	Самостійна робота
167	Домашня робота
167	Устна відповідь
167	Тест
167	Зошит
167	Диктант
167	Практична робота
167	Лабораторна робота
236	Диктант
236	ДКР
236	Тест
236	Домашня робота
236	Контрольная робота
236	Самостійна робота
236	Робота урок
198	Диктант
198	ДКР
198	Тест
198	Самостійна робота
198	контрольна робота
198	поточна
198	Устна відповідь
2	ведення зошита
2	теорія
2	річна
2	cамостійна робота
2	залік
2	семестрова 2
2	контрольна робота
2	домашнє завдання
2	математичний диктант
155	Теорія
155	Диктант
155	домашня с.р.
155	Тест
155	Домашня робота
155	Контрольная робота
99	лабораторна робота
172	Контрольная робота
172	Залік
172	ДКР
172	Самостійна робота
172	Домашня робота
172	Устна відповідь
172	Тест
172	Зошит
172	Диктант
172	Практична робота
172	Лабораторна робота
155	Самостійна робота
155	За урок
155	Зошит
273	Контрольная робота
273	Залік
273	ДКР
273	Самостійна робота
177	Контрольная робота
177	Залік
177	ДКР
177	Самостійна робота
177	Домашня робота
177	Устна відповідь
177	Тест
177	Зошит
177	Диктант
177	Практична робота
177	Лабораторна робота
273	Домашня робота
199	Теорія
199	Диктант
199	Тест
199	Домашня робота
199	Контрольная робота
199	Самостійна робота
199	За урок
199	Зошит
199	Лабораторна робота
199	Устна відповідь
199	ДКР
199	Практична робота
199	Залік
273	Устна відповідь
273	Тест
273	Зошит
273	Диктант
273	Практична робота
273	Лабораторна робота
155	Лабораторна робота
155	Устна відповідь
155	ДКР
155	Практична робота
155	Залік
14	за урок
14	самостійна робота
14	ДКР
14	теорія
14	зошит
14	домашня робота
14	контрольна робота
14	тест
22	за урок
22	самостійна робота
22	ДКР
22	теорія
22	зошит
22	домашня робота
22	контрольна робота
22	тест
22	Залік
78	переказ
78	за урок
78	тестування
78	усн. перек.
78	контр. роб.
78	твір
78	зошит
78	контр.тестув
110	Поточна
110	Практична робота
110	Письмове опитування
105	Поточна
105	Практична робота
105	Письмове опитування
236	Практична робота
236	Зошит
236	Лабораторна робота
236	Залік
216	Диктант
216	Тест
216	Домашня робота
216	Контрольна робота
216	Самостійна робота
236	Устна відповідь
23	дикт-кид-кут
23	контр термо
23	контрольна повторМехан
180	Контрольная робота
180	Залік
180	ДКР
180	Самостійна робота
180	Домашня робота
180	Устна відповідь
180	Тест
180	Зошит
180	Диктант
180	Практична робота
180	Лабораторна робота
181	Контрольная робота
181	Залік
181	ДКР
181	Самостійна робота
181	Домашня робота
181	Устна відповідь
181	Тест
181	Зошит
181	Диктант
181	Практична робота
181	Лабораторна робота
154	Теорія
154	Диктант
154	домашня с.р.
154	Тест
154	Домашня робота
154	Контрольная робота
154	Самостійна робота
151	Диктант
151	ДКР
151	Тест
151	Домашня робота
233	Контрольная робота
233	Залік
176	Диктант
176	ДКР
176	Тест
176	Домашня робота
176	Контрольная робота
176	Самостійна робота
176	Практична робота
233	ДКР
233	Самостійна робота
233	Домашня робота
154	За урок
154	Зошит
154	Лабораторна робота
154	Устна відповідь
154	ДКР
154	Практична робота
151	Контрольная робота
151	Самостійна робота
151	Практична робота
151	Зошит
151	Лабораторна робота
151	семестрова 1
151	Залік
151	Устна відповідь
10	самостійна робота
154	Залік
152	Диктант
152	ДКР
152	Тест
152	Домашня робота
152	Контрольная робота
152	Самостійна робота
152	Практична робота
152	Зошит
152	Лабораторна робота
152	Залік
152	Устна відповідь
220	Контрольная робота
220	Залік
220	ДКР
220	Самостійна робота
220	Домашня робота
220	Устна відповідь
220	Тест
220	Зошит
220	Диктант
220	Практична робота
10	ведення зошита
10	теорія
10	річна
200	Теорія
200	Диктант
200	Тест
200	Домашня робота
200	Контрольная робота
200	Самостійна робота
200	За урок
200	Зошит
200	Лабораторна робота
200	Устна відповідь
200	ДКР
10	залік
10	семестрова 2
10	контрольна робота
10	домашнє завдання
10	математичний диктант
233	Устна відповідь
233	Тест
233	Зошит
233	Диктант
233	Практична робота
200	Практична робота
200	Теорія та
200	Залік
233	Лабораторна робота
23	тест 2
23	формули
23	тест 1
123	тематична
127	Усне опитування
127	Контест рез.
127	КЗЗ
127	Контест роб.
123	правовий диктант
123	семестрова
123	річна
123	контрольна робота
150	Зошит ДР
150	Диктант
150	ДКР
150	Тест
150	Домашня робота
150	Контрольная робота
150	Самостійна робота
150	Практична робота
150	Зошит
150	Лабораторна робота
150	Залік
150	Устна відповідь
176	Зошит
176	Лабораторна робота
176	Залік
176	Устна відповідь
161	Диктант
161	ДКР
161	Тест
161	Домашня робота
161	Контрольная робота
161	Самостійна робота
161	Практична робота
161	Зошит
161	Лабораторна робота
161	Залік
161	Устна відповідь
165	Диктант
165	ДКР
165	Тест
165	Домашня робота
165	Контрольна робота
165	Самостійна робота
165	Практична робота
165	Зошит
165	Лабораторна робота
165	Залік
165	Устна відповідь
148	Диктант
148	ДКР
148	Тест
148	Домашня робота
148	Контрольная робота
148	зошит ДР
148	Самостійна робота
148	Практична робота
148	Зошит
148	Лабораторна робота
148	Залік
148	Устна відповідь
166	Диктант
166	ДКР
166	Тест
166	Домашня робота
166	Контрольна робота
166	Самостійна робота
166	Практична робота
166	Зошит
166	Лабораторна робота
166	Залік
166	Устна відповідь
149	Диктант
149	Самостійна ДЗ
149	Тест
149	Домашня робота
149	Контрольная робота
149	Самостійна робота
149	ДЗ зошит
149	Зошит
149	Лабораторна робота
149	Устна відповідь
149	ДКР
149	Практична робота
149	Залік
227	Контрольная робота
227	Залік
227	ДКР
227	Самостійна робота
227	Домашня робота
227	Устна відповідь
227	Тест
227	Зошит
227	Диктант
227	Практична робота
227	Лабораторна робота
23	темат 3
174	Робота урочна
174	ДКР
174	Тест
174	Самостійна робота
174	Контрольна робота
174	Практична робота
174	200-ка
157	Теорія
157	Диктант
157	Тест
157	Домашня робота
157	Контрольная робота
157	Самостійна робота
157	За урок
157	Зошит
157	Лабораторна робота
157	Устна відповідь
157	ДКР
157	Практична робота
157	Залік
174	Лабораторна робота
174	Річна
174	Залік
219	Контрольная робота
219	Залік
219	ДКР
219	Самостійна робота
219	Домашня робота
219	Устна відповідь
219	Тест
219	Зошит
219	Диктант
219	Практична робота
219	Лабораторна робота
220	Лабораторна робота
216	Класна робота
216	Зошит
216	Лабораторна робота
216	ДКР
216	Практична робота
216	Усна відповідь
23	термод тест-1
216	Вірш напам'ять
216	Залік
23	графіки
23	дикт-рівнозм
23	контр мол
23	сам-р-1
23	поточна
23	темат-2
213	Диктант
213	ДКР
213	Тест
46	тематична
46	самостійна робота
46	зошит
46	контрольна робота
46	усне опитування
213	Домашня робота
213	Контрольна робота
131	Усне опитування
131	Практична клас
131	Письмова робота
131	Практична
213	Самостійна робота
213	Класна робота
213	Практична робота
213	Усна відповідь
153	Диктант
153	ДКР
153	Тест
153	Домашня робота
153	Контрольная робота
153	Самостійна робота
153	Практична робота
153	Зошит
153	Лабораторна робота
153	Залік
153	Устна відповідь
213	Вірш напам'ять
213	Зошит
213	Залік
243	Контрольний норматив
254	Диктант
254	ДКР
254	Тест
254	Домашня робота
254	Контрольная робота
254	Самостійна робота
254	Практична робота
254	Зошит
210	Диктант
210	ДКР
210	Тест
210	Домашня робота
210	Контрольная робота
210	Самостійна робота
210	Практична робота
210	Зошит
210	Лабораторна робота
210	Залік
210	Устна відповідь
147	Диктант
147	Тест
147	Домашня робота
147	Контрольная робота
147	зошит ДР
147	Самостійна робота
147	Зошит
147	Лабораторна робота
147	математичні конкурси
147	Устна відповідь
147	ДКР
147	Практична робота
147	Залік
254	Лабораторна робота
254	Залік
254	Устна відповідь
266	Диктант
266	ДКР
266	Тест
266	Домашня робота
266	Контрольная робота
266	Самостійна робота
266	Практична робота
266	Зошит
266	Лабораторна робота
266	Залік
266	Устна відповідь
4	рівнозм рух
4	фіз-дикт-1
4	самостійна робота
4	форм кінем
4	фіз дикт
26	лабораторна робота
26	за урок
26	практична робота
26	самостiйна робота
218	Диктант
218	ДКР
218	Тест
218	Домашня робота
218	Контрольная робота
218	Самостійна робота
218	Практична робота
218	Зошит
218	Лабораторна робота
218	Залік
218	Устна відповідь
160	ДКР
160	Тест
160	Домашня робота
160	Контрольная робота
160	Самостійна робота
160	Класна робота
160	Практична робота
160	Бонусна оцінка
160	Зошит
160	Залік
160	Устна відповідь
26	контрольна робота
31	за урок
31	твір
31	тест
31	Контр. роб.
246	Диктант
246	ДКР
256	Контрольная робота
256	Залік
256	ДКР
256	Самостійна робота
256	Домашня робота
256	Устна відповідь
212	Диктант
212	ДКР
4	кидання під
4	тест
4	побудова лінз
4	поточна
4	контр.робота
256	Тест
256	Зошит
256	Диктант
256	Практична робота
256	Лабораторна робота
246	Тест
246	вірш
258	Диктант
258	Практична робота
258	Лабораторна робота
259	Практична робота
259	Лабораторна робота
246	Домашня робота
246	Контрольная робота
246	Самостійна робота
212	Тест
212	Домашня робота
246	Практична робота
246	Зошит
246	Лабораторна робота
246	Залік
246	Устна відповідь
223	Диктант
223	ДКР
223	Тест
223	Домашня робота
223	Контрольная робота
223	Самостійна робота
223	Практична робота
223	Зошит
223	Лабораторна робота
223	Залік
223	Устна відповідь
8	лабораторна робота
8	усна відповідь
8	тематична атестація
8	практична робота
8	семестрова
8	Контрольна робота
8	Самостійна робота
209	Диктант
209	ДКР
209	Тест
209	Домашня робота
209	Контрольная робота
209	Самостійна робота
209	Практична робота
209	Зошит
209	Залік
209	Устна відповідь
144	Диктант
144	ДКР
144	Тест
144	Домашня робота
144	Контрольная робота
144	Самостійна робота
144	Практична робота
144	Усна відповідь
144	Зошит
144	Лабораторна робота
144	Залік
237	Диктант
237	ДКР
237	Тест
237	Домашня робота
239	Контрольная робота
239	Залік
239	ДКР
239	Самостійна робота
239	Домашня робота
239	Устна відповідь
239	Тест
239	Зошит
239	Диктант
239	Практична робота
239	Лабораторна робота
240	Контрольная робота
240	Залік
240	ДКР
240	Самостійна робота
240	Домашня робота
240	Устна відповідь
240	Тест
240	Зошит
240	Диктант
240	Практична робота
240	Лабораторна робота
237	Кон роб1
237	Усна відповідь
237	СР-3
237	Зошит
237	СР-2
237	СР-1
226	ДКР
226	Тест
226	Домашня робота
226	Контрольная робота
226	Самостійна робота
244	Контрольная робота
244	Залік
244	ДКР
244	Самостійна робота
244	Домашня робота
244	Устна відповідь
244	Тест
244	Зошит
244	Диктант
244	Практична робота
244	Лабораторна робота
226	Практична робота
226	Зошит
226	Лабораторна робота
226	Залік
226	Устна відповідь
237	ТЕМА1 коливання
237	Залік
250	Контрольная робота
250	Залік
250	ДКР
250	Самостійна робота
250	Домашня робота
250	Устна відповідь
250	Тест
250	Зошит
250	Диктант
250	Практична робота
250	Лабораторна робота
259	Контрольная робота
259	Залік
259	ДКР
259	Самостійна робота
259	Домашня робота
259	Устна відповідь
259	Тест
259	Зошит
259	Диктант
133	Опитування
133	Практична робота
6	Самостійна робота
6	контрольна робота
207	Диктант
207	ДКР
207	Тест
207	Домашня робота
207	Контрольная робота
207	Самостійна робота
207	Практична робота
207	Зошит
207	Лабораторна робота
207	Залік
207	Устна відповідь
202	Фізичний диктант
202	ДКР
202	Тест
202	Домашня робота
202	Контрольная робота
202	Самостійна робота
202	Практична робота
202	Усна відповідь
202	Зошит
202	Лабораторна робота
202	Залік
241	Контрольная робота
241	Залік
241	ДКР
241	Самостійна робота
241	Домашня робота
241	Устна відповідь
241	Тест
241	Зошит
241	Диктант
241	Практична робота
241	Лабораторна робота
212	Контрольная робота
245	Контрольная робота
245	Залік
245	ДКР
245	Самостійна робота
245	Домашня робота
245	Устна відповідь
245	Тест
245	Зошит
245	Диктант
245	Практична робота
245	Лабораторна робота
247	Контрольная робота
247	Залік
247	ДКР
247	Самостійна робота
247	Домашня робота
247	Устна відповідь
247	Тест
247	Зошит
247	Диктант
247	Практична робота
247	Лабораторна робота
249	Контрольная робота
249	Залік
249	ДКР
249	Самостійна робота
249	Домашня робота
249	Устна відповідь
249	Тест
249	Зошит
249	Диктант
249	Практична робота
249	Лабораторна робота
251	Контрольная робота
251	Залік
251	ДКР
251	Самостійна робота
251	Домашня робота
251	Устна відповідь
251	Тест
251	Зошит
251	Диктант
251	Практична робота
251	Лабораторна робота
253	Контрольная робота
253	Залік
253	ДКР
253	Самостійна робота
253	Домашня робота
253	Устна відповідь
253	Тест
253	Зошит
253	Диктант
253	Практична робота
253	Лабораторна робота
212	Самостійна робота
212	Практична робота
212	Зошит
212	Лабораторна робота
212	Залік
212	Устна відповідь
231	Диктант
231	ДКР
231	Тест
231	Домашня робота
231	Контрольная робота
231	Самостійна робота
231	Практична робота
231	Зошит
231	Лабораторна робота
231	Залік
231	Устна відповідь
232	тематична
232	Диктант
232	ДКР
232	Тест
232	Домашня робота
232	Контрольная робота
232	Самостійна робота
232	Практична робота
232	Зошит
234	Диктант
234	ДКР
234	Тест
234	Домашня робота
234	Контрольная робота
234	Самостійна робота
234	Практична робота
234	Зошит
234	Лабораторна робота
234	Залік
234	Устна відповідь
264	Диктант
264	ДКР
264	Тест
264	Домашня робота
264	Контрольная робота
142	Диктант
142	ДКР
142	Тест
142	Домашня робота
142	Контрольная робота
142	Самостійна робота
142	Практична робота
142	Усна відповідь
142	Зошит
142	Лабораторна робота
142	Залік
264	Самостійна робота
264	Практична робота
264	Зошит
201	Диктант
201	Астрон. диктант
201	Тест
201	Домашня робота
201	Контрольная робота
201	Самостійна робота
201	За урок
201	Зошит
201	Лабораторна робота
201	Реферат
201	ДКР
201	Практична робота
201	Доповідь
201	Залік
108	контрольний норматив
264	Лабораторна робота
242	контрольний норматив
264	Залік
264	Устна відповідь
139	контурна карта
139	тематична
139	самостійна робота
139	семестрова
139	диктант
139	річна
139	контрольна робота
139	тест
139	СШАБританія Франція
178	Диктант
178	ДКР
178	Тест
178	Домашня робота
178	Контрольная робота
178	Самостійна робота
178	Зошит
178	Лабораторна робота
178	Усний переказ
178	Залік
178	Устна відповідь
232	Лабораторна робота
232	Залік
232	Устна відповідь
214	Диктант
214	Письмове завдання
214	ДКР
214	Тест
214	Домашня робота
214	Контрольная робота
214	Самостійна робота
214	Класна робота
214	Практична робота
214	Усна відповідь
214	Зошит
214	Залік
261	Диктант
261	ДКР
261	Тест
261	Домашня робота
261	Контрольная робота
261	Самостійна робота
261	Практична робота
261	Зошит
261	Лабораторна робота
261	Залік
261	Устна відповідь
36	усна відповідь
36	твір
36	зошит
248	Диктант
248	ДКР
248	Тест
248	Домашня робота
248	Самостійна робота
248	Зошит
248	Залік
248	Устна відповідь
225	ДКР
225	Тест
225	Домашня робота
225	Контрольная робота
225	Самостійна робота
225	Практична робота
225	Зошит
225	Лабораторна робота
225	Залік
225	Устна відповідь
238	Диктант
238	Поточна
238	ДКР
238	Тест
238	Домашня робота
238	Контрольная робота
238	Самостійна робота
238	Практична робота
238	Зошит
238	Лабораторна робота
238	Залік
16	Усне опитування
16	Практична
16	Письмове опитування
238	Устна відповідь
88	усна відповідь
265	Диктант
265	ДКР
265	Тест
265	Домашня робота
228	Диктант
228	ДКР
228	Тест
228	Домашня робота
228	Контрольная робота
228	Самостійна робота
228	Практична робота
228	Зошит
228	Лабораторна робота
228	Залік
228	Устна відповідь
265	Контрольная робота
265	Самостійна робота
265	Практична робота
265	Зошит
265	Лабораторна робота
265	Залік
265	Устна відповідь
267	Диктант
267	ДКР
267	Тест
267	Домашня робота
267	Самостійна робота
267	Контрольна робота
267	Практична робота
267	Зошит
267	Лабораторна робота
50	усна відповідь
50	зошит
50	контрольна робота
267	Залік
267	Устна відповідь
138	тематична
138	самостійна робота
138	семестрова
138	річна
138	контрольна робота
138	тест
34	усна відповідь
79	відповідь учня
79	тестування
79	твір
79	відпов. на
79	зошит
79	літ. диктант
79	1.Усна народна
79	напам'ять
224	Проект поточна
224	Тематична
224	КЗЗ
224	Практична робота
262	Контрольная робота
262	Залік
262	ДКР
262	Самостійна робота
262	Домашня робота
262	Устна відповідь
262	Тест
262	Зошит
262	Диктант
262	Практична робота
262	Лабораторна робота
263	Контрольная робота
263	Залік
263	ДКР
263	Самостійна робота
263	Домашня робота
263	Устна відповідь
263	Тест
263	Зошит
263	Диктант
263	Практична робота
263	Лабораторна робота
229	Диктант
229	ДКР
229	Тест
229	Домашня робота
229	Контрольная робота
229	Самостійна робота
229	Практична робота
229	Зошит
229	Лабораторна робота
229	Залік
229	Устна відповідь
224	Захист проекту
89	Поточна
89	Практична робота
89	Письмове опитування
107	Самостійна робота
107	Практична робота
107	Усна відповідь
252	Аудіювання
252	ДКР
252	Мовлення
252	Тест
252	Самостійна робота
252	Читання
252	Зошит
252	Твір
252	Устна відповідь
107	Зошит
129	Практична робота
129	Письмове опитування
129	Поточні
84	Аудіювання
84	Граматичне завдання
84	Тест
84	Домашня робота
84	Класна робота
84	Читання
84	Письмо
84	Говоріння
269	Контрольная робота
269	Залік
269	ДКР
269	Самостійна робота
269	Домашня робота
269	Устна відповідь
269	Тест
269	Зошит
269	Диктант
269	Практична робота
269	Лабораторна робота
270	Контрольная робота
270	Залік
270	ДКР
270	Самостійна робота
270	Домашня робота
270	Устна відповідь
270	Тест
270	Зошит
270	Диктант
270	Практична робота
270	Лабораторна робота
45	Самостійна робота
45	зошит
45	контрольна робота
45	Письмове опитування
45	усне опитування
271	Контрольная робота
271	Залік
271	ДКР
271	Самостійна робота
271	Домашня робота
271	Устна відповідь
271	Тест
271	Зошит
271	Диктант
271	Практична робота
271	Лабораторна робота
268	Диктант
268	ДКР
268	Тест
268	Домашня робота
268	Контрольная робота
268	Самостійна робота
268	Практична робота
268	Зошит
268	Лабораторна робота
268	Залік
268	Устна відповідь
257	Контрольний норматив
257	Диктант
257	Тематична
257	ДКР
257	Тест
257	Домашня робота
257	Самостійна робота
257	Практична робота
257	Зошит
257	Лабораторна робота
257	Залік
222	Диктант
222	ДКР
222	Тест
222	Домашня робота
222	Контрольная робота
222	Самостійна робота
222	Практична робота
222	Залік
179	Диктант
179	Тест
179	Домашня робота
179	Контрольная робота
179	Самостійна робота
179	Зошит
221	Project
221	Reading
221	Диктант
221	Тест
221	Listening
221	Домашня робота
221	Самостійна робота
221	Writing
221	Зошит
221	Устна відповідь
260	тематична
260	Тест
260	Самостійна робота
260	Практична робота
260	Письмова робота
230	Диктант
230	ДКР
230	Тест
230	Домашня робота
230	Контрольная робота
230	Самостійна робота
230	Практична робота
230	Зошит
230	Лабораторна робота
230	Залік
230	Устна відповідь
260	Устна відповідь
24	за урок
24	контр. робота
24	зошит
24	сам робота
24	тест
24	домашнє завдання
179	Лабораторна робота
179	літ. диктант
64	самостійна робота
64	опитування
64	Домашня робота
179	напам.
179	Устна відповідь
179	ДКР
179	Практична робота
179	Залік
179	Контр. роб.
205	контурна карта
205	Диктант
205	ДКР
205	Тест
205	Домашня робота
205	Контрольная робота
205	Самостійна робота
205	Практична робота
205	Зошит
205	Лабораторна робота
205	Залік
205	Устна відповідь
211	Тематична
211	ДКР
211	Тест
211	проект
211	Домашня робота
211	Контрольная робота
211	Самостійна робота
211	Практична робота
211	Усна відповідь
211	Зошит
211	Лабораторна робота
211	Залік
83	Аудіювання
83	Граматичне завдання
83	Тест
83	Домашня робота
83	Класна робота
83	Читання
83	Письмо
83	Говоріння
\.


--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: public; Owner: fmh
--

SELECT pg_catalog.setval('public.hibernate_sequence', 120299, true);


--
-- Name: prepod_id; Type: SEQUENCE SET; Schema: public; Owner: fmh
--

SELECT pg_catalog.setval('public.prepod_id', 273, true);


--
-- Name: class_and_students class_and_students_class_name_students_login_key; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.class_and_students
    ADD CONSTRAINT class_and_students_class_name_students_login_key UNIQUE (class_name, students_login);


--
-- Name: class_and_students class_and_students_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.class_and_students
    ADD CONSTRAINT class_and_students_pkey PRIMARY KEY (class_name, students_login);


--
-- Name: class class_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.class
    ADD CONSTRAINT class_pkey PRIMARY KEY (class_name);


--
-- Name: journal journal_date_stud_login_subject_key; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_date_stud_login_subject_key UNIQUE (date, stud_login, subject);


--
-- Name: journal journal_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_pkey PRIMARY KEY (id);


--
-- Name: move move_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.move
    ADD CONSTRAINT move_pkey PRIMARY KEY (login);


--
-- Name: prepod prepod_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.prepod
    ADD CONSTRAINT prepod_pkey PRIMARY KEY (schedule_id);

ALTER TABLE public.prepod CLUSTER ON prepod_pkey;


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (role);


--
-- Name: subject_list subject_list_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.subject_list
    ADD CONSTRAINT subject_list_pkey PRIMARY KEY (subject);


--
-- Name: authorities uk_login_auth; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.authorities
    ADD CONSTRAINT uk_login_auth UNIQUE (login, authority);


--
-- Name: prepod ukokrx10t2tq9d3cabgvdbbhawf; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.prepod
    ADD CONSTRAINT ukokrx10t2tq9d3cabgvdbbhawf UNIQUE (login, subject);


--
-- Name: schedule_and_class uktkl0yoaivqdwvu8qp5iyjgcy4; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.schedule_and_class
    ADD CONSTRAINT uktkl0yoaivqdwvu8qp5iyjgcy4 UNIQUE (schedules_id, class_name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (login);


--
-- Name: journal_class_name_date_subject_idx; Type: INDEX; Schema: public; Owner: fmh
--

CREATE INDEX journal_class_name_date_subject_idx ON public.journal USING btree (class_name, date, subject);


--
-- Name: authorities authorities_authority_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.authorities
    ADD CONSTRAINT authorities_authority_fkey FOREIGN KEY (authority) REFERENCES public.roles(role) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: authorities authorities_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.authorities
    ADD CONSTRAINT authorities_login_fkey FOREIGN KEY (login) REFERENCES public.users(login) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: class_and_students class_and_students_class_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.class_and_students
    ADD CONSTRAINT class_and_students_class_name_fkey FOREIGN KEY (class_name) REFERENCES public.class(class_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: class_and_students class_and_students_students_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.class_and_students
    ADD CONSTRAINT class_and_students_students_login_fkey FOREIGN KEY (students_login) REFERENCES public.users(login) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: journal journal_class_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_class_name_fkey FOREIGN KEY (class_name) REFERENCES public.class(class_name) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: journal journal_stud_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_stud_login_fkey FOREIGN KEY (stud_login) REFERENCES public.users(login) ON UPDATE CASCADE;


--
-- Name: journal journal_subject_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.journal
    ADD CONSTRAINT journal_subject_fkey FOREIGN KEY (subject) REFERENCES public.subject_list(subject) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: move move_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.move
    ADD CONSTRAINT move_login_fkey FOREIGN KEY (login) REFERENCES public.users(login) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prepod prepod_login_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.prepod
    ADD CONSTRAINT prepod_login_fkey FOREIGN KEY (login) REFERENCES public.users(login) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: prepod prepod_subject_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.prepod
    ADD CONSTRAINT prepod_subject_fkey FOREIGN KEY (subject) REFERENCES public.subject_list(subject) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: schedule_and_class schedule_and_class_class_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.schedule_and_class
    ADD CONSTRAINT schedule_and_class_class_name_fkey FOREIGN KEY (class_name) REFERENCES public.class(class_name) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: schedule_and_class schedule_and_class_schedules_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.schedule_and_class
    ADD CONSTRAINT schedule_and_class_schedules_id_fkey FOREIGN KEY (schedules_id) REFERENCES public.prepod(schedule_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: topics topics_sched4t_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.topics
    ADD CONSTRAINT topics_sched4t_id_fkey FOREIGN KEY (sched4t_id) REFERENCES public.prepod(schedule_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: works works_sched4w_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: fmh
--

ALTER TABLE ONLY public.works
    ADD CONSTRAINT works_sched4w_id_fkey FOREIGN KEY (sched4w_id) REFERENCES public.prepod(schedule_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

