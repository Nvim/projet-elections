-- REQUETES SIMPLES -- 

-- 1/ liste des candidats de l'élection européenne 2009 --
SELECT distinct Nom, Prenom from Candidat inner join votes on candidat.numdepot = votes.ref_candidat where Ref_Election = 1; 

-- 2/ liste des bureaux de l'élection legslatives 2012 --
SELECT * from Bureau inner join votes on bureau.num_bureau = votes.ref_bureau where ref_election = 3 ORDER BY `Num_Bureau`;

-- 3/ nb de candidats pour les régionales 2eme tour --
select count( DISTINCT numdepot) as "nombre de Candidats" from Candidat inner join votes on candidat.numdepot = votes.ref_candidat where Ref_election = 2; 

-- 4/ nb de bureaux pour l'election legislatives 2007 --
select count(distinct num_bureau) as "nombre de Bureaux" from bureau inner join votes on bureau.num_bureau = votes.ref_bureau where ref_election = 4;

-- 5/ liste des votes effectués dans les bureaux du 20eme arrondissement de Paris --
select * from votes inner join bureau on votes.ref_bureau = bureau.num_bureau where CP = 75120 ORDER BY nb_votes desc;

-- 6/ Liste des candidats ayant récoltés 0 votes à l'élection Européennes 2009 --
select Nom, Prenom, nb_votes as "Nombre de Votes" from candidat inner join votes on ref_candidat = numdepot where nb_votes = 0 and ref_election = 1;

-- 7/ Liste des bureaux dans lesquels il y eu moins de 600 votes exprimés --
select num_bureau as "Bureau", nbexprimes as "Nombre de Votes exprimés", libelle_scrutin as "Election"
from bureau inner join inscription on `Num_Bureau` = `Ref_bureau`
inner join election on `Ref_election` = `ID_scrutin`
where nbexprimes<600;

-- 8/ Liste des bureaux dans lesquels il y a eu plus de 1000 votes exprimés --
select num_bureau as "Bureau", nbexprimes as "Nombre de Votes exprimés", libelle_scrutin as "Election"
from bureau inner join inscription on `Num_Bureau` = `Ref_bureau`
inner join election on `Ref_election` = `ID_scrutin`
where nbexprimes>1000;

-- 9/ Liste des bureaux ayant moins de mille inscrits toutes elections confondues --
select num_bureau as "Bureau", nbinscrits as "Nombre d'inscrit"
from bureau inner join inscription on `Num_Bureau` = `Ref_Bureau`
where nbinscrits < 1000;

-- 10/ Liste des candidats classée par le nombre de votes --
select Nom, Prenom, nb_votes from votes inner join Candidat on ref_candidat = numdepot order by nb_votes desc;


-- REQUETES COMPLEXES --

-- 1/ Nombre de candidats par élection --
select count( DISTINCT ref_candidat) as "Nombre de Candidats", libelle_scrutin as "Election"  from votes inner join election on ref_election = id_scrutin group by(libelle_scrutin);

-- 2/ Total des votes par élection --
select sum(nb_votes) as "Nombre de Votes", libelle_scrutin as "Election" from votes inner join election on ref_election = id_scrutin group by(libelle_scrutin);

-- 3/ Total des votes par bureau --
select sum(nb_votes) as "Nombre de Votes", num_bureau as "Bureau" from votes inner join bureau on ref_bureau = num_bureau group by(num_bureau) order by sum(nb_votes) desc;

-- 4/ Total des votes par candidats pour l'élection Européenne 2009, trié par le nombre de votes décroissant --
select sum(nb_votes) as "Nombre de Votes", Nom, Prenom from votes 
inner join candidat on ref_candidat = numdepot
where `Ref_Election` = 1
group by(numdepot) 
order by sum(nb_votes) desc;

