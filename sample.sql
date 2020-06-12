/* 질의그룹 1 2 */
SELECT `S#` FROM SPJ WHERE `J#` = "J1" ORDER BY `S#`;
SELECT * FROM SPJ WHERE QTY between 300 and 750;
/* JOIN 3 */
SELECT `P#` FROM SPJ WHERE `S#` IN (select `S#` from Supplier where CITY ='London') AND `J#` IN (select `J#` from Project where CITY ='London') ;
/*4 first city */
SELECT DISTINCT s.CITY as firstCity, j.CITY as secondCity FROM .Supplier as s, .Project as j WHERE EXISTS(select * from .SPJ as spj where spj.`S#` = s.`S#` AND spj.`J#`=j.`J#`);
/*5 COUNT*/
SELECT `P#`,`J#`,sum(QTY) FROM .SPJ GROUP BY `P#`,`J#`;
/* 6,7 */ 
SELECT distinct `P#` FROM .SPJ WHERE QTY>=(select avg(QTY) from .SPJ);
SELECT `J#`,CITY FROM .Project WHERE CITY LIKE '_o%';
/*sub 8 */
SELECT `J#` FROM .Project WHERE CITY = (select CITY from .Project ORDER BY CITY ASC LIMIT 1);
/* 최대 수량 9*/
SELECT `J#` FROM .Project j WHERE (select max(QTY) from .SPJ where `J#`='J1') < (select avg(QTY) from .SPJ where `P#`='P1' AND `J#`=`J#`);

/*EXIST 10 */
SELECT DISTINCT `P#` FROM .SPJ as spj WHERE EXISTS (select * from Project  as j where CITY ='London' AND j.`J#`=spj.`J#`);
/*NOT EXIST 11, 런던S의 redP를 공급받지 "않은" J#*/
SELECT `J#` FROM .Project as j WHERE NOT EXISTS (select * from .SPJ as spj where j.`J#` = spj.`J#` and(`S#`,`P#`) in(select `S#`,`P#` from .Supplier s, .Part p where s.CITY ='London' and p.color='Red') );
/*12, 공급자 S1으로부터 최소한 모든 부품 공급받은 J# */
SELECT DISTINCT `J#` FROM .SPJ WHERE `P#` IN(select `P#` from .SPJ where `S#`='S1');
/*13 Union 테이블 별로 city 목록 가져오면 됨 */
SELECT CITY FROM .Supplier UNION select CITY from .Part UNION select CITY from .Project;

/* 질의그룹 4, 14 거래 명세가 없는 프로젝트는 모두 지우시오.*/
/* 15. S10 추가*/
INSERT INTO .Supplier VALUES('S10','Smith',NULL,'NewYork');
/* 16. 테이블 생성*/
CREATE TABLE Plist SELECT `P#` FROM .Supplier s , .SPJ spj WHERE s.`S#`=spj.`S#` AND s.CITY="London" UNION (SELECT `P#` FROM .Project j,.SPJ spj WHERE j.`J#`=spj.`J#` AND j.CITY="London");
/* 17. 테이블 생성2 -> 프로젝트 번호  */
CREATE TABLE Jlist SELECT spj.`J#` FROM .Project j, .SPJ spj WHERE j.`J#` = spj.`J#` AND j.CITY ='London' UNION (SELECT spj.`J#` FROM .Supplier s , .SPJ spj WHERE s.`S#`=spj.`S#` AND s.CITY="London");

/* 18.DDL _CREATE */
CREATE TABLE suppliers (`S#`varchar(45) NOT NULL, SNAME varchar(100) NOT NULL, STATUS int(100) NULL, CITY varchar(30) NULL,
PRIMARY KEY (`S#`));
CREATE TABLE parts (`P#`varchar(45) NOT NULL, PNAME varchar(100) NOT NULL, COLOR varchar(100) NOT NULL, WEIGHT varchar(100) NOT NULL, CITY varchar(300) NOT NULL,
PRIMARY KEY (`P#`));
CREATE TABLE projects (`J#`varchar(45) NOT NULL, JNAME varchar(100) NOT NULL, CITY varchar(300) NOT NULL,
PRIMARY KEY (`J#`));

/*19. INDEX pk 제약조건 */
CREATE INDEX Sidx ON Supplier (`S#`);
CREATE INDEX Pidx ON Part (`P#`);
CREATE INDEX Jidx ON Project (`J#`);
/*20. sample 데이터베이스 만들기 with sample table */
CREATE DATABASE `suppliers-parts-projects`;
CREATE TABLE `suppliers-parts-projects`.suppliers LIKE .suppliers;
INSERT INTO `suppliers-parts-projects`.suppliers SELECT * FROM .Supplier;
CREATE TABLE `suppliers-parts-projects`.parts LIKE .parts;
INSERT INTO `suppliers-parts-projects`.parts SELECT * FROM .Part;
CREATE TABLE `suppliers-parts-projects`.projects LIKE .projects;
INSERT INTO `suppliers-parts-projects`.projects SELECT * FROM .Project;
CREATE TABLE `suppliers-parts-projects`.SPJ LIKE sopt26.SPJ;
INSERT INTO `suppliers-parts-projects`.SPJ SELECT * FROM sopt26.SPJ;
/*21.View*/
CREATE VIEW view1(`S#`,`P#`) AS SELECT `S#`,`P#` FROM Supplier s, .Part p WHERE NOT (s.CITY = p.CITY);
select * from view1;
/*22. 런던에 위치한 공급자 기록 */
CREATE VIEW londonS AS SELECT * FROM .Supplier s WHERE s.CITY='London';
select * from londonS;
/*23*/
CREATE VIEW allProjects (`J#`,CITY) AS SELECT DISTINCT j.`J#`,j.CITY FROM Project j,SPJ spj WHERE spj.`S#`='S1' AND spj.`P#`='P1';
select * from allProjects;
/*24*/
CREATE VIEW HEAVYWEIGHTS (`P#`, WT, COL) AS SELECT `P#`, WEIGHT, COLOR FROM Part WHERE WEIGHT > 14;
SELECT * FROM HEAVYWEIGHTS WHERE COL = 'Green';
UPDATE HEAVYWEIGHTS SET COL = 'White' WHERE WT = 18;
DELETE FROM HEAVYWEIGHTS WHERE WT < 10;
INSERT INTO HEAVYWEIGHTS(`P#`, WT, COL) VALUES ('P99', 12, 'Purle');