-- 5/ Total des votes pour l'Election Législatives 2012 dans les bureaux dans le 5ème arrondissement --
select sum(nb_votes) as "Nombre de Votes", cp as "Code Postal" from votes
inner join bureau on `Num_Bureau` = `Ref_Bureau`
where `CP` = 75105 and `Ref_Election` = 3;

-- 6/Total du nombres de votes exprimés par elections --
select sum(nb_votes) as "Nombre de Votes", libelle_scrutin as "Election" from votes
inner join election on `Ref_Election` = `ID_scrutin`
group by libelle_scrutin;

-- 7/Nombre de vote moyen lors des législatives --
select avg(nb_votes) as "Nombre de Votes Moyen", libelle_scrutin as "Election" from votes
inner join election on `Ref_Election` = `ID_scrutin`
where `Ref_Election` = 3 or `Ref_Election` = 4
group by `LIBELLE_scrutin`;

-- 8/ Nombre de votes non comptabilisés par éléction --
select sum(nbvotants-nbexprimes) as "Votes non Comptabilisés", libelle_scrutin as "Election" from inscription
inner join election on `Ref_election` = `ID_scrutin`
group by `LIBELLE_scrutin`
order by sum(nbvotants-nbexprimes) desc;

-- 9/Nombre moyen de votes non comptabilisés (Nuls ou Blancs)par arrondissement aux éléctions régionales 2eme tour --
select round(avg(nbvotants-nbexprimes),1) as "Moyenne des Votes non Complabilisés", cp as "Arrondissement" from inscription
inner join bureau on `Ref_bureau` = `Num_Bureau`
where `Ref_election` = 2
group by cp
order by avg(nbvotants-nbexprimes) DESC;

-- 10/ Nombre moyen d'absentionnistes par bureau --
select round(avg(nbinscrits-nbvotants), 2) as "Moyenne d'Absentionnistes", `Ref_bureau` as "Bureau" from inscription
group by `Ref_bureau`
order by avg(nbinscrits-nbvotants) desc;

-- 11/ Elections ou le taux d'abstention combiné au taux de votes non comptabilisés est le plus élevé --
select ((sum(nbinscrits-nbvotants)/sum(nbinscrits)) + (sum(nbvotants-nbexprimes)/nbvotants)) as "Taux d'abstention et de votes non comptabilisés", 
libelle_scrutin as "Election" from inscription
inner join election on `Ref_election` = `ID_scrutin`
group by `Ref_election`
order by ((sum(nbinscrits-nbvotants)/sum(nbinscrits)) + (sum(nbvotants-nbexprimes)/nbvotants)) desc;


-- REQUETES DE MISE A JOUR --

-- 1/ Dans la table inscription rajouter une colonne recensant le nombre d'abstention --
alter table inscription add column nb_abstention INT; 

-- 1 bis / Peupler la colonne abstention (différence entre le nombre d'inscrits et de votants) --
update inscription set nb_abstention = nbinscrits - nbvotants; 

-- 2/ Dans la table inscription rajouter une colonne recensant le nombre de votes blancs -- 
alter table inscription add column nb_votes_blancs INT;

-- 2 bis/ Peupler la colonne abstention (différence entre le nombre de votant et le nombre de votes exprimés) --
update inscription set nb_votes_blancs = nbvotants - nbexprimes;

-- 3/ Les bureaux du premier arrondissement sont délocalisés dans le 4ème --
update bureau set cp = 75104 where cp = 75101;

-- 4/ Augmentation du nombre d'inscrits de 2% dans le bureau 23  lors de l'election legislatives 2012 --
update inscription set nbinscrits = nbinscrits +(0.2 *nbinscrits) where ref_bureau = 23 and ref_election = 3;

-- 5/ Dans vote, ne garder que les candidats ayant plus de 0 votes -- 
delete from vote where nb_votes = 0;

-- 6/ Modification du mois dans la date du scrutin des legislatives --
update election set date_scrutin = DATE_ADD(date_scrutin, INTERVAL -4 MONTH) where month(date_scrutin) = 10 and libelle_scrutin like "Législatives%";











